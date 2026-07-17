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
    @State private var showAddTaskSheet = false
    @State private var addTaskPreferredEventId: Int?
    @State private var showPaywall = false

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

    private var sectionTitles: [Int: String] {
        Dictionary(sections.map { ($0.id, $0.title) }, uniquingKeysWith: { first, _ in first })
    }

    private var groups: [ChecklistGroup] {
        var source = buildGroups()

        if selectedFilter != L10n.Common.all {
            source = source.filter { $0.title == selectedFilter }
        }

        if !searchText.isEmpty {
            source = source.compactMap { group in
                let matched = group.tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                guard !matched.isEmpty else { return nil }
                return ChecklistGroup(id: group.id, title: group.title, iconName: group.iconName, tasks: matched)
            }
        }

        return source
    }

    private var allGroups: [ChecklistGroup] {
        buildGroups()
    }

    private var filterOptions: [String] {
        var options = [L10n.Common.all]
        options.append(contentsOf: allGroups.map(\.title))
        return options
    }

    private var totalTasks: Int { allGroups.reduce(0) { $0 + $1.tasks.count } }
    private var doneTasks: Int { allGroups.reduce(0) { $0 + $1.tasks.filter { $0.statusValue == .done }.count } }
    private var inProgressTasks: Int { allGroups.reduce(0) { $0 + $1.tasks.filter { $0.statusValue == .inProgress }.count } }
    private var pendingTasks: Int { allGroups.reduce(0) { $0 + $1.tasks.filter { $0.statusValue == .pending }.count } }
    private var overallProgress: Double { totalTasks == 0 ? 0 : Double(doneTasks) / Double(totalTasks) }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if isSearching { searchBar }
                        summaryCard
                        if !isSearching { filterChips }
                        checklistContent
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .blur(radius: isPremium ? 0 : 2.5)
                .opacity(isPremium ? 1 : 0.82)

                if !isPremium {
                    PremiumLockedOverlay {
                        showPaywall = true
                    }
                    .padding(.horizontal, 24)
                }
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
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Checklist.subtitle)
                    .lineSpacing(2)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.gold)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button {
                    runPremiumOrPaywall {
                        withAnimation(.easeInOut(duration: 0.2)) { isSearching = true }
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
            .premiumGlassCard(cornerRadius: 16)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSearching = false
                    searchText = ""
                }
            } label: {
                Text(L10n.Common.cancel)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.sageDark)
            }
            .buttonStyle(.plain)
        }
    }

    private func circleButton(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(AppTheme.iconOnChrome)
            .frame(width: 44, height: 44)
            .background {
                Circle()
                    .fill(AppTheme.chrome)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .overlay {
                Circle()
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
    }

    private var summaryCard: some View {
        HStack(spacing: 16) {
            ChecklistRing(progress: overallProgress)
                .frame(width: 108, height: 108)

            HStack(spacing: 0) {
                summaryStat(icon: "checkmark.circle.fill", tint: AppTheme.sageDark, label: L10n.Checklist.done, value: doneTasks)
                summaryStat(icon: "clock.fill", tint: AppTheme.gold, label: L10n.Checklist.running, value: inProgressTasks)
                summaryStat(icon: "circle", tint: AppTheme.statusMuted, label: L10n.Checklist.notStarted, value: pendingTasks)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .premiumGlassCard(cornerRadius: 32)
    }

    private func summaryStat(icon: String, tint: Color, label: String, value: Int) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .shadow(color: tint.opacity(0.25), radius: 4, y: 1)

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
                        withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = option }
                    } label: {
                        Text(option)
                            .font(AppFont.semibold(13))
                            .foregroundStyle(isSelected ? .white : AppTheme.sageMuted(0.72))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                if isSelected {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.sage, AppTheme.sageDark],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                } else {
                                    Capsule()
                                        .fill(AppTheme.chipIdleFill)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                            .overlay {
                                Capsule()
                                    .stroke(
                                        isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.55),
                                        lineWidth: 1
                                    )
                            }
                            .shadow(color: AppTheme.sageDark.opacity(isSelected ? 0.14 : 0.05), radius: isSelected ? 10 : 6, y: 3)
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
            ForEach(groups) { group in
                sectionCard(group)
            }
        }
    }

    private func sectionCard(_ group: ChecklistGroup) -> some View {
        let isExpanded = expandedSections.contains(group.id) || isSearching
        let showAll = showAllSections.contains(group.id)
        let doneCount = group.tasks.filter { $0.statusValue == .done }.count
        let progress = group.tasks.isEmpty ? 0 : Double(doneCount) / Double(group.tasks.count)
        let visibleTasks = showAll ? group.tasks : Array(group.tasks.prefix(5))

        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if isExpanded { expandedSections.remove(group.id) } else { expandedSections.insert(group.id) }
                }
            } label: {
                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        Image(systemName: group.iconName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.iconOnChip)
                            .frame(width: 44, height: 44)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppTheme.iconChipFill)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                            }
                            .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 3)

                        Text(group.title)
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(AppTheme.titleOnGlass)

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(AppFont.semibold(15))
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.titleOnGlass)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.inkMuted(0.35))
                    }

                    ProgressBar(progress: progress)
                        .frame(height: 7)

                    HStack {
                        Text(L10n.Checklist.tasksCompleted(doneCount, group.tasks.count))
                            .font(AppFont.medium(12))
                            .foregroundStyle(AppTheme.captionOnGlass)
                        Spacer()
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                LazyVStack(spacing: 10) {
                    ForEach(visibleTasks) { task in
                        Button {
                            runPremiumOrPaywall {
                                selectedTask = task
                            }
                        } label: {
                            TaskRow(task: task)
                        }
                        .buttonStyle(.plain)
                    }

                    if group.tasks.count > 5 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if showAll { showAllSections.remove(group.id) } else { showAllSections.insert(group.id) }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(showAll ? L10n.Checklist.showLess : L10n.Checklist.showAll(group.tasks.count))
                                Image(systemName: showAll ? "chevron.up" : "chevron.down")
                            }
                            .font(AppFont.semibold(13))
                            .foregroundStyle(AppTheme.sageMuted(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }

                    if group.id > 0 {
                        Button {
                            runPremiumOrPaywall {
                                addTaskPreferredEventId = group.id
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
                            .foregroundStyle(AppTheme.sageMuted(0.72))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppTheme.sage.opacity(0.28), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(AppTheme.nestedGlassFill)
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
            }
        }
        .padding(18)
        .premiumGlassCard(cornerRadius: 28)
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

    /// Preview content behind the Pro lock (blurred), so the page still feels scrollable.
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

private struct ChecklistGroup: Identifiable {
    let id: Int
    let title: String
    let iconName: String
    let tasks: [PreparationTask]

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

private struct TaskRow: View {
    let task: PreparationTask

    var body: some View {
        HStack(spacing: 12) {
            StatusIcon(status: task.statusValue)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.titleOnGlass)

                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.45))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.inkMuted(0.22))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.nestedGlassFill)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.04), radius: 8, y: 3)
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
                .foregroundStyle(.white, AppTheme.statusDoneFill)
                .shadow(color: AppTheme.sage.opacity(0.25), radius: 4, y: 1)
        case .inProgress:
            Image(systemName: "clock.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(
                    LinearGradient(colors: [AppTheme.gold, AppTheme.goldDark], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Circle()
                )
                .shadow(color: AppTheme.gold.opacity(0.3), radius: 4, y: 1)
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
                .stroke(AppTheme.sage.opacity(0.14), lineWidth: 11)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [AppTheme.sage, AppTheme.gold, AppTheme.sageDark],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 11, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AppTheme.sage.opacity(0.25), radius: 6, y: 2)

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
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.progressTrack)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.sage, AppTheme.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, progress)) * proxy.size.width)
                    .shadow(color: AppTheme.sage.opacity(0.2), radius: 3, y: 1)
            }
        }
    }
}

private struct AddChecklistTaskSheet: View {
    let events: [WeddingEvent]
    var preferredEventId: Int?
    let onCreated: (PreparationTask) -> Void

    @Environment(\.dismiss) private var dismiss

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

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedEventId != nil
            && !isSaving
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Checklist.addTaskTitle)
                                .font(.system(size: 24, weight: .semibold, design: .serif))
                                .foregroundStyle(AppTheme.sageDark)
                            Text(L10n.Checklist.addTaskSubtitle)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.ink.opacity(0.5))
                        }

                        if events.isEmpty {
                            Text(L10n.Checklist.noEvents)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.peachDark)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .premiumGlassCard(cornerRadius: 16)
                        } else {
                            fieldGroup(L10n.Checklist.taskTitle) {
                                TextField(L10n.Checklist.taskTitlePlaceholder, text: $title, axis: .vertical)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.ink)
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
                                TextField(L10n.Checklist.taskDescriptionPlaceholder, text: $description, axis: .vertical)
                                    .font(AppFont.regular(14))
                                    .foregroundStyle(AppTheme.ink)
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
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                canSave ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.4),
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
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
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
                .foregroundStyle(AppTheme.ink.opacity(0.6))

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
                                isSelected ? AnyShapeStyle(style.color) : AnyShapeStyle(style.color.opacity(0.12)),
                                in: Capsule()
                            )
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
                    .foregroundStyle(AppTheme.ink.opacity(0.6))
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
                    .foregroundStyle(AppTheme.ink.opacity(0.6))
                Text(L10n.Checklist.taskSubTasksHint)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
            }

            VStack(spacing: 10) {
                ForEach($draftSubTasks) { $item in
                    HStack(spacing: 10) {
                        Image(systemName: "circle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.sage.opacity(0.55))

                        TextField(L10n.Checklist.taskSubTaskPlaceholder, text: $item.title)
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.ink)
                            .tint(AppTheme.sageDark)
                            .textFieldStyle(.plain)

                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                draftSubTasks.removeAll { $0.id == item.id }
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(AppTheme.ink.opacity(0.28))
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
                    .foregroundStyle(AppTheme.sageDark.opacity(0.78))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.sage.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppTheme.surface.opacity(0.55))
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
                .foregroundStyle(AppTheme.ink.opacity(0.6))

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(inputFieldBackground(cornerRadius: 16))
        }
    }

    private func inputFieldBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.surface.opacity(0.96))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 8, y: 3)
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


