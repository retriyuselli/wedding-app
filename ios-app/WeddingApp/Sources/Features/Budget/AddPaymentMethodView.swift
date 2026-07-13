import SwiftUI

struct AddPaymentMethodView: View {
    @Environment(\.dismiss) private var dismiss

    let onCreated: (CustomerPaymentMethod) async -> Void

    @State private var name = ""
    @State private var paymentType = "bank"
    @State private var accountNumber = ""
    @State private var accountName = ""
    @State private var isPrimary = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let typeOptions: [(id: String, label: String)] = [
        ("bank", L10n.Budget.paymentTypeBank),
        ("e-wallet", L10n.Budget.paymentTypeEwallet),
        ("cash", L10n.Budget.paymentTypeCash),
        ("other", L10n.Budget.paymentTypeOther),
    ]

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
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

                    formSection(title: L10n.Budget.paymentMethodName) {
                        formField(icon: "creditcard", placeholder: L10n.Budget.paymentMethodName, text: $name)
                    }

                    formSection(title: L10n.Budget.paymentType) {
                        Picker(L10n.Budget.paymentType, selection: $paymentType) {
                            ForEach(typeOptions, id: \.id) { option in
                                Text(option.label).tag(option.id)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    formSection(title: L10n.Budget.accountNumber) {
                        formField(
                            icon: "number",
                            placeholder: L10n.Budget.accountNumber,
                            text: $accountNumber,
                            keyboardType: .numbersAndPunctuation
                        )
                    }

                    formSection(title: L10n.Budget.accountName) {
                        formField(icon: "person.fill", placeholder: L10n.Budget.accountName, text: $accountName)
                    }

                    formSection(title: L10n.Budget.isPrimaryMethod) {
                        Toggle(isOn: $isPrimary) {
                            Text(L10n.Budget.isPrimaryMethod)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink)
                        }
                        .tint(AppTheme.sageDark)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .statusBarBlur()
        .navigationTitle(L10n.Budget.addPaymentMethod)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) { saveButton }
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
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
    }

    private func formField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 24)

            TextField(placeholder, text: text)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .keyboardType(keyboardType)
        }
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            Text(L10n.Budget.savePaymentMethod)
                .font(AppFont.medium(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canSave ? AppTheme.sageDark : AppTheme.sage.opacity(0.45),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func save() async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [
            "name": trimmedName,
            "type": paymentType,
            "is_primary": isPrimary,
        ]

        let trimmedAccountNumber = accountNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAccountNumber.isEmpty {
            payload["account_number"] = trimmedAccountNumber
        }

        let trimmedAccountName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAccountName.isEmpty {
            payload["account_name"] = trimmedAccountName
        }

        do {
            let envelope: Envelope<CustomerPaymentMethod> = try await APIClient.shared.request(
                "customer-payment-methods",
                method: "POST",
                json: payload
            )
            await onCreated(envelope.data)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
