import SwiftUI

struct TaskDetailView: View {
    let taskId: Int
    let eventTitle: String
    let sectionTitle: String?
    let createdAt: String?
    let attachments: [PreparationTaskAttachment]
    let onChangeStatus: (PreparationTask.Status) -> Void
    let onSubTasksUpdated: (Int, PreparationTask.Status, [PreparationSubTask]) -> Void
    let onTaskEdited: (Int, TaskEditResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var status: PreparationTask.Status
    @State private var subTasks: [PreparationSubTask]
    @State private var taskTitle: String
    @State private var descriptionText: String?
    @State private var notesText: String?
    @State private var priority: PreparationTask.Priority
    @State private var dueDate: String?
    @State private var showEditSheet = false

    init(
        task: PreparationTask,
        eventTitle: String,
        sectionTitle: String?,
        onChangeStatus: @escaping (PreparationTask.Status) -> Void,
        onSubTasksUpdated: @escaping (Int, PreparationTask.Status, [PreparationSubTask]) -> Void,
        onTaskEdited: @escaping (Int, TaskEditResult) -> Void
    ) {
        taskId = task.id
        self.eventTitle = eventTitle
        self.sectionTitle = sectionTitle
        createdAt = task.createdAt
        attachments = task.attachments ?? []
        self.onChangeStatus = onChangeStatus
        self.onSubTasksUpdated = onSubTasksUpdated
        self.onTaskEdited = onTaskEdited
        _status = State(initialValue: task.statusValue)
        _subTasks = State(initialValue: task.subTasks ?? [])
        _taskTitle = State(initialValue: task.title)
        _descriptionText = State(initialValue: task.description)
        _notesText = State(initialValue: task.notes)
        _priority = State(initialValue: task.priorityValue)
        _dueDate = State(initialValue: task.dueDate)
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    infoCard
                    if hasDescription { descriptionSection }
                    if hasSubTasks { subTasksSection }
                    if hasNotes { notesSection }
                    if hasAttachments { attachmentsSection }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .safeAreaInset(edge: .bottom) { bottomBar }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            TaskEditSheet(
                taskId: taskId,
                title: taskTitle,
                description: descriptionText,
                notes: notesText,
                priority: priority,
                dueDate: dueDate,
                onSaved: { result in applyEdit(result) }
            )
        }
    }

    private func applyEdit(_ result: TaskEditResult) {
        taskTitle = result.title
        descriptionText = result.description
        notesText = result.notes
        priority = result.priority
        dueDate = result.dueDate
        onTaskEdited(taskId, result)
    }

    private var hasDescription: Bool {
        guard let descriptionText else { return false }
        return !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasSubTasks: Bool { !subTasks.isEmpty }
    private var hasNotes: Bool {
        guard let notesText else { return false }
        return !notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasAttachments: Bool { !attachments.isEmpty }

    private var sortedSubTasks: [PreparationSubTask] {
        subTasks.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
    }

    private var priorityStyle: PriorityStyle {
        PriorityStyle(priority: priority)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.8))
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 10) {
                    Button {
                        showEditSheet = true
                    } label: {
                        circleIcon("pencil")
                    }
                    .buttonStyle(.plain)

                    circleIcon("ellipsis")
                }
            }

            Text(L10n.Checklist.detailTitle)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text(L10n.Checklist.detailSubtitle)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    private func circleIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(AppTheme.ink.opacity(0.7))
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(Color.white.opacity(0.78))
                    .background(.ultraThinMaterial, in: Circle())
            }
            .overlay {
                Circle()
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 10, y: 5)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                StatusIcon(status: status)

                VStack(alignment: .leading, spacing: 3) {
                    Text(taskTitle)
                        .font(AppFont.bold(14))
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(statusSubtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                }

                Spacer(minLength: 8)

                statusBadge
            }

            HStack(alignment: .top, spacing: 12) {
                infoCell(icon: "hourglass", label: L10n.Checklist.detailCategory, value: eventTitle, tint: AppTheme.sageDark)
                infoCell(icon: "flag.fill", label: L10n.Checklist.detailPriority, value: priorityStyle.label, tint: priorityStyle.color, valueTint: priorityStyle.color)
            }

            HStack(alignment: .top, spacing: 12) {
                infoCell(icon: "calendar", label: L10n.Checklist.detailCreated, value: Self.displayDate(fromISO: createdAt) ?? "-", tint: AppTheme.sageDark)
                infoCell(icon: "calendar", label: L10n.Checklist.detailDue, value: Self.displayDate(dueDate) ?? "-", tint: AppTheme.sageDark)
            }
        }
        .padding(18)
        .premiumGlassCard(cornerRadius: 22)
    }

    private var statusBadge: some View {
        Text(Self.label(for: status))
            .font(AppFont.medium(11))
            .foregroundStyle(status == .pending ? AppTheme.ink.opacity(0.6) : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusBadgeColor, in: Capsule())
    }

    private var statusBadgeColor: Color {
        switch status {
        case .done: return AppTheme.sageDark
        case .inProgress: return AppTheme.gold
        case .pending: return AppTheme.mist
        }
    }

    private func infoCell(icon: String, label: String, value: String, tint: Color, valueTint: Color = AppTheme.ink) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                Text(value)
                    .font(AppFont.medium(13))
                    .foregroundStyle(valueTint)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Deskripsi

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitleText(L10n.Common.description)

            Text(descriptionText ?? "")
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Sub Tugas

    private var subTasksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitleText(L10n.Checklist.taskSubTasks)

            VStack(spacing: 12) {
                ForEach(sortedSubTasks) { sub in
                    Button {
                        toggleSubTask(sub)
                    } label: {
                        HStack(spacing: 12) {
                            StatusIcon(status: sub.statusValue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(sub.title)
                                    .font(AppFont.medium(14))
                                    .foregroundStyle(AppTheme.ink)
                                Text(subTaskSubtitle(sub))
                                    .font(AppFont.regular(11))
                                    .foregroundStyle(sub.statusValue == .inProgress ? AppTheme.gold : AppTheme.ink.opacity(0.45))
                            }

                            Spacer()

                            if sub.statusValue == .done {
                                Text(L10n.Checklist.statusDone)
                                    .font(AppFont.medium(10))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.sageDark, in: Capsule())
                            } else if let trailing = subTaskTrailingText(sub) {
                                Text(trailing)
                                    .font(AppFont.regular(11))
                                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .premiumGlassCard(cornerRadius: 20)
        }
    }

    // MARK: - Catatan

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitleText(L10n.Common.notes)

            Text(notesText ?? "")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.lightSage.opacity(0.5), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Lampiran

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitleText(L10n.Checklist.attachments)

            VStack(spacing: 10) {
                ForEach(attachments) { attachment in
                    attachmentRow(attachment)
                }
            }
        }
    }

    private func attachmentRow(_ attachment: PreparationTaskAttachment) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.peachDark)
                .frame(width: 42, height: 42)
                .background(AppTheme.softPeach.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.fileName)
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Text(attachmentMeta(attachment))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer()

            if let urlString = attachment.url, let url = URL(string: urlString) {
                Link(destination: url) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                }
            }
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        Button {
            let next: PreparationTask.Status = status == .done ? .pending : .done
            withAnimation(.easeInOut(duration: 0.2)) { status = next }
            onChangeStatus(next)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: status == .done ? "arrow.uturn.backward.circle" : "checkmark.circle")
                    .font(.system(size: 17, weight: .semibold))
                Text(status == .done ? L10n.Checklist.markUndone : L10n.Checklist.markDone)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers

    private func sectionTitleText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 19, weight: .semibold, design: .serif))
            .foregroundStyle(AppTheme.sageDark)
    }

    private var statusSubtitle: String {
        switch status {
        case .done:
            if let date = Self.displayDate(dueDate) {
                return L10n.Checklist.statusDoneOn(date)
            }
            return L10n.Checklist.statusDone
        case .inProgress: return L10n.Checklist.statusInProgress
        case .pending: return L10n.Checklist.statusPending
        }
    }

    private func toggleSubTask(_ sub: PreparationSubTask) {
        guard let index = subTasks.firstIndex(where: { $0.id == sub.id }) else { return }

        let previous = subTasks[index]
        let next = PreparationTask.nextStatus(after: sub.statusValue)
        subTasks[index].status = next.rawValue
        subTasks[index].completedAt = next == .done ? Self.todayString() : nil
        syncParentStatusFromSubTasks()

        Task {
            do {
                let response: SubTaskToggleResponse = try await APIClient.shared.request(
                    "customer-preparation-sub-tasks/\(sub.id)/toggle",
                    method: "PATCH"
                )

                if let updatedIndex = subTasks.firstIndex(where: { $0.id == sub.id }) {
                    subTasks[updatedIndex] = response.data
                }

                if let parentStatus = PreparationTask.Status(rawValue: response.parentTaskStatus) {
                    status = parentStatus
                }

                publishTaskUpdate()
            } catch {
                if let revertIndex = subTasks.firstIndex(where: { $0.id == sub.id }) {
                    subTasks[revertIndex] = previous
                }
                syncParentStatusFromSubTasks()
            }
        }
    }

    private func syncParentStatusFromSubTasks() {
        guard !subTasks.isEmpty else { return }
        status = PreparationTask.status(from: subTasks)
        publishTaskUpdate()
    }

    private func publishTaskUpdate() {
        onSubTasksUpdated(taskId, status, subTasks)
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func subTaskSubtitle(_ sub: PreparationSubTask) -> String {
        switch sub.statusValue {
        case .done:
            if let date = Self.displayDate(sub.completedAt) {
                return L10n.Checklist.statusDoneOn(date)
            }
            return L10n.Checklist.statusDone
        case .inProgress:
            return L10n.Checklist.statusInProgress
        case .pending:
            return L10n.Checklist.statusPending
        }
    }

    private func subTaskTrailingText(_ sub: PreparationSubTask) -> String? {
        switch sub.statusValue {
        case .done:
            return nil
        case .inProgress, .pending:
            return Self.displayDate(sub.dueDate) ?? "–"
        }
    }

    private func attachmentMeta(_ attachment: PreparationTaskAttachment) -> String {
        let size = Self.formatFileSize(attachment.fileSize ?? 0)
        let uploaded = Self.displayDate(fromISO: attachment.createdAt) ?? "-"
        return L10n.Checklist.uploadedMeta(size, uploaded)
    }

    private static func formatFileSize(_ bytes: Int) -> String {
        let mb = Double(bytes) / 1_048_576
        if mb >= 0.1 {
            return String(format: "%.1f MB", mb)
        }
        let kb = Double(bytes) / 1024
        return String(format: "%.0f KB", max(kb, 1))
    }

    private static func label(for status: PreparationTask.Status) -> String {
        switch status {
        case .done: return L10n.Checklist.statusDone
        case .inProgress: return L10n.Checklist.statusInProgress
        case .pending: return L10n.Checklist.statusPending
        }
    }

    private static func displayDate(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd"
        guard let date = input.date(from: raw) else { return nil }
        return format(date)
    }

    private static func displayDate(fromISO raw: String?) -> String? {
        guard let raw else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: raw) {
            return format(date)
        }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: raw) {
            return format(date)
        }
        return displayDate(String(raw.prefix(10)))
    }

    private static func format(_ date: Date) -> String {
        let output = DateFormatter()
        output.locale = Locale(identifier: "id_ID")
        output.dateFormat = "d MMM yyyy"
        return output.string(from: date)
    }
}

struct PriorityStyle {
    let label: String
    let color: Color

    init(priority: PreparationTask.Priority) {
        label = priority.label
        switch priority {
        case .high: color = AppTheme.peachDark
        case .medium: color = AppTheme.gold
        case .low: color = AppTheme.sageDark
        }
    }
}

private struct TaskEditSheet: View {
    let taskId: Int
    let onSaved: (TaskEditResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var notes: String
    @State private var priority: PreparationTask.Priority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let priorityOptions: [PreparationTask.Priority] = [.high, .medium, .low]

    init(
        taskId: Int,
        title: String,
        description: String?,
        notes: String?,
        priority: PreparationTask.Priority,
        dueDate: String?,
        onSaved: @escaping (TaskEditResult) -> Void
    ) {
        self.taskId = taskId
        self.onSaved = onSaved
        _title = State(initialValue: title)
        _description = State(initialValue: description ?? "")
        _notes = State(initialValue: notes ?? "")
        _priority = State(initialValue: priority)
        _hasDueDate = State(initialValue: dueDate != nil)
        _dueDate = State(initialValue: Self.parseDate(dueDate) ?? Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        fieldGroup(L10n.Checklist.taskTitle) {
                            TextField(L10n.Checklist.taskTitlePlaceholder, text: $title, axis: .vertical)
                                .font(AppFont.medium(15))
                                .foregroundStyle(AppTheme.ink)
                                .tint(AppTheme.sageDark)
                                .textFieldStyle(.plain)
                        }

                        prioritySection

                        dueDateSection

                        fieldGroup(L10n.Common.description) {
                            TextField(L10n.Checklist.taskDescriptionPlaceholder, text: $description, axis: .vertical)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink)
                                .tint(AppTheme.sageDark)
                                .lineLimit(3 ... 8)
                        }

                        fieldGroup(L10n.Common.notes) {
                            TextField(L10n.Common.notes, text: $notes, axis: .vertical)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink)
                                .tint(AppTheme.sageDark)
                                .lineLimit(2 ... 6)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.peachDark)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Checklist.editTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) { save() }
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.sageDark)
                        .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
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
                    .environment(\.locale, Locale(identifier: "id_ID"))
            }
        }
        .padding(16)
        .background(editFieldBackground(cornerRadius: 16))
    }

    private func fieldGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.6))

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(editFieldBackground(cornerRadius: 16))
        }
    }

    private func editFieldBackground(cornerRadius: CGFloat) -> some View {
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
        guard !trimmedTitle.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let dueDateString = hasDueDate ? Self.formatDate(dueDate) : nil

        let json: [String: Any] = [
            "title": trimmedTitle,
            "priority": priority.rawValue,
            "description": trimmedDescription,
            "notes": trimmedNotes,
            "due_date": dueDateString ?? NSNull(),
        ]

        Task {
            do {
                let _: Envelope<PreparationTask> = try await APIClient.shared.request(
                    "customer-preparation-tasks/\(taskId)",
                    method: "PUT",
                    json: json
                )

                onSaved(TaskEditResult(
                    title: trimmedTitle,
                    description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                    notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                    priority: priority,
                    dueDate: dueDateString
                ))
                dismiss()
            } catch {
                errorMessage = L10n.Checklist.taskSaveError
                isSaving = false
            }
        }
    }

    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: raw)
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
