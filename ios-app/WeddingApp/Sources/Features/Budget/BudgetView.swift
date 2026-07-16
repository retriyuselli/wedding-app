import SwiftUI

struct BudgetView: View {
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared
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
    @State private var showPaywall = false
    @State private var expenseStatusFilter: String? = nil
    @State private var draftExpenseStatusFilter: String? = nil
    @State private var selectedCategory: BudgetCategory?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var editingScheduleRoute: EditableScheduleRoute?
    @State private var editingIncomingPayment: IncomingPayment?

    @FocusState private var isSearchFocused: Bool

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

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
                .blur(radius: isPremium ? 0 : 2.5)
                .opacity(isPremium ? 1 : 0.82)
                .overlay {
                    if isLoading && schedules.isEmpty && budget.totalBudget == 0 && isPremium {
                        ProgressView()
                    }
                }

                if !isPremium {
                    VStack(spacing: 14) {
                        ForEach(premium.sharedBudgetAccess) { access in
                            NavigationLink {
                                SharedUserDetailView(userId: access.userId)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(AppTheme.iconOnChip)
                                        .frame(width: 42, height: 42)
                                        .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(L10n.Premium.partnerBudgetCta)
                                            .font(AppFont.medium(14))
                                            .foregroundStyle(AppTheme.titleOnGlass)
                                        Text(L10n.Premium.partnerAccessSub(access.name))
                                            .font(AppFont.regular(12))
                                            .foregroundStyle(AppTheme.inkMuted(0.65))
                                            .lineLimit(2)
                                    }

                                    Spacer(minLength: 8)

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AppTheme.inkMuted(0.45))
                                }
                                .padding(14)
                                .premiumGlassCard(cornerRadius: 18)
                            }
                            .buttonStyle(.plain)
                        }

                        PremiumLockedOverlay {
                            showPaywall = true
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await PremiumStore.shared.refreshServerEntitlement()
                if isPremium {
                    await load()
                } else {
                    loadPreview()
                }
            }
            .refreshable {
                if isPremium {
                    await load()
                } else {
                    loadPreview()
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
                        loadPreview()
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onUnlocked: {
                    Task { await load() }
                })
                .environmentObject(session)
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

    private func runPremiumOrPaywall(_ action: @escaping () -> Void) {
        PremiumGate.presentOrRun(session: session, showPaywall: $showPaywall, action: action)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Budget.title)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Budget.subtitle)
                    .lineSpacing(2)
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                Button {
                    runPremiumOrPaywall {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearching = true
                            isSearchFocused = true
                        }
                    }
                } label: {
                    circleButton("magnifyingglass", isActive: isSearching)
                }
                .buttonStyle(.plain)

                circleButton("slider.horizontal.3", isActive: expenseStatusFilter != nil) {
                    runPremiumOrPaywall {
                        draftExpenseStatusFilter = expenseStatusFilter
                        showExpenseFilter = true
                    }
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
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isActive ? AppTheme.labelOnLightSurface : AppTheme.iconOnChip)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(isActive ? AppTheme.selectedChipFill : AppTheme.iconChipFill)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(
                            isActive ? AppTheme.sage.opacity(0.35) : AppTheme.iconChipStroke,
                            lineWidth: 1
                        )
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
                    .font(.system(size: 15, weight: .medium))
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
            .padding(.vertical, 12)
            .premiumGlassCard(cornerRadius: 16)

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
            .premiumGlassCard(cornerRadius: 20)
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
                                runPremiumOrPaywall {
                                    editingScheduleRoute = EditableScheduleRoute(id: schedule.id)
                                }
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
                                runPremiumOrPaywall {
                                    selectedCategory = category
                                }
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
            .premiumGlassCard(cornerRadius: 18)
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
            runPremiumOrPaywall {
                showEditBudget = true
            }
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
            .premiumGlassCard(cornerRadius: 32)
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
        .premiumGlassCard(cornerRadius: 20)
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
        .premiumGlassCard(cornerRadius: 16)
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
            runPremiumOrPaywall {
                showIncomingPayments = true
            }
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
            runPremiumOrPaywall {
                showSummaryDetail = true
            }
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
            .premiumGlassCard(cornerRadius: 20)
        } else {
            LazyVStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        runPremiumOrPaywall {
                            selectedCategory = category
                        }
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
                runPremiumOrPaywall {
                    showAddExpense = true
                }
            } label: {
                actionItem(icon: "plus", title: L10n.Budget.addExpense, sub: L10n.Budget.addExpenseSub)
            }
            .buttonStyle(.plain)

            Divider().frame(height: 34)

            Button {
                runPremiumOrPaywall {
                    showCategories = true
                }
            } label: {
                actionItem(icon: "square.grid.2x2", title: L10n.Budget.categoriesAction, sub: L10n.Budget.categoriesActionSub)
            }
            .buttonStyle(.plain)

            Divider().frame(height: 34)

            Button {
                runPremiumOrPaywall {
                    showReport = true
                }
            } label: {
                actionItem(icon: "chart.bar", title: L10n.Budget.report, sub: L10n.Budget.reportSub)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .premiumGlassCard(cornerRadius: 22)
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

    private func loadPreview() {
        errorMessage = nil
        budget = WeddingBudget(id: -1, totalBudget: 150_000_000, currency: "IDR", notes: nil)
        schedules = decodePreview("""
        [
          {"id":-1,"title":"DP Venue","vendor_name":"Garden Hall","category":"venue","category_label":"Venue","amount":35000000,"due_date":"2026-08-01","status":"paid","status_label":"Lunas","sort_order":1},
          {"id":-2,"title":"Pelunasan Catering","vendor_name":"Sari Rasa","category":"catering","category_label":"Catering","amount":42000000,"due_date":"2026-09-15","status":"pending","status_label":"Belum lunas","sort_order":2},
          {"id":-3,"title":"Makeup & Wardrobe","vendor_name":"Glam Studio","category":"attire","category_label":"Busana","amount":18000000,"due_date":"2026-09-01","status":"pending","status_label":"Belum lunas","sort_order":3},
          {"id":-4,"title":"Dokumentasi","vendor_name":"Lens & Light","category":"documentation","category_label":"Dokumentasi","amount":12000000,"due_date":"2026-08-20","status":"overdue","status_label":"Terlambat","sort_order":4}
        ]
        """) ?? []
        categoryAllocations = decodePreview("""
        [
          {"id":-1,"category":"venue","category_label":"Venue","allocated_amount":50000000,"notes":null},
          {"id":-2,"category":"catering","category_label":"Catering","allocated_amount":45000000,"notes":null},
          {"id":-3,"category":"attire","category_label":"Busana","allocated_amount":25000000,"notes":null},
          {"id":-4,"category":"documentation","category_label":"Dokumentasi","allocated_amount":15000000,"notes":null}
        ]
        """) ?? []
        incomingPayments = decodePreview("""
        [
          {"id":-1,"bank_name":"BCA","amount":10000000,"transfer_date":"2026-07-01","sender_name":"Keluarga Mempelai","description":"Hadiah awal","reference_number":null,"proof_url":null,"status":"confirmed","status_label":"Dikonfirmasi","confirmed_at":null,"rejection_reason":null,"notes":null},
          {"id":-2,"bank_name":"Mandiri","amount":5000000,"transfer_date":"2026-07-10","sender_name":"Sahabat","description":"Kontribusi","reference_number":null,"proof_url":null,"status":"pending","status_label":"Menunggu","confirmed_at":null,"rejection_reason":null,"notes":null}
        ]
        """) ?? []
        summary = nil
    }

    private func decodePreview<T: Decodable>(_ json: String) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(T.self, from: Data(json.utf8))
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
                    .premiumGlassCard(cornerRadius: 18)

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
