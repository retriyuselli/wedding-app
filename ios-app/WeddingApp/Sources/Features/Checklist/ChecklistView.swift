import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared

    @State private var events: [WeddingEvent] = []
    @State private var tasks: [PreparationTask] = []
    @State private var sections: [PreparationSection] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var selectedFilter = L10n.Common.all
    @State private var expandedSections: Set<Int> = []
    @State private var showAllSections: Set<Int> = []
    @State private var selectedTask: PreparationTask?
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    @State private var showAddTaskSheet = false
    @State private var addTaskPreferredEventId: Int?
    @State private var showPaywall = false
    @State private var cachedAllGroups: [ChecklistGroup] = []
    @State private var cachedGroups: [ChecklistGroup] = []
    @State private var scrollItems: [ChecklistScrollItem] = []
    @State private var totalTasks = 0
    @State private var doneTasks = 0
    @State private var inProgressTasks = 0
    @State private var pendingTasks = 0
    @State private var lastLoadAt: Date?

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

    private var sectionTitles: [Int: String] {
        Dictionary(sections.map { ($0.id, $0.title) }, uniquingKeysWith: { first, _ in first })
    }

    private var groups: [ChecklistGroup] { cachedGroups }

    private var allGroups: [ChecklistGroup] { cachedAllGroups }

    private var filterOptions: [String] {
        var options = [L10n.Common.all]
        options.append(contentsOf: allGroups.map(\.title))
        return options
    }

    private var overallProgress: Double { totalTasks == 0 ? 0 : Double(doneTasks) / Double(totalTasks) }

    private func recomputeChecklistCaches() {
        let built = buildGroups()
        cachedAllGroups = built

        var source = built
        if selectedFilter != L10n.Common.all {
            source = source.filter { $0.title == selectedFilter }
        }
        if !searchText.isEmpty {
            source = source.compactMap { group in
                let matched = group.tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                guard !matched.isEmpty else { return nil }
                return ChecklistGroup(
                    id: group.id,
                    title: group.title,
                    iconName: group.iconName,
                    dateText: group.dateText,
                    locationText: group.locationText,
                    tasks: matched
                )
            }
        }
        cachedGroups = source
        rebuildScrollItems(from: source)

        totalTasks = built.reduce(0) { $0 + $1.tasks.count }
        doneTasks = built.reduce(0) { $0 + $1.tasks.filter { $0.statusValue == .done }.count }
        inProgressTasks = built.reduce(0) { $0 + $1.tasks.filter { $0.statusValue == .inProgress }.count }
        pendingTasks = built.reduce(0) { $0 + $1.tasks.filter { $0.statusValue == .pending }.count }
    }

    private func rebuildScrollItems(from groups: [ChecklistGroup]) {
        var items: [ChecklistScrollItem] = []
        items.reserveCapacity(groups.count * 6)

        for group in groups {
            let isExpanded = expandedSections.contains(group.id) || isSearching
            let showAll = showAllSections.contains(group.id)
            items.append(.header(group, isExpanded: isExpanded))

            guard isExpanded else { continue }

            let visibleTasks = showAll ? group.tasks : Array(group.tasks.prefix(5))
            for task in visibleTasks {
                items.append(.task(groupId: group.id, task: task))
            }
            if group.tasks.count > 5 {
                items.append(.showMore(group, showingAll: showAll))
            }
            if group.id > 0 {
                items.append(.addTask(groupId: group.id))
            }
        }

        scrollItems = items
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        header
                        if isSearching { searchBar }
                        summaryCard
                        if !isSearching { filterChips }
                        checklistContent
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .opacity(isPremium ? 1 : 0.55)
                .allowsHitTesting(isPremium)

                if !isPremium {
                    PremiumLockedOverlay {
                        showPaywall = true
                    }
                    .padding(.horizontal, 24)
                }
            }
            .background {
                AppTheme.background.ignoresSafeArea()
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task {
                if isPremium {
                    await load()
                } else {
                    await loadPreview()
                }
            }
            .refreshable {
                if isPremium {
                    await load()
                } else {
                    await loadPreview()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                guard isPremium else { return }
                if let lastLoadAt, Date().timeIntervalSince(lastLoadAt) < 60 { return }
                Task { await load() }
            }
            .onChange(of: isPremium) { _, premium in
                Task {
                    if premium {
                        await load()
                    } else {
                        await loadPreview()
                    }
                }
            }
            .onChange(of: selectedFilter) { _, _ in recomputeChecklistCaches() }
            .onChange(of: searchText) { _, _ in recomputeChecklistCaches() }
            .onChange(of: expandedSections) { _, _ in rebuildScrollItems(from: groups) }
            .onChange(of: showAllSections) { _, _ in rebuildScrollItems(from: groups) }
            .onChange(of: isSearching) { _, _ in rebuildScrollItems(from: groups) }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onUnlocked: {
                    Task { await load() }
                })
                .environmentObject(session)
            }
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailView(
                    task: task,
                    eventTitle: eventTitle(for: task),
                    sectionTitle: sectionTitle(for: task),
                    onChangeStatus: { newStatus in changeStatus(task, to: newStatus) },
                    onSubTasksUpdated: { taskId, status, subTasks in
                        syncTaskStatus(taskId: taskId, status: status.rawValue, subTasks: subTasks)
                    },
                    onTaskEdited: { taskId, result in applyTaskEdit(taskId: taskId, result: result) }
                )
            }
            .sheet(isPresented: $showAddTaskSheet, onDismiss: {
                addTaskPreferredEventId = nil
            }) {
                AddChecklistTaskSheet(
                    events: events,
                    preferredEventId: addTaskPreferredEventId ?? preferredAddEventId
                ) { created in
                    tasks.insert(created, at: 0)
                    if let eventId = created.weddingEventId {
                        expandedSections.insert(eventId)
                        showAllSections.insert(eventId)
                    }
                    selectedFilter = L10n.Common.all
                    recomputeChecklistCaches()
                }
            }
        }
    }

    private func runPremiumOrPaywall(_ action: @escaping () -> Void) {
        PremiumGate.presentOrRun(session: session, showPaywall: $showPaywall, action: action)
    }

    private var preferredAddEventId: Int? {
        if selectedFilter != L10n.Common.all,
           let match = events.first(where: {
               ($0.jenisLabel ?? $0.jenisAcara.capitalized) == selectedFilter
           }) {
            return match.id
        }
        return events.first?.id
    }

    private func eventTitle(for task: PreparationTask) -> String {
        if let event = events.first(where: { $0.id == task.weddingEventId }) {
            return event.jenisLabel ?? event.jenisAcara.capitalized
        }
        return allGroups.first(where: { $0.tasks.contains(where: { $0.id == task.id }) })?.title ?? L10n.Checklist.fallbackSection
    }

    private func sectionTitle(for task: PreparationTask) -> String? {
        guard let sectionId = task.sectionId else { return nil }
        return sectionTitles[sectionId]
    }

    private func changeStatus(_ task: PreparationTask, to status: PreparationTask.Status) {
        syncTaskStatus(taskId: task.id, status: status.rawValue, subTasks: nil)
        persistTaskStatus(task, status: status)
    }

    private func syncTaskStatus(taskId: Int, status: String, subTasks: [PreparationSubTask]?) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].status = status
            if let subTasks {
                tasks[index].subTasks = subTasks
            }
        }
        if selectedTask?.id == taskId {
            selectedTask?.status = status
            if let subTasks {
                selectedTask?.subTasks = subTasks
            }
        }
        recomputeChecklistCaches()
    }

    private func applyTaskEdit(taskId: Int, result: TaskEditResult) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].title = result.title
            tasks[index].description = result.description
            tasks[index].notes = result.notes
            tasks[index].priority = result.priority.rawValue
            tasks[index].dueDate = result.dueDate
        }
        if selectedTask?.id == taskId {
            selectedTask?.title = result.title
            selectedTask?.description = result.description
            selectedTask?.notes = result.notes
            selectedTask?.priority = result.priority.rawValue
            selectedTask?.dueDate = result.dueDate
        }
        recomputeChecklistCaches()
    }

    private func persistTaskStatus(_ task: PreparationTask, status: PreparationTask.Status) {
        guard !tasks.isEmpty else { return }

        Task {
            try? await APIClient.shared.requestNoContent(
                "customer-preparation-tasks/\(task.id)",
                method: "PUT",
                json: ["title": task.title, "status": status.rawValue]
            )
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Checklist.title)
                    .font(AppFont.serifBold(32))
                    .foregroundStyle(AppTheme.titleOnBackground)

                Text(L10n.Checklist.subtitle)
                    .lineSpacing(2)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.mutedOnBackground)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button {
                    runPremiumOrPaywall {
                        isSearching = true
                        isSearchFocused = true
                    }
                } label: {
                    circleButton("magnifyingglass")
                }
                .buttonStyle(.plain)

                Button {
                    runPremiumOrPaywall {
                        addTaskPreferredEventId = nil
                        showAddTaskSheet = true
                    }
                } label: {
                    circleButton("plus")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Checklist.addTask)
            }
            .padding(.top, 4)
        }
        .frame(height: 96, alignment: .top)
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.inkMuted(0.45))

                TextField(L10n.Checklist.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(15))
                    .foregroundStyle(AppTheme.ink)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        isSearchFocused = false
                        KeyboardDismiss.resign()
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.inkMuted(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .premiumListRow(cornerRadius: 16)

            Button {
                isSearching = false
                searchText = ""
                isSearchFocused = false
                KeyboardDismiss.resign()
            } label: {
                Text(L10n.Common.cancel)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.titleOnBackground)
            }
            .buttonStyle(.plain)
        }
    }

    private func circleButton(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(AppTheme.iconOnChrome)
            .frame(width: 44, height: 44)
            .background(AppTheme.chrome, in: Circle())
            .overlay {
                Circle()
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
    }

    private var summaryCard: some View {
        HStack(spacing: 16) {
            ChecklistRing(progress: overallProgress)
                .frame(width: 108, height: 108)

            HStack(spacing: 0) {
                summaryStat(icon: "checkmark.circle.fill", tint: AppTheme.sageDark, label: L10n.Checklist.done, value: doneTasks)
                summaryStat(icon: "clock.fill", tint: AppTheme.goldOnLightSurface, label: L10n.Checklist.running, value: inProgressTasks)
                summaryStat(icon: "circle", tint: AppTheme.statusMuted, label: L10n.Checklist.notStarted, value: pendingTasks)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .premiumListRow(cornerRadius: 28)
    }

    private func summaryStat(icon: String, tint: Color, label: String, value: Int) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)

            Text(label)
                .font(AppFont.medium(11))
                .foregroundStyle(AppTheme.inkMuted(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("\(value)")
                .font(AppFont.semibold(20))
                .monospacedDigit()
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(L10n.Checklist.tasks)
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.inkMuted(0.38))
        }
        .frame(maxWidth: .infinity)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filterOptions, id: \.self) { option in
                    let isSelected = option == selectedFilter
                    Button {
                        selectedFilter = option
                    } label: {
                        Text(option)
                            .font(AppFont.semibold(13))
                            .foregroundStyle(isSelected ? .white : AppTheme.sageMuted(0.72))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                Capsule()
                                    .fill(isSelected ? AppTheme.sageDark : AppTheme.chipIdleFill)
                            }
                            .overlay {
                                Capsule()
                                    .stroke(
                                        isSelected ? Color.clear : AppTheme.hairline,
                                        lineWidth: 1
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var checklistContent: some View {
        if isLoading && tasks.isEmpty && events.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        } else if let errorMessage, allGroups.isEmpty {
            MoreEmptyState(
                icon: "exclamationmark.triangle",
                title: L10n.Common.warning,
                message: errorMessage
            )
        } else if allGroups.isEmpty {
            MoreEmptyState(
                icon: "checklist",
                title: L10n.Checklist.emptyTitle,
                message: L10n.Checklist.emptySub
            )
        } else {
            // One LazyVStack child per header/task so offscreen rows stay unbuilt.
            ForEach(scrollItems) { item in
                scrollItemView(item)
            }
        }
    }

    @ViewBuilder
    private func scrollItemView(_ item: ChecklistScrollItem) -> some View {
        switch item {
        case .header(let group, let isExpanded):
            Button {
                guard !isSearching else { return }
                if isExpanded {
                    expandedSections.remove(group.id)
                } else {
                    expandedSections.insert(group.id)
                }
            } label: {
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: group.iconName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.iconOnChip)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(group.title)
                                .font(AppFont.serifSemibold(17))
                                .foregroundStyle(AppTheme.titleOnGlass)

                            if let dateText = group.dateText {
                                Label(dateText, systemImage: "calendar")
                                    .font(AppFont.regular(11))
                                    .foregroundStyle(AppTheme.captionOnGlass)
                                    .labelStyle(.titleAndIcon)
                                    .lineLimit(1)
                            }

                            if let locationText = group.locationText {
                                Label(locationText, systemImage: "mappin.and.ellipse")
                                    .font(AppFont.regular(11))
                                    .foregroundStyle(AppTheme.captionOnGlass)
                                    .labelStyle(.titleAndIcon)
                                    .lineLimit(2)
                            }
                        }

                        Spacer(minLength: 8)

                        Text("\(Int(group.progress * 100))%")
                            .font(AppFont.semibold(15))
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.titleOnGlass)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.inkMuted(0.35))
                            .padding(.top, 4)
                    }

                    ProgressBar(progress: group.progress)
                        .frame(height: 6)

                    HStack {
                        Text(L10n.Checklist.tasksCompleted(group.doneCount, group.tasks.count))
                            .font(AppFont.medium(12))
                            .foregroundStyle(AppTheme.captionOnGlass)
                        Spacer()
                    }
                }
                .padding(14)
                .premiumListRow(cornerRadius: 20)
            }
            .buttonStyle(.plain)

        case .task(_, let task):
            Button {
                runPremiumOrPaywall {
                    selectedTask = task
                }
            } label: {
                TaskRow(task: task)
                    .equatable()
            }
            .buttonStyle(.plain)

        case .showMore(let group, let showingAll):
            Button {
                if showingAll {
                    showAllSections.remove(group.id)
                } else {
                    showAllSections.insert(group.id)
                }
            } label: {
                HStack(spacing: 6) {
                    Text(showingAll ? L10n.Checklist.showLess : L10n.Checklist.showAll(group.tasks.count))
                    Image(systemName: showingAll ? "chevron.up" : "chevron.down")
                }
                .font(AppFont.semibold(13))
                .foregroundStyle(AppTheme.mutedOnBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

        case .addTask(let groupId):
            Button {
                runPremiumOrPaywall {
                    addTaskPreferredEventId = groupId
                    showAddTaskSheet = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(L10n.Checklist.addTask)
                        .font(AppFont.semibold(13))
                    Spacer()
                }
                .foregroundStyle(AppTheme.titleOnBackground)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppTheme.surface.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            AppTheme.mutedOnBackground.opacity(0.85),
                            style: StrokeStyle(lineWidth: 1.2, dash: [5, 4])
                        )
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func buildGroups() -> [ChecklistGroup] {
        var result: [ChecklistGroup] = events.map { event in
            let eventTasks = tasks
                .filter { $0.weddingEventId == event.id }
                .sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
            return ChecklistGroup(
                id: event.id,
                title: event.jenisLabel ?? event.jenisAcara.capitalized,
                iconName: ChecklistGroup.icon(for: event.jenisAcara),
                dateText: event.tglAcara
                    .flatMap { DateFormatter.calendarDate(from: $0) }
                    .map { DateFormatter.displayLocaleDate($0) }
                    ?? L10n.More.dateNotSet,
                locationText: {
                    let loc = event.lokasiAcara?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    return loc.isEmpty ? L10n.More.locationNotSet : loc
                }(),
                tasks: eventTasks
            )
        }

        let orphanTasks = tasks.filter { task in
            task.weddingEventId == nil || !events.contains { $0.id == task.weddingEventId }
        }
        if !orphanTasks.isEmpty {
            result.append(ChecklistGroup(id: -1, title: L10n.Checklist.otherGroup, iconName: "sparkles", tasks: orphanTasks))
        }

        return result
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        lastLoadAt = Date()

        do {
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")
            async let taskEnvelope: Envelope<[PreparationTask]> = APIClient.shared.request("customer-preparation-tasks")
            async let sectionEnvelope: Envelope<[PreparationSection]> = APIClient.shared.request("customer-preparation-sections")

            // Await all first so a premium/network failure cannot leave events
            // populated with an empty task list ("0 of 0 tasks").
            let loadedEvents = try await eventEnvelope.data
            let loadedTasks = try await taskEnvelope.data
            let loadedSections = try await sectionEnvelope.data

            events = loadedEvents
            tasks = loadedTasks
            sections = loadedSections
            recomputeChecklistCaches()

            if let first = groups.first {
                expandedSections.insert(first.id)
            }
        } catch {
            // Server rejected Pro checklist (local StoreKit entitlement ≠ server is_premium).
            if error.premiumRequired {
                premium.markServerEntitlementMissing()
                await loadPreview()
                return
            }
            errorMessage = error.localizedDescription
        }
    }

    /// Preview content behind the Pro lock, so the page still feels scrollable.
    private func loadPreview() async {
        errorMessage = nil
        if let envelope: Envelope<[WeddingEvent]> = try? await APIClient.shared.request("wedding-events"),
           !envelope.data.isEmpty {
            events = envelope.data
        } else {
            events = Self.previewEvents
        }
        tasks = Self.previewTasks(for: events)
        sections = []
        expandedSections = Set(events.prefix(2).map(\.id))
        showAllSections = Set(events.map(\.id))
        recomputeChecklistCaches()
    }

    private static var previewEvents: [WeddingEvent] {
        [
            WeddingEvent(id: -101, jenisAcara: "akad", jenisLabel: WeddingEvent.label(for: "akad"), sortOrder: 1, tglAcara: nil, waktuMulai: nil, jamSelesai: nil, lokasiAcara: nil, estimasiTamu: nil, catatan: nil),
            WeddingEvent(id: -102, jenisAcara: "resepsi", jenisLabel: WeddingEvent.label(for: "resepsi"), sortOrder: 2, tglAcara: nil, waktuMulai: nil, jamSelesai: nil, lokasiAcara: nil, estimasiTamu: nil, catatan: nil),
            WeddingEvent(id: -103, jenisAcara: "pengajian", jenisLabel: WeddingEvent.label(for: "pengajian"), sortOrder: 0, tglAcara: nil, waktuMulai: nil, jamSelesai: nil, lokasiAcara: nil, estimasiTamu: nil, catatan: nil),
        ]
    }

    private static func previewTasks(for events: [WeddingEvent]) -> [PreparationTask] {
        let akadId = events.first(where: { $0.jenisAcara.lowercased() == "akad" })?.id
            ?? events.first?.id
        let resepsiId = events.first(where: { $0.jenisAcara.lowercased() == "resepsi" })?.id
            ?? events.dropFirst().first?.id
        let otherId = events.first(where: { $0.jenisAcara.lowercased() == "pengajian" || $0.jenisAcara.lowercased() == "lamaran" })?.id

        var items: [PreparationTask] = [
            PreparationTask(id: -1, weddingEventId: akadId, sectionId: nil, title: "Booking penghulu / petugas akad", label: nil, description: nil, notes: nil, priority: "high", status: "done", dueDate: nil, sortOrder: 1, subTasks: nil, attachments: nil),
            PreparationTask(id: -2, weddingEventId: akadId, sectionId: nil, title: "Fitting baju pengantin", label: nil, description: nil, notes: nil, priority: "medium", status: "in_progress", dueDate: nil, sortOrder: 2, subTasks: nil, attachments: nil),
            PreparationTask(id: -3, weddingEventId: akadId, sectionId: nil, title: "Persiapan mahar & seserahan", label: nil, description: nil, notes: nil, priority: "medium", status: "pending", dueDate: nil, sortOrder: 3, subTasks: nil, attachments: nil),
            PreparationTask(id: -4, weddingEventId: resepsiId, sectionId: nil, title: "Finalisasi vendor dekorasi", label: nil, description: nil, notes: nil, priority: "high", status: "in_progress", dueDate: nil, sortOrder: 1, subTasks: nil, attachments: nil),
            PreparationTask(id: -5, weddingEventId: resepsiId, sectionId: nil, title: "Konfirmasi catering & tasting", label: nil, description: nil, notes: nil, priority: "high", status: "pending", dueDate: nil, sortOrder: 2, subTasks: nil, attachments: nil),
            PreparationTask(id: -6, weddingEventId: resepsiId, sectionId: nil, title: "Susunan acara resepsi", label: nil, description: nil, notes: nil, priority: "medium", status: "pending", dueDate: nil, sortOrder: 3, subTasks: nil, attachments: nil),
            PreparationTask(id: -7, weddingEventId: resepsiId, sectionId: nil, title: "Brief dokumentasi foto & video", label: nil, description: nil, notes: nil, priority: "low", status: "pending", dueDate: nil, sortOrder: 4, subTasks: nil, attachments: nil),
        ]

        if let otherId {
            items.append(
                PreparationTask(id: -8, weddingEventId: otherId, sectionId: nil, title: "Undangan keluarga dekat", label: nil, description: nil, notes: nil, priority: "medium", status: "done", dueDate: nil, sortOrder: 1, subTasks: nil, attachments: nil)
            )
        }

        return items
    }
}

private struct ChecklistGroup: Identifiable, Hashable {
    let id: Int
    let title: String
    let iconName: String
    let dateText: String?
    let locationText: String?
    let tasks: [PreparationTask]
    let doneCount: Int

    var progress: Double {
        tasks.isEmpty ? 0 : Double(doneCount) / Double(tasks.count)
    }

    init(
        id: Int,
        title: String,
        iconName: String,
        dateText: String? = nil,
        locationText: String? = nil,
        tasks: [PreparationTask]
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.dateText = dateText
        self.locationText = locationText
        self.tasks = tasks
        self.doneCount = tasks.reduce(0) { $0 + ($1.statusValue == .done ? 1 : 0) }
    }

    static func icon(for jenis: String) -> String {
        switch jenis.lowercased() {
        case "akad": return "hands.and.sparkles"
        case "resepsi": return "party.popper"
        case "lamaran": return "heart"
        case "pengajian": return "book"
        default: return "sparkles"
        }
    }
}

private enum ChecklistScrollItem: Identifiable, Hashable {
    case header(ChecklistGroup, isExpanded: Bool)
    case task(groupId: Int, task: PreparationTask)
    case showMore(ChecklistGroup, showingAll: Bool)
    case addTask(groupId: Int)

    var id: String {
        switch self {
        case .header(let group, _):
            return "header-\(group.id)"
        case .task(let groupId, let task):
            return "task-\(groupId)-\(task.id)"
        case .showMore(let group, _):
            return "more-\(group.id)"
        case .addTask(let groupId):
            return "add-\(groupId)"
        }
    }
}

private struct TaskRow: View, Equatable {
    let task: PreparationTask

    static func == (lhs: TaskRow, rhs: TaskRow) -> Bool {
        lhs.task.id == rhs.task.id
            && lhs.task.title == rhs.task.title
            && lhs.task.status == rhs.task.status
            && lhs.task.dueDate == rhs.task.dueDate
    }

    var body: some View {
        HStack(spacing: 12) {
            StatusIcon(status: task.statusValue)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.titleOnGlass)
                    .lineLimit(2)

                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.45))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.inkMuted(0.22))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.hairline.opacity(0.7), lineWidth: 1)
        }
    }

    private var subtitle: String {
        switch task.statusValue {
        case .done:
            if let date = task.dueDate, let formatted = Self.displayDate(date) {
                return L10n.Checklist.doneOn(formatted)
            }
            return L10n.Checklist.done
        case .inProgress:
            return L10n.Checklist.running
        case .pending:
            return L10n.Checklist.notStarted
        }
    }

    private static let inputDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let outputDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "d MMM yyyy"
        return f
    }()

    private static func displayDate(_ raw: String) -> String? {
        guard let date = inputDateFormatter.date(from: raw) else { return nil }
        return outputDateFormatter.string(from: date)
    }
}

struct StatusIcon: View {
    let status: PreparationTask.Status

    var body: some View {
        switch status {
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(AppTheme.statusDoneFill)
        case .inProgress:
            Image(systemName: "clock.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(AppTheme.gold, in: Circle())
        case .pending:
            Circle()
                .stroke(AppTheme.inkMuted(0.28), lineWidth: 2)
                .frame(width: 24, height: 24)
        }
    }
}

private struct ChecklistRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.sage.opacity(0.14), lineWidth: 10)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    AppTheme.sageDark,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text(L10n.Checklist.totalProgress)
                    .font(AppFont.medium(8))
                    .foregroundStyle(AppTheme.inkMuted(0.45))

                Text("\(Int(progress * 100))%")
                    .font(AppFont.semibold(24))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.titleOnGlass)

                Text(L10n.Checklist.done)
                    .font(AppFont.medium(9))
                    .foregroundStyle(AppTheme.inkMuted(0.45))
            }
        }
    }
}

private struct ProgressBar: View {
    let progress: Double

    var body: some View {
        Capsule()
            .fill(AppTheme.progressTrack)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.sageDark)
                    .scaleEffect(x: max(0.001, min(1, progress)), y: 1, anchor: .leading)
            }
            .clipShape(Capsule())
    }
}

private struct AddChecklistTaskSheet: View {
    let events: [WeddingEvent]
    var preferredEventId: Int?
    let onCreated: (PreparationTask) -> Void

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var appearance = AppearanceStore.shared

    @State private var title = ""
    @State private var description = ""
    @State private var selectedEventId: Int?
    @State private var priority: PreparationTask.Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var draftSubTasks: [DraftSubTask] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let priorityOptions: [PreparationTask.Priority] = [.high, .medium, .low]

    /// Midnight-only contrast tweaks — other palettes keep the original look.
    private var isMidnight: Bool {
        appearance.colorPalette.prefersLightContentChrome
    }

    private var sheetTitleColor: Color {
        isMidnight ? AppTheme.titleOnBackground : AppTheme.sageDark
    }

    private var sheetMutedColor: Color {
        isMidnight ? AppTheme.mutedOnBackground : AppTheme.ink.opacity(0.55)
    }

    private var sheetLabelColor: Color {
        isMidnight ? AppTheme.mutedOnBackground : AppTheme.ink.opacity(0.6)
    }

    private var sheetHintColor: Color {
        isMidnight ? AppTheme.mutedOnBackground.opacity(0.9) : AppTheme.ink.opacity(0.4)
    }

    private var fieldTextColor: Color {
        isMidnight ? AppTheme.ink : AppTheme.ink
    }

    private var placeholderColor: Color {
        isMidnight ? AppTheme.ink.opacity(0.45) : AppTheme.ink.opacity(0.35)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedEventId != nil
            && !isSaving
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if isMidnight {
                    AppTheme.background
                        .ignoresSafeArea()
                } else {
                    LuxuryWeddingBackground()
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Checklist.addTaskTitle)
                                .font(AppFont.serifSemibold(24))
                                .foregroundStyle(sheetTitleColor)
                            Text(L10n.Checklist.addTaskSubtitle)
                                .font(AppFont.regular(13))
                                .foregroundStyle(sheetMutedColor)
                        }

                        if events.isEmpty {
                            Text(L10n.Checklist.noEvents)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.peachDark)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .premiumListRow(cornerRadius: 16)
                        } else {
                            fieldGroup(L10n.Checklist.taskTitle) {
                                TextField(
                                    "",
                                    text: $title,
                                    prompt: Text(L10n.Checklist.taskTitlePlaceholder)
                                        .foregroundStyle(placeholderColor),
                                    axis: .vertical
                                )
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(fieldTextColor)
                                    .tint(AppTheme.sageDark)
                                    .textFieldStyle(.plain)
                            }

                            fieldGroup(L10n.Checklist.taskEvent) {
                                Picker(L10n.Checklist.taskEventPlaceholder, selection: $selectedEventId) {
                                    Text(L10n.Checklist.taskEventPlaceholder).tag(Optional<Int>.none)
                                    ForEach(events) { event in
                                        Text(event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara))
                                            .tag(Optional(event.id))
                                    }
                                }
                                .labelsHidden()
                                .tint(AppTheme.sageDark)
                            }

                            prioritySection

                            dueDateSection

                            fieldGroup(L10n.Checklist.taskDescription) {
                                TextField(
                                    "",
                                    text: $description,
                                    prompt: Text(L10n.Checklist.taskDescriptionPlaceholder)
                                        .foregroundStyle(placeholderColor),
                                    axis: .vertical
                                )
                                    .font(AppFont.regular(14))
                                    .foregroundStyle(fieldTextColor)
                                    .tint(AppTheme.sageDark)
                                    .lineLimit(3 ... 8)
                            }

                            subTasksSection
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.peachDark)
                        }

                        Button {
                            save()
                        } label: {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(L10n.Checklist.taskSave)
                                        .font(AppFont.semibold(16))
                                }
                            }
                            .foregroundStyle(AppTheme.primaryActionForeground(enabled: canSave))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                AppTheme.primaryActionFill(enabled: canSave),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                    }
                    .padding(20)
                    .padding(.bottom, 12)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                        .foregroundStyle(isMidnight ? AppTheme.mutedOnBackground : AppTheme.ink.opacity(0.7))
                }
            }
            .onAppear {
                if selectedEventId == nil {
                    selectedEventId = preferredEventId ?? events.first?.id
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Checklist.taskPriority)
                .font(AppFont.medium(13))
                .foregroundStyle(sheetLabelColor)

            HStack(spacing: 10) {
                ForEach(priorityOptions, id: \.self) { option in
                    let isSelected = option == priority
                    let style = PriorityStyle(priority: option)
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { priority = option }
                    } label: {
                        Text(style.label)
                            .font(AppFont.medium(13))
                            .foregroundStyle(isSelected ? .white : style.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(style.color)
                                    : AnyShapeStyle(style.color.opacity(isMidnight ? 0.22 : 0.12)),
                                in: Capsule()
                            )
                            .overlay {
                                if isMidnight && !isSelected {
                                    Capsule()
                                        .stroke(style.color.opacity(0.65), lineWidth: 1)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $hasDueDate.animation()) {
                Text(L10n.Checklist.taskDueDate)
                    .font(AppFont.medium(13))
                    .foregroundStyle(isMidnight ? AppTheme.ink.opacity(0.78) : AppTheme.ink.opacity(0.6))
            }
            .tint(AppTheme.sageDark)

            if hasDueDate {
                DatePicker("", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(AppTheme.sageDark)
                    .environment(\.locale, Locale(identifier: "id_ID"))
            }
        }
        .padding(16)
        .background(inputFieldBackground(cornerRadius: 16))
    }

    private var subTasksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Checklist.taskSubTasks)
                    .font(AppFont.medium(13))
                    .foregroundStyle(sheetLabelColor)
                Text(L10n.Checklist.taskSubTasksHint)
                    .font(AppFont.regular(11))
                    .foregroundStyle(sheetHintColor)
            }

            VStack(spacing: 10) {
                ForEach($draftSubTasks) { $item in
                    HStack(spacing: 10) {
                        Image(systemName: "circle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.sage.opacity(0.55))

                        TextField(
                            "",
                            text: $item.title,
                            prompt: Text(L10n.Checklist.taskSubTaskPlaceholder)
                                .foregroundStyle(placeholderColor)
                        )
                            .font(AppFont.medium(14))
                            .foregroundStyle(fieldTextColor)
                            .tint(AppTheme.sageDark)
                            .textFieldStyle(.plain)

                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                draftSubTasks.removeAll { $0.id == item.id }
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(AppTheme.ink.opacity(isMidnight ? 0.4 : 0.28))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(inputFieldBackground(cornerRadius: 14))
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        draftSubTasks.append(DraftSubTask())
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(L10n.Checklist.taskAddSubTask)
                            .font(AppFont.semibold(13))
                        Spacer()
                    }
                    .foregroundStyle(isMidnight ? AppTheme.titleOnBackground : AppTheme.sageDark.opacity(0.78))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isMidnight ? AppTheme.mutedOnBackground.opacity(0.85) : AppTheme.sage.opacity(0.3),
                                style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isMidnight ? AppTheme.surface.opacity(0.14) : AppTheme.surface.opacity(0.55))
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func fieldGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.medium(13))
                .foregroundStyle(sheetLabelColor)

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(inputFieldBackground(cornerRadius: 16))
        }
    }

    private func inputFieldBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.surface.opacity(isMidnight ? 1 : 0.96))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isMidnight ? AppTheme.hairline : Color.white.opacity(0.65),
                        lineWidth: 1
                    )
            }
            .shadow(color: AppTheme.sageDark.opacity(isMidnight ? 0 : 0.05), radius: 8, y: 3)
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let eventId = selectedEventId, !trimmedTitle.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        var payload: [String: Any] = [
            "title": trimmedTitle,
            "priority": priority.rawValue,
            "status": PreparationTask.Status.pending.rawValue,
            "wedding_event_id": eventId,
        ]

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDescription.isEmpty {
            payload["description"] = trimmedDescription
        }

        if hasDueDate {
            payload["due_date"] = Self.formatDate(dueDate)
        }

        let subTaskPayload = draftSubTasks
            .map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { ["title": $0] }

        if !subTaskPayload.isEmpty {
            payload["sub_tasks"] = subTaskPayload
        }

        Task {
            do {
                let envelope: Envelope<PreparationTask> = try await APIClient.shared.request(
                    "customer-preparation-tasks",
                    method: "POST",
                    json: payload
                )
                onCreated(envelope.data)
                dismiss()
            } catch {
                errorMessage = error.userFacingMessage.isEmpty
                    ? L10n.Checklist.taskCreateError
                    : error.userFacingMessage
                isSaving = false
            }
        }
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

private struct DraftSubTask: Identifiable {
    let id = UUID()
    var title = ""
}

struct PreparationSection: Decodable, Identifiable {
    let id: Int
    let title: String
    let icon: String?
    let sortOrder: Int?
}


