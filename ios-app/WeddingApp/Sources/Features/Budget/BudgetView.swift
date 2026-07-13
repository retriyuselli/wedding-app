import SwiftUI

struct BudgetView: View {
    @ObservedObject private var categoriesStore = BudgetCategoriesStore.shared
    @State private var budget = WeddingBudget(id: nil, totalBudget: 0, currency: nil, notes: "")
    @State private var summary: WeddingBudgetSummary?
    @State private var schedules: [PaymentSchedule] = []
    @State private var incomingPayments: [IncomingPayment] = []
    @State private var categoryAllocations: [BudgetCategoryAllocation] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showEditBudget = false
    @State private var showAddExpense = false
    @State private var showCategories = false
    @State private var showReport = false
    @State private var showSummaryDetail = false
    @State private var showIncomingPayments = false
    @State private var showExpenseFilter = false
    @State private var expenseStatusFilter: String? = nil
    @State private var draftExpenseStatusFilter: String? = nil
    @State private var selectedCategory: BudgetCategory?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var editingScheduleRoute: EditableScheduleRoute?
    @State private var editingIncomingPayment: IncomingPayment?

    @FocusState private var isSearchFocused: Bool

    private var trimmedSearchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredSchedules: [PaymentSchedule] {
        guard !trimmedSearchQuery.isEmpty else { return [] }
        return schedules.filter { $0.matchesSearch(trimmedSearchQuery) }
    }

    private var filteredCategories: [BudgetCategory] {
        guard !trimmedSearchQuery.isEmpty else { return [] }
        return allCategories.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearchQuery) }
    }

    private var filteredIncomingPayments: [IncomingPayment] {
        guard !trimmedSearchQuery.isEmpty else { return [] }
        return incomingPayments.filter { $0.matchesSearch(trimmedSearchQuery) }
    }

    private var hasSearchResults: Bool {
        !filteredSchedules.isEmpty || !filteredCategories.isEmpty || !filteredIncomingPayments.isEmpty
    }

    private var categories: [BudgetCategory] {
        BudgetCategory.build(
            from: schedules,
            options: categoriesStore.categories,
            allocations: categoryAllocations,
            defaults: categoriesStore.defaults
        )
    }

    private var allCategories: [BudgetCategory] {
        BudgetCategory.buildAll(
            from: schedules,
            options: categoriesStore.categories,
            allocations: categoryAllocations,
            defaults: categoriesStore.defaults
        )
    }

    private var metrics: BudgetSummaryMetrics {
        BudgetSummaryMetrics.resolve(
            budget: budget,
            summary: summary,
            categories: categories
        )
    }

    private var incomingMetrics: IncomingPaymentMetrics {
        IncomingPaymentMetrics.resolve(
            payments: incomingPayments,
            summary: summary,
            pendingStatus: categoriesStore.defaultIncomingPaymentStatus
        )
    }

    private var totalBudgetCaption: String {
        if budget.totalBudget <= 0 {
            return L10n.Budget.tapToSetTotal
        }

        if let planPercent = summary?.planCoveragePercent {
            return L10n.Budget.allocationOfPlan(planPercent)
        }

        let plannedTotal = categoryAllocations.reduce(0) { $0 + $1.allocatedAmount }
        if plannedTotal > 0 {
            let percent = Int(min(100, round(plannedTotal / budget.totalBudget * 100)))
            return L10n.Budget.allocationOfPlan(percent)
        }

        return L10n.Budget.totalPlan
    }

    private var recentIncomingPayments: [IncomingPayment] {
        Array(incomingPayments.prefix(2))
    }

    private var incomingTotal: Double {
        incomingMetrics.totalAll
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if isSearching {
                            searchBar
                        }
                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                        }
                        if isSearching {
                            searchResultsSection
                        } else {
                            totalCard
                            statsRow
                            if expenseStatusFilter != nil {
                                activeExpenseFilterChip
                            }
                            incomingPaymentsCard
                            summaryHeader
                            summarySection
                            actionBar
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .overlay {
                    if isLoading && schedules.isEmpty && budget.totalBudget == 0 {
                        ProgressView()
                    }
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
            .navigationDestination(isPresented: $showEditBudget) {
                EditTotalBudgetView(budget: budget) { updated in
                    budget = updated
                    Task { await load() }
                }
            }
            .navigationDestination(isPresented: $showAddExpense) {
                AddExpenseView(schedule: nil) {
                    await load()
                }
            }
            .navigationDestination(isPresented: $showCategories) {
                BudgetCategoriesView(
                    categories: allCategories,
                    allocations: categoryAllocations,
                    totalBudget: metrics.totalBudget,
                    schedules: schedules,
                    onReload: { await load() },
                    categoryOptions: categoriesStore.categories
                )
            }
            .sheet(isPresented: $showReport) {
                BudgetReportShareView(
                    metrics: metrics,
                    categories: categories,
                    incomingTotal: incomingTotal
                )
            }
            .sheet(isPresented: $showExpenseFilter) {
                BudgetExpenseFilterSheet(
                    selection: $draftExpenseStatusFilter,
                    onApply: {
                        expenseStatusFilter = draftExpenseStatusFilter
                        showExpenseFilter = false
                        Task { await load() }
                    },
                    onReset: {
                        draftExpenseStatusFilter = nil
                        expenseStatusFilter = nil
                        showExpenseFilter = false
                        Task { await load() }
                    }
                )
            }
            .navigationDestination(isPresented: $showIncomingPayments) {
                IncomingPaymentsView {
                    await load()
                }
            }
            .navigationDestination(isPresented: $showSummaryDetail) {
                BudgetSummaryDetailView(
                    totalBudget: metrics.totalBudget,
                    schedules: schedules,
                    onReload: { await load() },
                    categoryOptions: categoriesStore.categories,
                    allocations: categoryAllocations
                )
            }
            .navigationDestination(item: $selectedCategory) { category in
                BudgetCategoryDetailView(
                    categoryId: category.id,
                    schedules: schedules,
                    totalBudget: metrics.totalBudget,
                    onReload: { await load() },
                    categoryOptions: categoriesStore.categories,
                    allocations: categoryAllocations
                )
            }
            .navigationDestination(item: $editingScheduleRoute) { route in
                AddExpenseView(
                    schedule: schedules.first(where: { $0.id == route.id })
                ) {
                    await load()
                    editingScheduleRoute = nil
                }
            }
            .navigationDestination(item: $editingIncomingPayment) { payment in
                AddIncomingPaymentView(payment: payment) {
                    await load()
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Budget.title)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Budget.subtitle)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                        isSearchFocused = true
                    }
                } label: {
                    circleButton("magnifyingglass", isActive: isSearching)
                }
                .buttonStyle(.plain)

                circleButton("slider.horizontal.3", isActive: expenseStatusFilter != nil) {
                    draftExpenseStatusFilter = expenseStatusFilter
                    showExpenseFilter = true
                }
            }
            .padding(.top, 4)
        }
        .frame(height: 96, alignment: .top)
        .padding(.top, 8)
    }

    private func circleButton(_ icon: String, isActive: Bool = false, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(isActive ? AppTheme.sageDark : AppTheme.ink.opacity(0.72))
                .frame(width: 42, height: 42)
                .background((isActive ? AppTheme.lightSage : .white).opacity(0.86), in: Circle())
                .overlay {
                    Circle()
                        .stroke(isActive ? AppTheme.sageDark.opacity(0.25) : .clear, lineWidth: 1)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))

                TextField(L10n.Budget.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(15))
                    .foregroundStyle(AppTheme.ink)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
                    .submitLabel(.search)

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
                    .stroke(isSearchFocused ? AppTheme.sageDark.opacity(0.35) : AppTheme.sage.opacity(0.18), lineWidth: isSearchFocused ? 1.5 : 1)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSearching = false
                    searchText = ""
                    isSearchFocused = false
                }
            } label: {
                Text(L10n.Common.cancel)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var searchResultsSection: some View {
        if trimmedSearchQuery.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.sage.opacity(0.5))
                Text(L10n.Budget.searchEmptyTitle)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Budget.searchEmptySub)
                    .font(AppFont.regular(12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 16)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else if !hasSearchResults {
            ContentUnavailableView(
                L10n.Budget.searchNotFound,
                systemImage: "magnifyingglass",
                description: Text(L10n.Budget.searchNoResults(trimmedSearchQuery))
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                if !filteredSchedules.isEmpty {
                    searchSectionHeader(
                        title: L10n.Budget.expenses,
                        count: filteredSchedules.count
                    )

                    VStack(spacing: 10) {
                        ForEach(filteredSchedules) { schedule in
                            Button {
                                editingScheduleRoute = EditableScheduleRoute(id: schedule.id)
                            } label: {
                                searchExpenseCard(schedule)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !filteredCategories.isEmpty {
                    searchSectionHeader(
                        title: L10n.Budget.categories,
                        count: filteredCategories.count
                    )

                    VStack(spacing: 10) {
                        ForEach(filteredCategories) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                BudgetCategoryRow(category: category, total: metrics.totalBudget)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !filteredIncomingPayments.isEmpty {
                    searchSectionHeader(
                        title: L10n.Budget.incoming,
                        count: filteredIncomingPayments.count
                    )

                    VStack(spacing: 10) {
                        ForEach(filteredIncomingPayments) { payment in
                            Button {
                                editingIncomingPayment = payment
                            } label: {
                                IncomingPaymentRow(payment: payment)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func searchSectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(AppFont.medium(16))
                .foregroundStyle(AppTheme.sageDark)
            Spacer()
            Text("\(count)")
                .font(AppFont.regular(12))
                .foregroundStyle(.secondary)
        }
    }

    private func searchExpenseCard(_ schedule: PaymentSchedule) -> some View {
        PaymentScheduleRow(schedule: schedule)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 5)
    }

    private var adaptiveTotalBudgetFontSize: CGFloat {
        switch CurrencyFormatter.rupiah(metrics.totalBudget).count {
        case 17...:
            return 16
        case 15...:
            return 18
        default:
            return 20
        }
    }

    private var totalCard: some View {
        Button {
            showEditBudget = true
        } label: {
            VStack(spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Budget.totalBudget)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text(CurrencyFormatter.rupiah(metrics.totalBudget))
                            .font(AppFont.medium(adaptiveTotalBudgetFontSize))
                            .foregroundStyle(AppTheme.sageDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text(totalBudgetCaption)
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(L10n.Budget.spent)
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text("\(metrics.percent(metrics.spent))%")
                            .font(AppFont.medium(26))
                            .foregroundStyle(AppTheme.sageDark)
                        BudgetBar(
                            progress: metrics.totalBudget == 0 ? 0 : metrics.spent / metrics.totalBudget,
                            color: AppTheme.sageDark
                        )
                        .frame(height: 6)
                        Text(CurrencyFormatter.rupiah(metrics.spent))
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageDark)
                    }
                    .frame(width: 140)
                }

                HStack(spacing: 18) {
                    BudgetDonut(
                        segments: [
                            (metrics.spent, AppTheme.sageDark),
                            (metrics.remaining, AppTheme.gold),
                            (metrics.commitment, AppTheme.mist),
                        ]
                    )
                    .frame(width: 96, height: 96)

                    VStack(alignment: .leading, spacing: 10) {
                        donutLegend(color: AppTheme.sageDark, title: L10n.Budget.spent, amount: metrics.spent, percent: metrics.percent(metrics.spent))
                        donutLegend(color: AppTheme.gold, title: L10n.Budget.remaining, amount: metrics.remaining, percent: metrics.percent(metrics.remaining))
                        donutLegend(color: AppTheme.mist, title: L10n.Budget.commitment, amount: metrics.commitment, percent: metrics.percent(metrics.commitment))
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 6) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.sageDark)
                        Text(L10n.Budget.remaining)
                            .font(AppFont.regular(10))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text(CurrencyFormatter.rupiah(metrics.remaining))
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(18)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func donutLegend(color: Color, title: String, amount: Double, percent: Int) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 9, height: 9)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.65))
                Text("\(CurrencyFormatter.rupiah(amount)) (\(percent)%)")
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(icon: "list.bullet.rectangle", tint: AppTheme.sageDark, label: L10n.Budget.totalBudget, amount: metrics.totalBudget, sub: nil)
            statCard(icon: "checkmark.circle.fill", tint: AppTheme.sageDark, label: L10n.Budget.spent, amount: metrics.spent, sub: "\(metrics.percent(metrics.spent))%")
            statCard(icon: "hourglass", tint: AppTheme.gold, label: L10n.Budget.commitment, amount: metrics.commitment, sub: "\(metrics.percent(metrics.commitment))%")
            statCard(icon: "wallet.pass", tint: AppTheme.ink.opacity(0.45), label: L10n.Budget.remaining, amount: metrics.remaining, sub: "\(metrics.percent(metrics.remaining))%")
        }
    }

    private func statCard(icon: String, tint: Color, label: String, amount: Double, sub: String?) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(AppTheme.sage.opacity(0.10), in: Circle())

            Text(label)
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(CurrencyFormatter.rupiahShort(amount))
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(sub ?? "")
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.ink.opacity(sub != nil ? 0.4 : 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 6)
        .padding(.vertical, 14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 5)
    }

    private var activeExpenseFilterChip: some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.sageDark)

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Budget.filterActive)
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
                Text(expenseStatusFilterLabel)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
            }

            Spacer(minLength: 8)

            Button {
                expenseStatusFilter = nil
                draftExpenseStatusFilter = nil
                Task { await load() }
            } label: {
                Text(L10n.Budget.clearFilter)
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.lightSage.opacity(0.65), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.18), lineWidth: 1)
        }
    }

    private var expenseStatusFilterLabel: String {
        switch expenseStatusFilter {
        case "paid":
            return L10n.Budget.paid
        case "pending":
            return L10n.Budget.unpaid
        case "overdue":
            return L10n.Budget.overdue
        default:
            return L10n.Common.all
        }
    }

    private var incomingPaymentsCard: some View {
        Button {
            showIncomingPayments = true
        } label: {
            IncomingPaymentsSummaryCard(
                metrics: incomingMetrics,
                recentPayments: recentIncomingPayments
            )
        }
        .buttonStyle(.plain)
    }

    private var summaryHeader: some View {
        Button {
            showSummaryDetail = true
        } label: {
            HStack {
                Text(L10n.Budget.summary)
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.sageDark)
                Spacer()
                Label(L10n.Common.seeDetail, systemImage: "chevron.right")
                    .font(AppFont.regular(12))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var summarySection: some View {
        if categories.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.sage.opacity(0.5))
                Text(L10n.Budget.noExpenses)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.Budget.noExpensesSub)
                    .font(AppFont.regular(12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 16)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            LazyVStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        BudgetCategoryRow(category: category, total: metrics.totalBudget)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            Button {
                showAddExpense = true
            } label: {
                actionItem(icon: "plus", title: L10n.Budget.addExpense, sub: L10n.Budget.addExpenseSub)
            }
            .buttonStyle(.plain)

            Divider().frame(height: 34)

            Button {
                showCategories = true
            } label: {
                actionItem(icon: "square.grid.2x2", title: L10n.Budget.categoriesAction, sub: L10n.Budget.categoriesActionSub)
            }
            .buttonStyle(.plain)

            Divider().frame(height: 34)

            Button {
                showReport = true
            } label: {
                actionItem(icon: "chart.bar", title: L10n.Budget.report, sub: L10n.Budget.reportSub)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 12, y: 6)
        .padding(.top, 4)
    }

    private func actionItem(icon: String, title: String, sub: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
            Text(title)
                .font(AppFont.medium(11))
                .foregroundStyle(AppTheme.ink.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(sub)
                .font(AppFont.regular(9))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            await categoriesStore.loadIfNeeded()

            async let budgetEnvelope: NullableEnvelope<WeddingBudget> = APIClient.shared.request("wedding-budget")
            let scheduleQueryItems = expenseStatusFilter.map { [URLQueryItem(name: "status", value: $0)] }
            async let scheduleEnvelope: Envelope<[PaymentSchedule]> = APIClient.shared.request(
                "wedding-payment-schedules",
                queryItems: scheduleQueryItems
            )

            let budgetResult = try await budgetEnvelope.data
            budget = budgetResult ?? WeddingBudget(
                id: nil,
                totalBudget: 0,
                currency: categoriesStore.defaults.currency,
                notes: ""
            )
            schedules = try await scheduleEnvelope.data
        } catch {
            guard !error.isRequestCancelled else {
                return
            }

            errorMessage = error.userFacingMessage
        }

        do {
            let summaryEnvelope: Envelope<WeddingBudgetSummary> = try await APIClient.shared.request("wedding-budget/summary")
            summary = summaryEnvelope.data
        } catch {
            if !(error.isRequestCancelled) {
                summary = nil
            }
        }

        do {
            let allocationEnvelope: Envelope<[BudgetCategoryAllocation]> = try await APIClient.shared.request("wedding-budget-category-allocations")
            categoryAllocations = allocationEnvelope.data
        } catch {
            categoryAllocations = []
        }

        do {
            let incomingEnvelope: Envelope<[IncomingPayment]> = try await APIClient.shared.request("wedding-incoming-payments")
            incomingPayments = incomingEnvelope.data
        } catch {
            incomingPayments = []
        }
    }
}

private struct BudgetExpenseFilterSheet: View {
    @Binding var selection: String?
    let onApply: () -> Void
    let onReset: () -> Void

    private let options: [(id: String?, label: String)] = [
        (nil, L10n.Common.all),
        ("paid", L10n.Budget.paid),
        ("pending", L10n.Budget.unpaid),
        ("overdue", L10n.Budget.overdue),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.Budget.filterExpenses)
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                        .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button {
                                selection = option.id
                            } label: {
                                HStack {
                                    Text(option.label)
                                        .font(AppFont.medium(15))
                                        .foregroundStyle(AppTheme.ink)
                                    Spacer()
                                    if selection == option.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(AppTheme.sageDark)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)

                            if index < options.count - 1 {
                                Divider().opacity(0.35)
                            }
                        }
                    }
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Button(action: onReset) {
                            Text(L10n.Common.reset)
                                .font(AppFont.medium(15))
                                .foregroundStyle(AppTheme.sageDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Button(action: onApply) {
                            Text(L10n.Common.apply)
                                .font(AppFont.medium(15))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationTitle(L10n.Common.filter)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
