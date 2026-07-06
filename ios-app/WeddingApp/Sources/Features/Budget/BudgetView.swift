import SwiftUI

struct BudgetView: View {
    @State private var budget = WeddingBudget(id: nil, totalBudget: 0, currency: "IDR", notes: "")
    @State private var schedules: [PaymentSchedule] = []
    @State private var incomingPayments: [IncomingPayment] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showEditBudget = false
    @State private var showAddExpense = false
    @State private var showCategories = false
    @State private var showReport = false
    @State private var showSummaryDetail = false
    @State private var selectedCategory: BudgetCategory?

    private var categories: [BudgetCategory] {
        BudgetCategory.build(from: schedules)
    }

    private var metrics: BudgetSummaryMetrics {
        BudgetSummaryMetrics.make(budget: budget, categories: categories)
    }

    private var incomingTotal: Double {
        incomingPayments.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                        }
                        totalCard
                        statsRow
                        summaryHeader
                        summarySection
                        actionBar
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
            .sheet(isPresented: $showEditBudget) {
                EditTotalBudgetSheet(budget: budget) { updated in
                    budget = updated
                }
            }
            .navigationDestination(isPresented: $showAddExpense) {
                AddExpenseView(schedule: nil) {
                    await load()
                }
            }
            .sheet(isPresented: $showCategories) {
                NavigationStack {
                    BudgetCategoriesView(
                        categories: categories,
                        totalBudget: metrics.totalBudget,
                        schedules: schedules,
                        onReload: { await load() }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Tutup") { showCategories = false }
                        }
                    }
                }
            }
            .sheet(isPresented: $showReport) {
                BudgetReportShareView(
                    reportText: metrics.reportText(categories: categories, incomingTotal: incomingTotal)
                )
            }
            .navigationDestination(isPresented: $showSummaryDetail) {
                BudgetSummaryDetailView(
                    totalBudget: metrics.totalBudget,
                    schedules: schedules,
                    onReload: { await load() }
                )
            }
            .navigationDestination(item: $selectedCategory) { category in
                BudgetCategoryDetailView(
                    categoryId: category.id,
                    schedules: schedules,
                    totalBudget: metrics.totalBudget,
                    onReload: { await load() }
                )
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Budget")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text("Kelola anggaran pernikahan\ndengan bijak dan terencana.")
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                circleButton("magnifyingglass")
                circleButton("slider.horizontal.3") {
                    showEditBudget = true
                }
            }
            .padding(.top, 4)
        }
        .frame(height: 96, alignment: .top)
        .padding(.top, 8)
    }

    private func circleButton(_ icon: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppTheme.ink.opacity(0.72))
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.86), in: Circle())
                .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }

    private var totalCard: some View {
        Button {
            showEditBudget = true
        } label: {
            VStack(spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Total Anggaran")
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text(CurrencyFormatter.rupiah(metrics.totalBudget))
                            .font(AppFont.medium(26))
                            .foregroundStyle(AppTheme.sageDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(budget.totalBudget > 0 ? "100% dari rencana" : "Ketuk untuk atur total budget")
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.4))
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Pengeluaran Terpakai")
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
                        donutLegend(color: AppTheme.sageDark, title: "Terpakai", amount: metrics.spent, percent: metrics.percent(metrics.spent))
                        donutLegend(color: AppTheme.gold, title: "Sisa Anggaran", amount: metrics.remaining, percent: metrics.percent(metrics.remaining))
                        donutLegend(color: AppTheme.mist, title: "Komitmen", amount: metrics.commitment, percent: metrics.percent(metrics.commitment))
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 6) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.sageDark)
                        Text("Sisa Anggaran")
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
            statCard(icon: "list.bullet.rectangle", tint: AppTheme.sageDark, label: "Total Anggaran", amount: metrics.totalBudget, sub: nil)
            statCard(icon: "checkmark.circle.fill", tint: AppTheme.sageDark, label: "Terpakai", amount: metrics.spent, sub: "\(metrics.percent(metrics.spent))%")
            statCard(icon: "hourglass", tint: AppTheme.gold, label: "Komitmen", amount: metrics.commitment, sub: "\(metrics.percent(metrics.commitment))%")
            statCard(icon: "wallet.pass", tint: AppTheme.ink.opacity(0.45), label: "Sisa Anggaran", amount: metrics.remaining, sub: "\(metrics.percent(metrics.remaining))%")
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

    private var summaryHeader: some View {
        Button {
            showSummaryDetail = true
        } label: {
            HStack {
                Text("Ringkasan Anggaran")
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.sageDark)
                Spacer()
                Label("Lihat detail", systemImage: "chevron.right")
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
                Text("Belum ada pengeluaran")
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.sageDark)
                Text("Tambahkan expense pertama untuk melihat ringkasan per kategori.")
                    .font(AppFont.regular(12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 16)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            VStack(spacing: 10) {
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
                actionItem(icon: "plus", title: "Tambah Expense", sub: "Catat pengeluaran baru")
            }
            .buttonStyle(.plain)

            Divider().frame(height: 34)

            Button {
                showCategories = true
            } label: {
                actionItem(icon: "square.grid.2x2", title: "Kategori Budget", sub: "Kelola kategori anggaran")
            }
            .buttonStyle(.plain)

            Divider().frame(height: 34)

            Button {
                showReport = true
            } label: {
                actionItem(icon: "chart.bar", title: "Laporan Budget", sub: "Unduh laporan lengkap")
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
            async let budgetEnvelope: NullableEnvelope<WeddingBudget> = APIClient.shared.request("wedding-budget")
            async let scheduleEnvelope: Envelope<[PaymentSchedule]> = APIClient.shared.request("wedding-payment-schedules")

            let budgetResult = try await budgetEnvelope.data
            budget = budgetResult ?? WeddingBudget(id: nil, totalBudget: 0, currency: "IDR", notes: "")
            schedules = try await scheduleEnvelope.data
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let incomingEnvelope: Envelope<[IncomingPayment]> = try await APIClient.shared.request("wedding-incoming-payments")
            incomingPayments = incomingEnvelope.data
        } catch {
            incomingPayments = []
        }
    }
}
