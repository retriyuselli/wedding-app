import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct PaymentScheduleFormView: View {
    let schedule: PaymentSchedule?
    let onSaved: () async -> Void

    var body: some View {
        AddExpenseView(schedule: schedule, onSaved: onSaved)
    }
}

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    let schedule: PaymentSchedule?
    let onSaved: () async -> Void

    @State private var title = ""
    @State private var vendorName = ""
    @State private var category = ""
    @State private var amountText = ""
    @State private var dueDate = Date()
    @State private var selectedWeddingEventId: Int?
    @State private var selectedPaymentMethodId: Int?
    @State private var notes = ""
    @State private var isMarkedPaid = false
    @State private var paymentMethods: [CustomerPaymentMethod] = []
    @State private var weddingEvents: [WeddingEvent] = []
    @State private var selectedProofItem: PhotosPickerItem?
    @State private var proofPreview: UIImage?
    @State private var proofFileData: Data?
    @State private var proofFileName = "proof.jpg"
    @State private var proofMimeType = "image/jpeg"
    @State private var proofRemoteUrl: String?
    @State private var proofSizeError: String?
    @State private var showProofSizeAlert = false
    @State private var suppressProofSelectionReset = false

    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    @State private var showEventPicker = false
    @State private var showPaymentMethodPicker = false
    @State private var showProofViewer = false
    @State private var showProofPicker = false
    @State private var showProofSourceDialog = false
    @State private var showProofFileImporter = false

    @State private var isLoading = false
    @State private var isLoadingMethods = false
    @State private var errorMessage: String?

    private let notesLimit = 200
    private let maxProofFileSize = 1_024 * 1_024
    private var isEditing: Bool { schedule != nil }

    private var selectedCategoryLabel: String {
        category.isEmpty ? L10n.Budget.pickCategory : categoriesStore.label(for: category)
    }

    private var selectedPaymentMethodLabel: String {
        guard let selectedPaymentMethodId,
              let method = paymentMethods.first(where: { $0.id == selectedPaymentMethodId }) else {
            return L10n.Budget.pickPaymentMethod
        }
        return method.displayLabel
    }

    private var selectedEventLabel: String {
        guard let selectedWeddingEventId,
              let event = weddingEvents.first(where: { $0.id == selectedWeddingEventId }) else {
            return L10n.Budget.noEventOptional
        }

        return event.jenisLabel ?? event.jenisAcara.capitalized
    }

    private var formattedDueDate: String {
        DateFormatter.displayLocaleDate(dueDate)
    }

    private var amountPreview: String {
        guard let amount = parsedAmount else { return "Rp 0" }
        return CurrencyFormatter.rupiah(amount)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !category.isEmpty
            && parsedAmount != nil
            && !isLoading
    }

    private var canViewProof: Bool {
        proofPreview != nil || proofRemoteUrl != nil
    }

    private var shouldUseReadOnlyProofDisplay: Bool {
        isEditing && canViewProof && selectedProofItem == nil && proofFileData == nil
    }

    private var proofPickerMatching: PHPickerFilter {
        .images
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    header

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    pickerRow(icon: "square.grid.2x2", title: selectedCategoryLabel, isPlaceholder: category.isEmpty) {
                        showCategoryPicker = true
                    }

                    inputRow(icon: "doc.text") {
                        TextField(L10n.Budget.expenseTitlePlaceholder, text: $title)
                            .font(AppFont.regular(14))
                            .foregroundStyle(AppTheme.ink)
                    }

                    inputRow(icon: "building.2") {
                        TextField(L10n.Budget.vendorOptional, text: $vendorName)
                            .font(AppFont.regular(14))
                            .foregroundStyle(AppTheme.ink)
                    }

                    inputRow(icon: "banknote") {
                        TextField(L10n.Budget.enterAmount, text: $amountText)
                            .font(AppFont.regular(14))
                            .foregroundStyle(AppTheme.ink)
                            .keyboardType(.numberPad)
                            .onChange(of: amountText) { _, newValue in
                                amountText = Self.formatAmountInput(newValue)
                            }
                    } trailing: {
                        Text(amountPreview)
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageDark)
                    }

                    pickerRow(icon: "calendar", title: formattedDueDate, isPlaceholder: false) {
                        showDatePicker = true
                    }

                    if !weddingEvents.isEmpty {
                        pickerRow(
                            icon: "calendar.badge.clock",
                            title: selectedEventLabel,
                            isPlaceholder: selectedWeddingEventId == nil
                        ) {
                            showEventPicker = true
                        }
                    }

                    pickerRow(icon: "wallet.pass", title: selectedPaymentMethodLabel, isPlaceholder: selectedPaymentMethodId == nil) {
                        showPaymentMethodPicker = true
                    }

                    notesSection
                    paymentStatusSection
                    proofSection

                    if isEditing {
                        Button(role: .destructive) {
                            Task { await deleteExpense() }
                        } label: {
                            Label(L10n.Budget.deleteExpense, systemImage: "trash")
                                .font(AppFont.medium(14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { saveButton }
        .task {
            await categoriesStore.loadIfNeeded()
            await loadPaymentMethods()
            await loadWeddingEvents()
            populateIfNeeded()
        }
        .onChange(of: schedule?.id) { _, _ in
            populateIfNeeded()
        }
        .onChange(of: schedule?.amount) { _, _ in
            populateIfNeeded()
        }
        .navigationDestination(isPresented: $showCategoryPicker) {
            ExpenseCategoryPickerView(selection: $category)
        }
        .navigationDestination(isPresented: $showDatePicker) {
            ExpenseDatePickerView(selection: $dueDate)
        }
        .navigationDestination(isPresented: $showEventPicker) {
            ExpenseWeddingEventPickerView(
                events: weddingEvents,
                selection: $selectedWeddingEventId
            )
        }
        .navigationDestination(isPresented: $showPaymentMethodPicker) {
            ExpensePaymentMethodPickerView(
                methods: $paymentMethods,
                selection: $selectedPaymentMethodId,
                isLoading: isLoadingMethods,
                onReload: { await loadPaymentMethods() }
            )
        }
        .onChange(of: selectedProofItem) { _, item in
            Task { await loadProofPreview(from: item) }
        }
        .photosPicker(isPresented: $showProofPicker, selection: $selectedProofItem, matching: proofPickerMatching)
        .fileImporter(
            isPresented: $showProofFileImporter,
            allowedContentTypes: [.jpeg, .png, .pdf],
            allowsMultipleSelection: false
        ) { result in
            Task { @MainActor in
                handleProofFileImport(result)
            }
        }
        .confirmationDialog(L10n.Budget.chooseProofSource, isPresented: $showProofSourceDialog) {
            Button(L10n.Budget.choosePhoto) {
                showProofPicker = true
            }
            Button(L10n.Budget.chooseFile) {
                showProofFileImporter = true
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        }
        .sheet(isPresented: $showProofViewer) {
            ExpenseProofViewer(
                image: proofPreview,
                remoteURL: proofRemoteUrl.flatMap(URL.init(string:))
            )
        }
        .alert(L10n.Budget.fileTooLarge, isPresented: $showProofSizeAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(proofSizeError ?? L10n.Budget.fileTooLargeDefault)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.72))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.86), in: Circle())
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(isEditing ? L10n.Budget.editExpense : L10n.Budget.addExpense)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.sageDark)
                Text(isEditing ? L10n.Budget.editExpenseFormSub : L10n.Budget.addExpenseFormSub)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Color.clear.frame(width: 42, height: 42)
        }
        .padding(.bottom, 8)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                fieldIcon("note.text")

                TextField(L10n.Budget.notesPlaceholder, text: $notes, axis: .vertical)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(3...5)
                    .onChange(of: notes) { _, newValue in
                        if newValue.count > notesLimit {
                            notes = String(newValue.prefix(notesLimit))
                        }
                    }

                Text("\(notes.count)/\(notesLimit)")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.35))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(fieldBackground)
        }
    }

    private var paymentStatusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                fieldIcon("checkmark.circle")

                Text(L10n.Budget.paymentStatus)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)

                Spacer()
            }

            Picker(L10n.Budget.paymentStatus, selection: $isMarkedPaid) {
                Text(L10n.Budget.unpaid).tag(false)
                Text(L10n.Budget.paid).tag(true)
            }
            .pickerStyle(.segmented)

            if isMarkedPaid {
                Text(L10n.Budget.statusHintPaid)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            } else if isOverdueUnpaid {
                Text(L10n.Budget.statusHintOverdue)
                    .font(AppFont.regular(11))
                    .foregroundStyle(Color.orange.opacity(0.85))
            } else {
                Text(L10n.Budget.statusHintPending)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(fieldBackground)
    }

    private var isOverdueUnpaid: Bool {
        guard !isMarkedPaid else {
            return false
        }

        let startOfToday = Calendar.current.startOfDay(for: Date())
        return dueDate < startOfToday
    }

    private var proofSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                fieldIcon("photo.on.rectangle")
                Text(L10n.Budget.proofOptional)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)

                Spacer()

                if shouldUseReadOnlyProofDisplay {
                    Button {
                        showProofViewer = true
                    } label: {
                        Label(L10n.Budget.view, systemImage: "eye")
                            .font(AppFont.medium(12))
                            .foregroundStyle(AppTheme.sageDark)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppTheme.lightSage, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if proofSizeError != nil {
                proofSizeErrorView
            }

            if shouldUseReadOnlyProofDisplay {
                Button {
                    showProofViewer = true
                } label: {
                    proofPreviewContent
                }
                .buttonStyle(.plain)

                Button {
                    showProofSourceDialog = true
                } label: {
                    Label(L10n.Budget.replaceProof, systemImage: "arrow.triangle.2.circlepath")
                        .font(AppFont.medium(12))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.lightSage.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    showProofSourceDialog = true
                } label: {
                    proofUploadContent
                }
                .buttonStyle(.plain)
            }

            Text(L10n.Budget.proofMaxSize)
                .font(AppFont.regular(11))
                .foregroundStyle(proofSizeError == nil ? AppTheme.ink.opacity(0.35) : .red.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(fieldBackground)
    }

    private var proofSizeErrorView: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.red)

            Text(proofSizeError ?? "")
                .font(AppFont.regular(12))
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var proofPreviewContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                .foregroundStyle(AppTheme.sage.opacity(0.35))

            if let proofPreview {
                Image(uiImage: proofPreview)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.sageDark)
                    Text(L10n.Budget.tapToOpenProof)
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                }
                .padding(.vertical, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 160)
    }

    private var proofUploadContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
                .foregroundStyle(proofSizeError == nil ? AppTheme.sage.opacity(0.35) : Color.red.opacity(0.45))

            if let proofPreview {
                Image(uiImage: proofPreview)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.lightSage, in: Circle())

                    Text(L10n.Budget.addProof)
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 120)
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                Text(isEditing ? L10n.Budget.saveChanges : L10n.Budget.saveExpense)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSave ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private func pickerRow(icon: String, title: String, isPlaceholder: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                fieldIcon(icon)
                Text(title)
                    .font(AppFont.regular(14))
                    .foregroundStyle(isPlaceholder ? AppTheme.ink.opacity(0.35) : AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.25))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(fieldBackground)
        }
        .buttonStyle(.plain)
    }

    private func inputRow<Content: View, Trailing: View>(
        icon: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) -> some View {
        HStack(spacing: 12) {
            fieldIcon(icon)
            content()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(fieldBackground)
    }

    private func fieldIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(AppTheme.ink.opacity(0.45))
            .frame(width: 36, height: 36)
            .background(AppTheme.mist.opacity(0.65), in: Circle())
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white)
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 4)
    }

    private var parsedAmount: Double? {
        let digits = amountText.filter(\.isNumber)
        guard !digits.isEmpty, let value = Double(digits) else { return nil }
        return value
    }

    private static func formatAmountInput(_ value: String) -> String {
        let digits = value.filter(\.isNumber)
        guard !digits.isEmpty, let number = Int(digits) else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: number)) ?? digits
    }

    private func populateIfNeeded() {
        guard let schedule else { return }
        title = schedule.title
        vendorName = schedule.vendorName ?? ""
        category = schedule.category ?? ""
        amountText = Self.formatAmountInput(String(Int(schedule.amount.rounded())))
        selectedWeddingEventId = schedule.weddingEventId
        selectedPaymentMethodId = schedule.customerPaymentMethodId
        notes = schedule.notes ?? ""
        isMarkedPaid = schedule.isPaid
        if let dueDateString = schedule.dueDate, !dueDateString.isEmpty,
           let date = DateFormatter.apiDate.date(from: dueDateString) {
            dueDate = date
        }

        if let proofUrl = schedule.proofUrl,
           let url = URL(string: proofUrl) {
            proofRemoteUrl = proofUrl
            Task {
                if proofUrl.lowercased().hasSuffix(".pdf") {
                    return
                }

                if let (data, response) = try? await URLSession.shared.data(from: url),
                   (response as? HTTPURLResponse)?.statusCode == 200,
                   let image = UIImage(data: data) {
                    proofPreview = image
                }
            }
        }
    }

    private func loadWeddingEvents() async {
        do {
            let envelope: Envelope<[WeddingEvent]> = try await APIClient.shared.request("wedding-events")
            weddingEvents = envelope.data
        } catch {
            weddingEvents = []
        }
    }

    private func loadPaymentMethods() async {
        isLoadingMethods = true
        defer { isLoadingMethods = false }

        do {
            let envelope: Envelope<[CustomerPaymentMethod]> = try await APIClient.shared.request("customer-payment-methods")
            paymentMethods = envelope.data
            if selectedPaymentMethodId == nil {
                selectedPaymentMethodId = paymentMethods.first(where: { $0.isPrimary == true })?.id ?? paymentMethods.first?.id
            }
        } catch {
            paymentMethods = []
        }
    }

    @MainActor
    private func loadProofPreview(from item: PhotosPickerItem?) async {
        guard let item else {
            if schedule?.proofUrl == nil {
                proofPreview = nil
                proofFileData = nil
            }

            if suppressProofSelectionReset {
                suppressProofSelectionReset = false
                return
            }

            proofSizeError = nil
            return
        }

        guard let pickedFile = try? await item.loadTransferable(type: PickedProofFile.self) else {
            rejectProofFile(
                message: L10n.Budget.proofReadError
            )
            return
        }

        let data = pickedFile.data

        if data.count > maxProofFileSize {
            rejectProofFile(
                message: L10n.Budget.fileTooLargeDetail(Self.formatFileSize(data.count))
            )
            return
        }

        proofSizeError = nil
        showProofSizeAlert = false
        proofFileData = data
        proofFileName = pickedFile.fileName
        proofMimeType = pickedFile.mimeType
        proofRemoteUrl = nil
        isMarkedPaid = true

        if pickedFile.mimeType.hasPrefix("image/"), let image = UIImage(data: data) {
            proofPreview = image
        } else {
            proofPreview = nil
        }
    }

    @MainActor
    private func handleProofFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure:
            rejectProofFile(message: L10n.Budget.proofReadError)
        case .success(let urls):
            guard let url = urls.first else { return }

            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            guard let data = try? Data(contentsOf: url) else {
                rejectProofFile(message: L10n.Budget.proofReadError)
                return
            }

            if data.count > maxProofFileSize {
                rejectProofFile(
                    message: L10n.Budget.fileTooLargeDetail(Self.formatFileSize(data.count))
                )
                return
            }

            let fileName = url.lastPathComponent.isEmpty ? "proof" : url.lastPathComponent
            let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
                ?? "application/octet-stream"

            proofSizeError = nil
            showProofSizeAlert = false
            proofFileData = data
            proofFileName = fileName
            proofMimeType = mimeType
            proofRemoteUrl = nil
            isMarkedPaid = true
            suppressProofSelectionReset = true
            selectedProofItem = nil

            if mimeType.hasPrefix("image/"), let image = UIImage(data: data) {
                proofPreview = image
            } else {
                proofPreview = nil
            }
        }
    }

    @MainActor
    private func rejectProofFile(message: String) {
        proofSizeError = message
        showProofSizeAlert = true
        proofFileData = nil
        proofPreview = nil
        suppressProofSelectionReset = true
        selectedProofItem = nil
    }

    private static func formatFileSize(_ bytes: Int) -> String {
        let megabytes = Double(bytes) / 1_024 / 1_024
        if megabytes >= 0.1 {
            let formatted = megabytes.truncatingRemainder(dividingBy: 0.1) == 0
                ? String(format: "%.0f", megabytes)
                : String(format: "%.1f", megabytes)
            return "\(formatted) MB"
        }

        let kilobytes = Double(bytes) / 1_024
        let formatted = kilobytes.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", kilobytes)
            : String(format: "%.1f", kilobytes)
        return "\(formatted) KB"
    }

    private func buildFields(amount: Double) -> [String: String] {
        let status = isMarkedPaid ? "paid" : (isOverdueUnpaid ? "overdue" : "pending")

        var fields: [String: String] = [
            "title": title.trimmingCharacters(in: .whitespacesAndNewlines),
            "category": category,
            "amount": String(amount),
            "due_date": DateFormatter.apiDate.string(from: dueDate),
            "status": status,
        ]

        if let selectedPaymentMethodId {
            fields["customer_payment_method_id"] = String(selectedPaymentMethodId)
        }

        if let selectedWeddingEventId {
            fields["wedding_event_id"] = String(selectedWeddingEventId)
        }

        let trimmedVendor = vendorName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedVendor.isEmpty {
            fields["vendor_name"] = trimmedVendor
        }

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNotes.isEmpty {
            fields["notes"] = trimmedNotes
        }

        return fields
    }

    private func save() async {
        guard let amount = parsedAmount else { return }

        if let proofFileData, proofFileData.count > maxProofFileSize {
            rejectProofFile(
                message: L10n.Budget.fileTooLargeDetail(Self.formatFileSize(proofFileData.count))
            )
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let fields = buildFields(amount: amount)

        do {
            if let proofFileData {
                if let schedule {
                    let _: Envelope<PaymentSchedule> = try await APIClient.shared.uploadMultipart(
                        "wedding-payment-schedules/\(schedule.id)",
                        method: "PUT",
                        fields: fields,
                        fileName: proofFileName,
                        mimeType: proofMimeType,
                        fileData: proofFileData
                    )
                } else {
                    let _: Envelope<PaymentSchedule> = try await APIClient.shared.uploadMultipart(
                        "wedding-payment-schedules",
                        fields: fields,
                        fileName: proofFileName,
                        mimeType: proofMimeType,
                        fileData: proofFileData
                    )
                }
            } else if let schedule {
                let _: Envelope<PaymentSchedule> = try await APIClient.shared.request(
                    "wedding-payment-schedules/\(schedule.id)",
                    method: "PUT",
                    json: fields.reduce(into: [String: Any]()) { result, pair in
                        if pair.key == "amount" {
                            result[pair.key] = amount
                        } else if pair.key == "customer_payment_method_id", let id = Int(pair.value) {
                            result[pair.key] = id
                        } else {
                            result[pair.key] = pair.value
                        }
                    }
                )
            } else {
                let _: Envelope<PaymentSchedule> = try await APIClient.shared.request(
                    "wedding-payment-schedules",
                    method: "POST",
                    json: fields.reduce(into: [String: Any]()) { result, pair in
                        if pair.key == "amount" {
                            result[pair.key] = amount
                        } else if pair.key == "customer_payment_method_id", let id = Int(pair.value) {
                            result[pair.key] = id
                        } else {
                            result[pair.key] = pair.value
                        }
                    }
                )
            }

            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteExpense() async {
        guard let schedule else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await APIClient.shared.requestNoContent("wedding-payment-schedules/\(schedule.id)")
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ExpenseProofViewer: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let image: UIImage?
    let remoteURL: URL?

    private var isPDF: Bool {
        remoteURL?.pathExtension.lowercased() == "pdf"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if let image {
                    ScrollView {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                } else if isPDF, let remoteURL {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.sageDark)

                        Text(L10n.Budget.pdfProof)
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.ink)

                        Button(L10n.Budget.openDocument) {
                            openURL(remoteURL)
                        }
                        .font(AppFont.medium(14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(AppTheme.sageDark, in: Capsule())
                    }
                    .padding()
                } else if let remoteURL {
                    ScrollView {
                        AsyncImage(url: remoteURL) { phase in
                            switch phase {
                            case .success(let loadedImage):
                                loadedImage
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                ContentUnavailableView(
                                    L10n.Budget.proofLoadError,
                                    systemImage: "photo",
                                    description: Text(L10n.Budget.proofLoadErrorSub)
                                )
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 240)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        L10n.Budget.proofUnavailable,
                        systemImage: "photo",
                        description: Text(L10n.Budget.proofNoFile)
                    )
                }
            }
            .navigationTitle(L10n.Budget.proof)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                }
            }
        }
    }
}

struct ExpenseCategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared
    @Binding var selection: String

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            List {
                ForEach(categoriesStore.categories) { option in
                    Button {
                        selection = option.key
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: option.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.sageDark)
                                .frame(width: 28)

                            Text(option.label)
                                .font(AppFont.regular(15))
                                .foregroundStyle(AppTheme.ink)

                            Spacer()

                            if selection == option.key {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.sageDark)
                            }
                        }
                    }
                    .listRowBackground(AppTheme.surface)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .statusBarBlur()
        .navigationTitle(L10n.Budget.pickCategoryTitle)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await categoriesStore.loadIfNeeded()
        }
    }
}

struct ExpenseDatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: Date

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            VStack(spacing: 16) {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Button(L10n.Common.done) { dismiss() }
                    .font(AppFont.medium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
        .statusBarBlur()
        .navigationTitle(L10n.Budget.pickDate)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ExpenseWeddingEventPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let events: [WeddingEvent]
    @Binding var selection: Int?

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            List {
                Button {
                    selection = nil
                    dismiss()
                } label: {
                    HStack {
                        Text(L10n.Budget.noEvent)
                            .font(AppFont.regular(15))
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        if selection == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.sageDark)
                        }
                    }
                }
                .listRowBackground(AppTheme.surface)

                ForEach(events) { event in
                    Button {
                        selection = event.id
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.jenisLabel ?? event.jenisAcara.capitalized)
                                    .font(AppFont.regular(15))
                                    .foregroundStyle(AppTheme.ink)

                                if let date = event.tglAcara, !date.isEmpty {
                                    Text(date)
                                        .font(AppFont.regular(12))
                                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                                }
                            }

                            Spacer()

                            if selection == event.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.sageDark)
                            }
                        }
                    }
                    .listRowBackground(AppTheme.surface)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .statusBarBlur()
        .navigationTitle(L10n.Budget.pickEvent)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ExpensePaymentMethodPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var methods: [CustomerPaymentMethod]
    @Binding var selection: Int?
    let isLoading: Bool
    var onReload: (() async -> Void)? = nil

    @State private var showAddPaymentMethod = false

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if methods.isEmpty {
                    VStack(spacing: 20) {
                        ContentUnavailableView(
                            L10n.Budget.noPaymentMethods,
                            systemImage: "wallet.pass",
                            description: Text(L10n.Budget.noPaymentMethodsSub)
                        )

                        Button {
                            showAddPaymentMethod = true
                        } label: {
                            Label(L10n.Budget.addPaymentMethod, systemImage: "plus")
                                .font(AppFont.medium(14))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(AppTheme.sageDark, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    List {
                        ForEach(methods) { method in
                            Button {
                                selection = method.id
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(method.name)
                                            .font(AppFont.medium(15))
                                            .foregroundStyle(AppTheme.ink)
                                        if let accountNumber = method.accountNumber, !accountNumber.isEmpty {
                                            Text(accountNumber)
                                                .font(AppFont.regular(12))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    if selection == method.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(AppTheme.sageDark)
                                    }
                                }
                            }
                            .listRowBackground(AppTheme.surface)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .statusBarBlur()
        .navigationTitle(L10n.Budget.paymentMethodTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddPaymentMethod = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $showAddPaymentMethod) {
            AddPaymentMethodView { method in
                if let onReload {
                    await onReload()
                } else if !methods.contains(where: { $0.id == method.id }) {
                    methods.append(method)
                }
                selection = method.id
            }
        }
    }
}

private struct PickedProofFile: Transferable {
    let data: Data
    let fileName: String
    let mimeType: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            try Self.imported(from: received.file)
        }

        FileRepresentation(importedContentType: .jpeg) { received in
            try Self.imported(from: received.file)
        }

        FileRepresentation(importedContentType: .png) { received in
            try Self.imported(from: received.file)
        }

        FileRepresentation(importedContentType: .pdf) { received in
            try Self.imported(from: received.file)
        }

        DataRepresentation(importedContentType: .image) { data in
            PickedProofFile(data: data, fileName: "proof.jpg", mimeType: UTType.jpeg.preferredMIMEType ?? "image/jpeg")
        }
    }

    private static func imported(from url: URL) throws -> PickedProofFile {
        let data = try Data(contentsOf: url)
        let fileName = url.lastPathComponent.isEmpty ? "proof" : url.lastPathComponent
        let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"

        return PickedProofFile(data: data, fileName: fileName, mimeType: mimeType)
    }
}

private extension DateFormatter {
    static let apiDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
