import SwiftUI

struct ChecklistView: View {
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
                    .padding(.bottom, 20)
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
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
        }
    }

    private func eventTitle(for task: PreparationTask) -> String {
        if let event = events.first(where: { $0.id == task.weddingEventId }) {
            return event.jenisLabel ?? event.jenisAcara.capitalized
        }
        return allGroups.first(where: { $0.tasks.contains(where: { $0.id == task.id }) })?.title ?? "Persiapan"
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
                    .lineSpacing(1)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isSearching = true }
                } label: {
                    circleButton("magnifyingglass")
                }
                .buttonStyle(.plain)
                circleButton("slider.horizontal.3")
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
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))

                TextField(L10n.Checklist.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(15))
                    .foregroundStyle(AppTheme.ink)
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.ink.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.18), lineWidth: 1)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSearching = false
                    searchText = ""
                }
            } label: {
                Text(L10n.Common.cancel)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
            }
            .buttonStyle(.plain)
        }
    }

    private func circleButton(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(AppTheme.ink.opacity(0.72))
            .frame(width: 42, height: 42)
            .background(.white.opacity(0.86), in: Circle())
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
    }

    private var summaryCard: some View {
        HStack(spacing: 14) {
            ChecklistRing(progress: overallProgress)
                .frame(width: 104, height: 104)

            HStack(spacing: 0) {
                summaryStat(icon: "checkmark.circle.fill", tint: AppTheme.sageDark, label: L10n.Checklist.done, value: doneTasks)
                summaryStat(icon: "clock.fill", tint: AppTheme.gold, label: L10n.Checklist.running, value: inProgressTasks)
                summaryStat(icon: "circle", tint: AppTheme.mist, label: L10n.Checklist.notStarted, value: pendingTasks)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    private func summaryStat(icon: String, tint: Color, label: String, value: Int) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(tint)

            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("\(value)")
                .font(AppFont.medium(20))
                .foregroundStyle(AppTheme.sageDark)

            Text(L10n.Checklist.tasks)
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
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
                            .font(AppFont.medium(13))
                            .foregroundStyle(isSelected ? .white : AppTheme.ink.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                isSelected ? AnyShapeStyle(AppTheme.sageDark) : AnyShapeStyle(AppTheme.lightSage),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
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
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: group.iconName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppTheme.sageDark)
                            .frame(width: 42, height: 42)
                            .background(AppTheme.sage.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Text(group.title)
                            .font(AppFont.medium(17))
                            .foregroundStyle(AppTheme.sageDark)

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.sageDark)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.ink.opacity(0.4))
                    }

                    ProgressBar(progress: progress)
                        .frame(height: 6)

                    HStack {
                        Text(L10n.Checklist.tasksCompleted(doneCount, group.tasks.count))
                            .font(AppFont.regular(12))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                        Spacer()
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                LazyVStack(spacing: 10) {
                    ForEach(visibleTasks) { task in
                        Button {
                            selectedTask = task
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
                                Text(showAll ? "Tampilkan lebih sedikit" : "Lihat semua (\(group.tasks.count))")
                                Image(systemName: showAll ? "chevron.up" : "chevron.down")
                            }
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 14)
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 14, y: 7)
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
            result.append(ChecklistGroup(id: -1, title: "Lainnya", iconName: "sparkles", tasks: orphanTasks))
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
            events = try await eventEnvelope.data
            tasks = try await taskEnvelope.data
            sections = try await sectionEnvelope.data

            if let first = groups.first {
                expandedSections.insert(first.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
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

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)

                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(AppTheme.lightSage.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var subtitle: String {
        switch task.statusValue {
        case .done:
            if let date = task.dueDate, let formatted = Self.displayDate(date) {
                return "Selesai pada \(formatted)"
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
                .foregroundStyle(.white, AppTheme.sageDark)
        case .inProgress:
            Image(systemName: "clock.fill")
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(AppTheme.gold, in: Circle())
        case .pending:
            Circle()
                .stroke(AppTheme.ink.opacity(0.25), lineWidth: 2)
                .frame(width: 24, height: 24)
        }
    }
}

private struct ChecklistRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.mist, lineWidth: 11)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppTheme.sageDark, style: StrokeStyle(lineWidth: 11, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text(L10n.Checklist.totalProgress)
                    .font(AppFont.regular(8))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))

                Text("\(Int(progress * 100))%")
                    .font(AppFont.medium(26))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Checklist.done)
                    .font(AppFont.regular(9))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
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
                    .fill(AppTheme.mist)

                Capsule()
                    .fill(AppTheme.sageDark)
                    .frame(width: max(0, min(1, progress)) * proxy.size.width)
            }
        }
    }
}

struct PreparationSection: Decodable, Identifiable {
    let id: Int
    let title: String
    let icon: String?
    let sortOrder: Int?
}


