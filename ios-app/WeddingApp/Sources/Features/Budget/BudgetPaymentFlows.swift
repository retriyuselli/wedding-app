import SwiftUI

struct EditableScheduleRoute: Identifiable, Hashable {
    let id: Int
}

struct PaymentScheduleListView: View {
    let title: String
    let schedules: [PaymentSchedule]
    let onReload: () async -> Void
    var categorySummary: BudgetCategory?
    var totalBudget: Double = 0
    var onSetAllocation: (() -> Void)? = nil

    @State private var showAddExpense = false
    @State private var editingScheduleRoute: EditableScheduleRoute?
    @State private var errorMessage: String?

    private var sortedSchedules: [PaymentSchedule] {
        schedules.sorted { lhs, rhs in
            let lhsOrder = lhs.sortOrder ?? Int.max
            let rhsOrder = rhs.sortOrder ?? Int.max

            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }

            return (lhs.dueDate ?? "") < (rhs.dueDate ?? "")
        }
    }

    private var listIdentity: String {
        sortedSchedules
            .map { "\($0.id):\($0.amount):\($0.status):\($0.title)" }
            .joined(separator: "|")
    }

    var body: some View {
        List {
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }

            if let categorySummary {
                Section {
                    BudgetCategorySummaryCard(category: categorySummary, totalBudget: totalBudget)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                if shouldPromptSetAllocation(for: categorySummary), let onSetAllocation {
                    Section {
                        Button(action: onSetAllocation) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppTheme.sageDark)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(L10n.Budget.setAllocationPromptTitle)
                                        .font(AppFont.medium(14))
                                        .foregroundStyle(AppTheme.ink)
                                    Text(L10n.Budget.setAllocationPromptSub)
                                        .font(AppFont.regular(12))
                                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer(minLength: 4)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppTheme.ink.opacity(0.28))
                            }
                            .padding(14)
                            .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                }
            }

            if sortedSchedules.isEmpty {
                ContentUnavailableView(
                    L10n.Budget.noExpenses,
                    systemImage: "creditcard",
                    description: Text(L10n.Budget.noExpensesScheduleSub)
                )
            } else {
                ForEach(sortedSchedules) { schedule in
                    Button {
                        editingScheduleRoute = EditableScheduleRoute(id: schedule.id)
                    } label: {
                        PaymentScheduleRow(schedule: schedule)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await delete(schedule) }
                        } label: {
                            Label(L10n.Common.delete, systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if !schedule.isPaid {
                            Button {
                                Task { await markPaid(schedule) }
                            } label: {
                                Label(L10n.Budget.markPaid, systemImage: "checkmark.circle")
                            }
                            .tint(.green)
                        }
                    }
                }
            }
        }
        .id(listIdentity)
        .refreshable {
            await onReload()
        }
        .task(id: listIdentity) {
            await onReload()
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(isPresented: $showAddExpense) {
            AddExpenseView(schedule: nil) {
                await onReload()
            }
        }
        .navigationDestination(item: $editingScheduleRoute) { route in
            AddExpenseView(
                schedule: schedules.first(where: { $0.id == route.id })
            ) {
                await onReload()
                editingScheduleRoute = nil
            }
        }
    }

    private func shouldPromptSetAllocation(for category: BudgetCategory) -> Bool {
        !category.hasPlannedAllocation && category.totalRecorded > 0
    }

    private func markPaid(_ schedule: PaymentSchedule) async {
        do {
            let _: Envelope<PaymentSchedule> = try await APIClient.shared.request(
                "wedding-payment-schedules/\(schedule.id)/mark-paid",
                method: "PATCH"
            )
            await onReload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete(_ schedule: PaymentSchedule) async {
        do {
            try await APIClient.shared.requestNoContent("wedding-payment-schedules/\(schedule.id)")
            await onReload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct BudgetCategoryDetailView: View {
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    let categoryId: String
    let schedules: [PaymentSchedule]
    let totalBudget: Double
    let onReload: () async -> Void
    var categoryOptions: [BudgetPaymentCategory] = []
    var allocations: [BudgetCategoryAllocation] = []

    @State private var showEditAllocation = false

    private var budgetDefaults: BudgetDefaults {
        categoriesStore.defaults
    }

    private var allocationMap: [String: BudgetCategoryAllocation] {
        BudgetCategory.allocationsMap(from: allocations)
    }

    private var category: BudgetCategory {
        BudgetCategory.build(
            from: schedules,
            options: categoryOptions,
            allocations: allocations,
            defaults: budgetDefaults
        ).first { $0.id == categoryId }
            ?? BudgetCategory(
                id: categoryId,
                name: BudgetCategory.label(for: categoryId, options: categoryOptions),
                iconName: BudgetCategory.icon(
                    for: categoryId,
                    options: categoryOptions,
                    defaultIcon: budgetDefaults.categoryIcon
                ),
                plannedAllocation: allocationMap[categoryId]?.allocatedAmount ?? 0,
                spent: 0,
                commitment: 0
            )
    }

    private var filteredSchedules: [PaymentSchedule] {
        schedules.filter {
            $0.resolvedCategoryKey(default: budgetDefaults.expenseCategory) == categoryId
        }
    }

    var body: some View {
        PaymentScheduleListView(
            title: category.name,
            schedules: filteredSchedules,
            onReload: onReload,
            categorySummary: category,
            totalBudget: totalBudget,
            onSetAllocation: {
                showEditAllocation = true
            }
        )
        .navigationDestination(isPresented: $showEditAllocation) {
            EditCategoryAllocationView(
                category: category,
                allocation: allocationMap[categoryId]
            ) {
                await onReload()
            }
        }
    }
}

struct BudgetSummaryDetailView: View {
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    let totalBudget: Double
    let schedules: [PaymentSchedule]
    let onReload: () async -> Void
    var categoryOptions: [BudgetPaymentCategory] = []
    var allocations: [BudgetCategoryAllocation] = []

    private var budgetDefaults: BudgetDefaults {
        categoriesStore.defaults
    }

    private var categories: [BudgetCategory] {
        BudgetCategory.build(
            from: schedules,
            options: categoryOptions,
            allocations: allocations,
            defaults: budgetDefaults
        )
    }

    private var metrics: BudgetSummaryMetrics {
        BudgetSummaryMetrics.make(
            budget: WeddingBudget(
                id: nil,
                totalBudget: totalBudget,
                currency: budgetDefaults.currency,
                notes: nil
            ),
            categories: categories
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                summaryCard

                if categories.isEmpty {
                    ContentUnavailableView(
                        L10n.Budget.noExpenses,
                        systemImage: "chart.pie",
                        description: Text(L10n.Budget.noExpensesSummarySub)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    Text(L10n.Budget.perCategory)
                        .font(AppFont.medium(16))
                        .foregroundStyle(AppTheme.sageDark)

                    VStack(spacing: 10) {
                        ForEach(categories) { category in
                            NavigationLink {
                                BudgetCategoryDetailView(
                                    categoryId: category.id,
                                    schedules: schedules,
                                    totalBudget: totalBudget,
                                    onReload: onReload,
                                    categoryOptions: categoryOptions,
                                    allocations: allocations
                                )
                            } label: {
                                BudgetCategoryRow(category: category, total: totalBudget)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(L10n.Budget.summary)
        .navigationBarTitleDisplayMode(.large)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Budget.totalBudget)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
            Text(CurrencyFormatter.rupiah(metrics.totalBudget))
                .font(AppFont.medium(22))
                .foregroundStyle(AppTheme.sageDark)

            HStack(spacing: 10) {
                summaryMetric(title: L10n.Budget.spent, amount: metrics.spent, percent: metrics.percent(metrics.spent), tint: AppTheme.sageDark)
                summaryMetric(title: L10n.Budget.commitment, amount: metrics.commitment, percent: metrics.percent(metrics.commitment), tint: AppTheme.gold)
                summaryMetric(title: L10n.Budget.remainingShort, amount: metrics.remaining, percent: metrics.percent(metrics.remaining), tint: AppTheme.ink.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func summaryMetric(title: String, amount: Double, percent: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
            Text(CurrencyFormatter.rupiahShort(amount))
                .font(AppFont.medium(13))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(percent)%")
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct BudgetCategoriesView: View {
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    private let horizontalPadding: CGFloat = 20

    let categories: [BudgetCategory]
    let allocations: [BudgetCategoryAllocation]
    let totalBudget: Double
    let schedules: [PaymentSchedule]
    let onReload: () async -> Void
    var categoryOptions: [BudgetPaymentCategory] = []

    private var budgetDefaults: BudgetDefaults {
        categoriesStore.defaults
    }

    @State private var editingCategory: BudgetCategory?

    private var allocationMap: [String: BudgetCategoryAllocation] {
        BudgetCategory.allocationsMap(from: allocations)
    }

    private var totalPlannedAllocation: Double {
        categories.reduce(0) { $0 + $1.plannedAllocation }
    }

    private var totalRecordedAcrossCategories: Double {
        categories.reduce(0) { $0 + $1.totalRecorded }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if !categories.isEmpty {
                        allocationSummary
                    }

                    if categories.isEmpty {
                        ContentUnavailableView(
                            L10n.Budget.noCategories,
                            systemImage: "square.grid.2x2",
                            description: Text(L10n.Budget.categoriesLoadError)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(categories) { category in
                                categoryCard(for: category)
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(L10n.Budget.categoriesTitle)
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onReload() }
        .navigationDestination(item: $editingCategory) { category in
            EditCategoryAllocationView(
                category: category,
                allocation: allocationMap[category.id]
            ) {
                await onReload()
            }
        }
    }

    private func categoryCard(for category: BudgetCategory) -> some View {
        HStack(spacing: 10) {
            NavigationLink {
                BudgetCategoryDetailView(
                    categoryId: category.id,
                    schedules: schedules,
                    totalBudget: totalBudget,
                    onReload: onReload,
                    categoryOptions: categoryOptions,
                    allocations: allocations
                )
            } label: {
                BudgetCategoryRow(category: category, total: totalBudget)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                editingCategory = category
            } label: {
                Image(systemName: category.hasPlannedAllocation ? "pencil.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(category.hasPlannedAllocation ? L10n.Budget.editAllocationNamed(category.name) : L10n.Budget.setAllocationNamed(category.name))
        }
    }

    private var allocationSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Budget.totalCategoryAllocation)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.5))

            HStack(alignment: .firstTextBaseline) {
                Text(CurrencyFormatter.rupiah(totalPlannedAllocation))
                    .font(AppFont.medium(20))
                    .foregroundStyle(AppTheme.sageDark)

                if totalBudget > 0 {
                    Text(L10n.Budget.fromTotal(CurrencyFormatter.rupiah(totalBudget)))
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }
            }

            if totalBudget > 0 {
                BudgetBar(
                    progress: min(totalPlannedAllocation / totalBudget, 1),
                    color: AppTheme.gold
                )
                .frame(height: 6)
            }

            if totalPlannedAllocation == 0, totalRecordedAcrossCategories > 0 {
                Text(L10n.Budget.allocationPlanEmpty(CurrencyFormatter.rupiah(totalRecordedAcrossCategories)))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.gold.opacity(0.9))
            } else {
                Text(L10n.Budget.tapToAllocate)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }
}

struct PaymentScheduleRow: View {
    let schedule: PaymentSchedule

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(schedule.title)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text(CurrencyFormatter.rupiah(schedule.amount))
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
            }

            HStack(spacing: 8) {
                if let vendor = schedule.vendorName, !vendor.isEmpty {
                    Text(vendor)
                }
                if let category = schedule.categoryLabel {
                    Text(category)
                }
            }
            .font(AppFont.regular(12))
            .foregroundStyle(.secondary)
            .lineLimit(1)

            HStack {
                Text(schedule.displayStatusLabel)
                    .font(AppFont.regular(11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor(schedule.displayStatusColorName).opacity(0.15))
                    .foregroundStyle(statusColor(schedule.displayStatusColorName))
                    .clipShape(Capsule())

                if schedule.isPaid, let paidAtDisplay = schedule.paidAtDisplay {
                    Text(L10n.Budget.paidOn(paidAtDisplay))
                        .font(AppFont.regular(11))
                        .foregroundStyle(.secondary)
                } else if let dueDate = schedule.dueDate, !dueDate.isEmpty {
                    Text(L10n.Budget.dueOn(dueDate))
                        .font(AppFont.regular(11))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "paid": return .green
        case "overdue": return .red
        default: return .orange
        }
    }
}

struct EditTotalBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoriesStore = BudgetCategoriesStore.shared

    let budget: WeddingBudget
    let onSaved: (WeddingBudget) -> Void

    @State private var totalBudgetText = ""
    @State private var notes = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        budgetInfoCard

                        formSection(title: L10n.Budget.totalBudget) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 12) {
                                    fieldIcon("banknote")

                                    TextField(L10n.Budget.enterAmount, text: $totalBudgetText)
                                        .font(AppFont.regular(14))
                                        .foregroundStyle(AppTheme.ink)
                                        .keyboardType(.numberPad)
                                        .onChange(of: totalBudgetText) { _, newValue in
                                            totalBudgetText = Self.formatAmountInput(newValue)
                                        }

                                    Text(amountPreview)
                                        .font(AppFont.medium(13))
                                        .foregroundStyle(AppTheme.sageDark)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }

                                Text(L10n.Budget.ceilingHint)
                                    .font(AppFont.regular(11))
                                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                            }
                        }

                        formSection(title: L10n.Common.notes) {
                            HStack(alignment: .top, spacing: 12) {
                                fieldIcon("note.text")

                                TextField(L10n.Budget.budgetNotesPlaceholder, text: $notes, axis: .vertical)
                                    .font(AppFont.regular(14))
                                    .foregroundStyle(AppTheme.ink)
                                    .lineLimit(3...5)
                            }
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
            populateIfNeeded()
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
                Text(L10n.Budget.setBudget)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Budget.setBudgetSub)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Color.clear.frame(width: 42, height: 42)
        }
        .padding(.bottom, 4)
    }

    private var budgetInfoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 44, height: 44)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Budget.spendingPlan)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Budget.spendingPlanInfo)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
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
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
    }

    private func fieldIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(AppTheme.ink.opacity(0.45))
            .frame(width: 36, height: 36)
            .background(AppTheme.mist.opacity(0.65), in: Circle())
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(L10n.Budget.saveBudget)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSave ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSave || isLoading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private var amountPreview: String {
        guard let amount = parsedAmount else { return "Rp 0" }
        return CurrencyFormatter.rupiah(amount)
    }

    private var canSave: Bool {
        parsedAmount != nil
    }

    private var parsedAmount: Double? {
        let digits = totalBudgetText.filter(\.isNumber)
        guard !digits.isEmpty, let value = Double(digits) else { return nil }
        return value
    }

    private func populateIfNeeded() {
        if budget.totalBudget > 0 {
            totalBudgetText = Self.formatAmountInput(String(Int(budget.totalBudget.rounded())))
        }
        notes = budget.notes ?? ""
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

    private func save() async {
        guard let amount = parsedAmount else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [
            "total_budget": amount,
            "currency": budget.currency ?? categoriesStore.defaults.currency,
        ]

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNotes.isEmpty {
            payload["notes"] = trimmedNotes
        }

        do {
            let envelope: Envelope<WeddingBudget> = try await APIClient.shared.request(
                "wedding-budget",
                method: "PUT",
                json: payload
            )
            onSaved(envelope.data)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct BudgetReportShareView: View {
    let metrics: BudgetSummaryMetrics
    let categories: [BudgetCategory]
    let incomingTotal: Double

    @Environment(\.dismiss) private var dismiss
    @State private var reportFileURL: URL?

    private var reportText: String {
        metrics.reportText(categories: categories, incomingTotal: incomingTotal)
    }

    private var sortedCategories: [BudgetCategory] {
        categories.sorted { lhs, rhs in
            if lhs.totalRecorded == rhs.totalRecorded {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.totalRecorded > rhs.totalRecorded
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            overviewSection

                            if metrics.isOverBudget {
                                overBudgetBanner
                            }

                            categoriesSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }

                    shareBar
                }
            }
            .navigationTitle(L10n.Budget.report)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let reportFileURL {
                        ShareLink(item: reportFileURL) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                reportFileURL = writeReportFile()
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.Budget.reportOverview)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.5))

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                reportMetricCard(
                    title: L10n.Budget.totalBudget,
                    amount: metrics.totalBudget,
                    subtitle: nil,
                    tint: AppTheme.sageDark
                )
                reportMetricCard(
                    title: L10n.Budget.spent,
                    amount: metrics.spent,
                    subtitle: "\(metrics.percent(metrics.spent))%",
                    tint: AppTheme.sage
                )
                reportMetricCard(
                    title: L10n.Budget.commitment,
                    amount: metrics.commitment,
                    subtitle: "\(metrics.percent(metrics.commitment))%",
                    tint: AppTheme.gold
                )
                reportMetricCard(
                    title: metrics.isOverBudget ? L10n.Budget.overBudget : L10n.Budget.remaining,
                    amount: metrics.isOverBudget ? metrics.overspend : metrics.remaining,
                    subtitle: metrics.isOverBudget
                        ? L10n.Budget.overBudgetBy(CurrencyFormatter.rupiahShort(metrics.overspend))
                        : "\(metrics.percent(metrics.remaining))%",
                    tint: metrics.isOverBudget ? Color.red.opacity(0.75) : AppTheme.ink.opacity(0.55)
                )
            }

            HStack {
                Text(L10n.Budget.incoming)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                Spacer()
                Text(CurrencyFormatter.rupiah(incomingTotal))
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var overBudgetBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.red.opacity(0.8))

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Budget.overBudget)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(L10n.Budget.overBudgetBy(CurrencyFormatter.rupiah(metrics.overspend)))
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.red.opacity(0.15), lineWidth: 1)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Budget.reportCategories)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.5))

            if sortedCategories.isEmpty {
                Text(L10n.Budget.noExpenses)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(sortedCategories) { category in
                        reportCategoryRow(category)
                    }
                }
            }
        }
    }

    private func reportCategoryRow(_ category: BudgetCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.sage.opacity(0.12), in: Circle())

                Text(category.name)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)

                Spacer()

                Text(CurrencyFormatter.rupiah(category.spent))
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.sageDark)
            }

            HStack(spacing: 12) {
                reportMetaChip(
                    label: L10n.Budget.reportRecordedLabel,
                    value: CurrencyFormatter.rupiah(category.totalRecorded)
                )
                reportMetaChip(
                    label: L10n.Budget.reportAllocationLabel,
                    value: category.hasPlannedAllocation
                        ? CurrencyFormatter.rupiah(category.plannedAllocation)
                        : L10n.Budget.notSetShort
                )
            }

            if category.commitment > 0 {
                Text(L10n.Budget.commitmentAmount(CurrencyFormatter.rupiah(category.commitment)))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.gold.opacity(0.9))
            }

            BudgetBar(
                progress: category.hasPlannedAllocation
                    ? category.usageAgainstPlanRatio
                    : category.paidRecordedRatio,
                color: AppTheme.sage
            )
            .frame(height: 5)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func reportMetaChip(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
            Text(value)
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.ink.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reportMetricCard(
        title: String,
        amount: Double,
        subtitle: String?,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
                .lineLimit(1)

            Text(CurrencyFormatter.rupiah(amount))
                .font(AppFont.medium(15))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let subtitle {
                Text(subtitle)
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.lightSage.opacity(0.35), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var shareBar: some View {
        Group {
            if let reportFileURL {
                ShareLink(item: reportFileURL) {
                    Label(L10n.Budget.downloadShareReport, systemImage: "square.and.arrow.up")
                        .font(AppFont.medium(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(.ultraThinMaterial)
            }
        }
    }

    private func writeReportFile() -> URL? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        let fileName = "Laporan-Budget-\(formatter.string(from: Date())).txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try reportText.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
