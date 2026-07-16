import SwiftUI

struct IncomingPaymentsSummaryCard: View {
    let metrics: IncomingPaymentMetrics
    let recentPayments: [IncomingPayment]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(L10n.Budget.incoming, systemImage: "arrow.down.circle.fill")
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.sageDark)
                        .labelStyle(.titleAndIcon)

                    Text(CurrencyFormatter.rupiah(metrics.totalAll))
                        .font(AppFont.medium(24))
                        .foregroundStyle(AppTheme.sageDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(L10n.Budget.incomingTotalRecorded)
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))

                    Text(L10n.Budget.incomingNotAffectRemaining)
                        .font(AppFont.regular(10))
                        .foregroundStyle(AppTheme.ink.opacity(0.42))
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 8) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(L10n.Budget.confirmed)
                            .font(AppFont.regular(10))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text(CurrencyFormatter.rupiah(metrics.totalConfirmed))
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.sageDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if metrics.pendingCount > 0 {
                        Text(L10n.Budget.pendingCount(metrics.pendingCount))
                            .font(AppFont.regular(10))
                            .foregroundStyle(AppTheme.sageDark.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.sage.opacity(0.14), in: Capsule())
                    }
                }
            }

            if !recentPayments.isEmpty {
                Divider().overlay(AppTheme.sage.opacity(0.18))

                VStack(spacing: 8) {
                    ForEach(recentPayments) { payment in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(payment.displaySenderName)
                                    .font(AppFont.medium(12))
                                    .foregroundStyle(AppTheme.ink)
                                    .lineLimit(1)
                                if !payment.subtitleLine.isEmpty {
                                    Text(payment.subtitleLine)
                                        .font(AppFont.regular(10))
                                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                                        .lineLimit(1)
                                }
                            }

                            Spacer(minLength: 8)

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(CurrencyFormatter.rupiah(payment.amount))
                                    .font(AppFont.medium(12))
                                    .foregroundStyle(AppTheme.sageDark)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                Text(payment.displayStatusLabel)
                                    .font(AppFont.regular(9))
                                    .foregroundStyle(statusTint(for: payment))
                            }
                        }
                    }
                }
            } else {
                Text(L10n.Budget.noIncoming)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
            }

            HStack {
                Spacer()
                Label(L10n.Common.seeAll, systemImage: "chevron.right")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
            }
        }
        .padding(18)
        .premiumGlassCard(cornerRadius: 22)
    }

    private func statusTint(for payment: IncomingPayment) -> Color {
        switch payment.normalizedStatus {
        case "confirmed": return Color.green.opacity(0.9)
        case "rejected": return Color.red.opacity(0.9)
        default: return Color.orange.opacity(0.95)
        }
    }
}

struct IncomingPaymentsView: View {
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    let onChanged: () async -> Void

    @State private var payments: [IncomingPayment] = []
    @State private var selectedFilter: IncomingPaymentFilter = .all
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddPayment = false
    @State private var editingPayment: IncomingPayment?

    private var metrics: IncomingPaymentMetrics {
        IncomingPaymentMetrics.make(
            from: payments,
            pendingStatus: categoriesStore.defaultIncomingPaymentStatus
        )
    }

    private var filteredPayments: [IncomingPayment] {
        payments.filter {
            selectedFilter.matches($0, pendingStatus: categoriesStore.defaultIncomingPaymentStatus)
        }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    summaryStrip
                    filterChips

                    if isLoading && payments.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if filteredPayments.isEmpty {
                        ContentUnavailableView(
                            L10n.Budget.incomingEmpty,
                            systemImage: "arrow.down.circle",
                            description: Text(emptyDescription)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(filteredPayments) { payment in
                                Button {
                                    editingPayment = payment
                                } label: {
                                    IncomingPaymentRow(payment: payment)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        Task { await delete(payment) }
                                    } label: {
                                        Label(L10n.Common.delete, systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    addButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(L10n.Budget.incoming)
        .navigationBarTitleDisplayMode(.large)
        .task { await load() }
        .refreshable { await load() }
        .navigationDestination(isPresented: $showAddPayment) {
            AddIncomingPaymentView(payment: nil) {
                await load()
                await onChanged()
            }
        }
        .navigationDestination(item: $editingPayment) { payment in
            AddIncomingPaymentView(payment: payment) {
                await load()
                await onChanged()
            }
        }
    }

    private var emptyDescription: String {
        switch selectedFilter {
        case .all:
            return L10n.Budget.incomingEmptyAllSub
        case .menunggu:
            return L10n.Budget.incomingEmptyPending
        case .confirmed:
            return L10n.Budget.incomingEmptyConfirmed
        case .rejected:
            return L10n.Budget.incomingEmptyRejected
        }
    }

    private var summaryStrip: some View {
        HStack(spacing: 10) {
            summaryMetric(title: L10n.Budget.total, amount: metrics.totalAll, tint: AppTheme.sageDark)
            summaryMetric(title: L10n.Budget.confirmed, amount: metrics.totalConfirmed, tint: AppTheme.gold)
        }
    }

    private func summaryMetric(title: String, amount: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
            Text(CurrencyFormatter.rupiah(amount))
                .font(AppFont.medium(16))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(IncomingPaymentFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.label)
                            .font(AppFont.medium(12))
                            .foregroundStyle(selectedFilter == filter ? .white : AppTheme.ink.opacity(0.65))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? AppTheme.sageDark : AppTheme.mist.opacity(0.65),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            showAddPayment = true
        } label: {
            Label(L10n.Budget.addIncoming, systemImage: "plus")
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[IncomingPayment]> = try await APIClient.shared.request("wedding-incoming-payments")
            payments = envelope.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete(_ payment: IncomingPayment) async {
        do {
            try await APIClient.shared.requestNoContent("wedding-incoming-payments/\(payment.id)")
            await load()
            await onChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct IncomingPaymentRow: View {
    let payment: IncomingPayment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 40, height: 40)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(payment.displaySenderName)
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    Text(payment.displayStatusLabel)
                        .font(AppFont.regular(10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.14))
                        .foregroundStyle(statusColor)
                        .clipShape(Capsule())
                }

                if !payment.subtitleLine.isEmpty {
                    Text(payment.subtitleLine)
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                        .lineLimit(1)
                }

                if let description = payment.description, !description.isEmpty {
                    Text(description)
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                        .lineLimit(2)
                }

                Text(CurrencyFormatter.rupiah(payment.amount))
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)

                if let referenceNumber = payment.referenceNumber, !referenceNumber.isEmpty {
                    Text(L10n.Budget.ref(referenceNumber))
                        .font(AppFont.regular(10))
                        .foregroundStyle(AppTheme.ink.opacity(0.4))
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
                .padding(.top, 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .premiumGlassCard(cornerRadius: 18)
    }

    private var statusColor: Color {
        switch payment.normalizedStatus {
        case "confirmed": return .green
        case "rejected": return .red
        default: return .orange
        }
    }
}

struct AddIncomingPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    let payment: IncomingPayment?
    let onSaved: () async -> Void

    @State private var senderName = ""
    @State private var amountText = ""
    @State private var transferDate = Date()
    @State private var bankName = ""
    @State private var descriptionText = ""
    @State private var referenceNumber = ""
    @State private var notes = ""
    @State private var status = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isEditing: Bool { payment != nil }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    incomingStatusSection

                    formSection(title: L10n.Budget.sender) {
                        formField(icon: "person.fill", placeholder: L10n.Budget.senderPlaceholder, text: $senderName)
                    }

                    formSection(title: L10n.Budget.amount) {
                        HStack(spacing: 12) {
                            Image(systemName: "banknote")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.sageDark)
                                .frame(width: 24)
                            TextField(L10n.Budget.amountPlaceholder, text: $amountText)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink)
                                .keyboardType(.numberPad)
                                .onChange(of: amountText) { _, newValue in
                                    amountText = CurrencyFormatter.formatAmountInput(newValue)
                                }
                        }
                    }

                    formSection(title: L10n.Budget.transferDate) {
                        DatePicker("", selection: $transferDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding(.horizontal, 4)
                    }

                    formSection(title: L10n.Budget.optionalDetail) {
                        formField(icon: "building.columns", placeholder: L10n.Budget.bankPlaceholder, text: $bankName)
                        formField(icon: "text.alignleft", placeholder: L10n.Budget.descriptionPlaceholder, text: $descriptionText)
                        formField(icon: "number", placeholder: L10n.Budget.referencePlaceholder, text: $referenceNumber)
                        formField(icon: "note.text", placeholder: L10n.Common.notes, text: $notes, axis: .vertical)
                    }

                    if isEditing {
                        Button(role: .destructive) {
                            Task { await deletePayment() }
                        } label: {
                            Label(L10n.Common.delete, systemImage: "trash")
                                .font(AppFont.medium(14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(isEditing ? L10n.Budget.editIncoming : L10n.Budget.addIncoming)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) { saveButton }
        .task {
            await categoriesStore.loadIfNeeded()
            if status.isEmpty {
                status = categoriesStore.defaultIncomingPaymentStatus
            }
            populateIfNeeded()
        }
    }

    private var incomingStatusSection: some View {
        formSection(title: L10n.Budget.receiveStatus) {
            Picker(L10n.Budget.status, selection: $status) {
                Text(L10n.Budget.statusPending).tag("menunggu")
                Text(L10n.Budget.confirmed).tag("confirmed")
                Text(L10n.Budget.statusRejected).tag("rejected")
            }
            .pickerStyle(.segmented)

            Text(incomingStatusHint)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
        }
    }

    private var incomingStatusHint: String {
        switch status {
        case "confirmed":
            return L10n.Budget.incomingStatusHintConfirmed
        case "rejected":
            return L10n.Budget.incomingStatusHintRejected
        default:
            return L10n.Budget.incomingStatusHintPending
        }
    }

    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)

            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .premiumGlassCard(cornerRadius: 18)
        }
    }

    private func formField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        axis: Axis = .horizontal
    ) -> some View {
        HStack(alignment: axis == .vertical ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 24)

            TextField(placeholder, text: text, axis: axis)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(axis == .vertical ? 3...5 : 1...1)
        }
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            Text(isEditing ? L10n.Budget.saveChanges : L10n.Budget.saveIncoming)
                .font(AppFont.medium(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canSave ? AppTheme.sageDark : AppTheme.sage.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSave || isLoading)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var canSave: Bool {
        !senderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && parsedAmount != nil
    }

    private var parsedAmount: Double? {
        let digits = amountText.filter(\.isNumber)
        guard !digits.isEmpty, let value = Double(digits) else { return nil }
        return value
    }

    private func populateIfNeeded() {
        guard let payment else { return }

        senderName = payment.senderName ?? ""
        amountText = payment.amount > 0
            ? CurrencyFormatter.formatAmountInput(String(Int(payment.amount)))
            : ""
        bankName = payment.bankName ?? ""
        descriptionText = payment.description ?? ""
        referenceNumber = payment.referenceNumber ?? ""
        notes = payment.notes ?? ""
        status = payment.normalizedStatus

        if let transferDate = payment.transferDate,
           let date = Self.apiDateFormatter.date(from: String(transferDate.prefix(10))) {
            self.transferDate = date
        }
    }

    private func save() async {
        guard let amount = parsedAmount else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [
            "sender_name": senderName.trimmingCharacters(in: .whitespacesAndNewlines),
            "amount": amount,
            "transfer_date": Self.apiDateFormatter.string(from: transferDate),
            "status": status,
        ]

        let optionalFields: [(String, String)] = [
            ("bank_name", bankName),
            ("description", descriptionText),
            ("reference_number", referenceNumber),
            ("notes", notes),
        ]

        for (key, value) in optionalFields {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                payload[key] = trimmed
            }
        }

        do {
            if let payment {
                let _: Envelope<IncomingPayment> = try await APIClient.shared.request(
                    "wedding-incoming-payments/\(payment.id)",
                    method: "PUT",
                    json: payload
                )
            } else {
                let _: Envelope<IncomingPayment> = try await APIClient.shared.request(
                    "wedding-incoming-payments",
                    method: "POST",
                    json: payload
                )
            }

            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deletePayment() async {
        guard let payment else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await APIClient.shared.requestNoContent("wedding-incoming-payments/\(payment.id)")
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
