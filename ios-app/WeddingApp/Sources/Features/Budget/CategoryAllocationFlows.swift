import SwiftUI

struct EditCategoryAllocationView: View {
    @Environment(\.dismiss) private var dismiss

    let category: BudgetCategory
    let allocation: BudgetCategoryAllocation?
    let onSaved: () async -> Void

    @State private var amountText = ""
    @State private var notes = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var isEditing: Bool { allocation != nil }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    categoryHeader

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    formSection(title: L10n.Budget.budgetAllocation) {
                        HStack(spacing: 12) {
                            Image(systemName: "banknote")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.sageDark)
                                .frame(width: 24)

                            TextField(L10n.Budget.allocationAmountField, text: $amountText)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink)
                                .keyboardType(.numberPad)
                                .onChange(of: amountText) { _, newValue in
                                    let formatted = CurrencyFormatter.formatAmountInput(newValue)
                                    if formatted != amountText {
                                        amountText = formatted
                                    }
                                }
                        }

                        if shouldShowSuggestedAmount {
                            suggestedAmountRow
                        }
                    }

                    formSection(title: L10n.Common.notes) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "note.text")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.sageDark)
                                .frame(width: 24)

                            TextField(L10n.Budget.optional, text: $notes, axis: .vertical)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.ink)
                                .lineLimit(3...5)
                        }
                    }

                    usageSummary

                    if isEditing {
                        Button {
                            Task { await deleteAllocation() }
                        } label: {
                            Label(L10n.Budget.deleteAllocation, systemImage: "trash")
                                .font(AppFont.medium(14))
                                .foregroundStyle(Color.red.opacity(0.95))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(isEditing ? L10n.Budget.editAllocation : L10n.Budget.setAllocation)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) { saveButton }
        .onAppear { populateIfNeeded() }
    }

    private var categoryHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 44, height: 44)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Budget.spentCommitmentLine(CurrencyFormatter.rupiah(category.spent), CurrencyFormatter.rupiah(category.commitment)))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.captionOnLightSurface)
            }

            Spacer()
        }
        .padding(14)
        .premiumListRow(cornerRadius: 18)
    }

    private var usageSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Budget.summaryShort)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)

            HStack {
                Text(L10n.Budget.recorded)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.captionOnLightSurface)
                Spacer()
                Text(CurrencyFormatter.rupiah(category.totalRecorded))
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
            }

            if let planned = parsedAmount, planned > 0 {
                HStack {
                    Text(L10n.Budget.allocationRemaining)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.captionOnLightSurface)
                    Spacer()
                    Text(CurrencyFormatter.rupiah(max(planned - category.spent - category.commitment, 0)))
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.goldOnLightSurface)
                }
            }
        }
        .padding(14)
        .premiumListRow(cornerRadius: 16)
    }

    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.titleOnBackground)

            VStack(spacing: 10) {
                content()
            }
            .padding(14)
            .premiumListRow(cornerRadius: 18)
        }
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            Text(isEditing ? L10n.Budget.saveChanges : L10n.Budget.saveAllocation)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.primaryActionForeground(enabled: canSave))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    AppTheme.primaryActionFill(enabled: canSave),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSave || isLoading)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.surface)
    }

    private var canSave: Bool {
        parsedAmount != nil
    }

    private var parsedAmount: Double? {
        CurrencyFormatter.parseAmountInput(amountText)
    }

    private var suggestedRecordedAmount: Double {
        category.totalRecorded
    }

    private var shouldShowSuggestedAmount: Bool {
        !isEditing && suggestedRecordedAmount > 0
    }

    private var suggestedAmountRow: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Budget.suggestedFromRecorded(CurrencyFormatter.rupiah(suggestedRecordedAmount)))
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.captionOnLightSurface)
            }

            Spacer(minLength: 8)

            Button {
                amountText = CurrencyFormatter.formatAmountInput(String(Int(suggestedRecordedAmount)))
            } label: {
                Text(L10n.Budget.useSuggestedAmount)
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.sage.opacity(0.14), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
    }

    private func populateIfNeeded() {
        if let allocation {
            amountText = allocation.allocatedAmount > 0
                ? CurrencyFormatter.formatAmountInput(String(Int(allocation.allocatedAmount)))
                : ""
            notes = allocation.notes ?? ""
            return
        }

        // Prefill new allocation from recorded expenses so the form is immediately actionable.
        if category.totalRecorded > 0 {
            amountText = CurrencyFormatter.formatAmountInput(String(Int(category.totalRecorded)))
        }
    }

    private func save() async {
        guard let amount = parsedAmount else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [
            "category": category.id,
            "allocated_amount": amount,
        ]

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNotes.isEmpty {
            payload["notes"] = trimmedNotes
        }

        do {
            if let allocation {
                let _: Envelope<BudgetCategoryAllocation> = try await APIClient.shared.request(
                    "wedding-budget-category-allocations/\(allocation.id)",
                    method: "PUT",
                    json: payload
                )
            } else {
                let _: Envelope<BudgetCategoryAllocation> = try await APIClient.shared.request(
                    "wedding-budget-category-allocations",
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

    private func deleteAllocation() async {
        guard let allocation else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await APIClient.shared.requestNoContent("wedding-budget-category-allocations/\(allocation.id)")
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
