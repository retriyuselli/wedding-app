import SwiftUI

private struct EditableScheduleRoute: Identifiable, Hashable {
    let id: Int
}

struct PaymentScheduleListView: View {
    let title: String
    let schedules: [PaymentSchedule]
    let onReload: () async -> Void
    var categorySummary: BudgetCategory?
    var totalBudget: Double = 0

    @State private var showAddExpense = false
    @State private var editingScheduleRoute: EditableScheduleRoute?
    @State private var errorMessage: String?

    private var sortedSchedules: [PaymentSchedule] {
        schedules.sorted { lhs, rhs in
            (lhs.dueDate ?? "") < (rhs.dueDate ?? "")
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
            }

            if sortedSchedules.isEmpty {
                ContentUnavailableView(
                    "Belum ada pengeluaran",
                    systemImage: "creditcard",
                    description: Text("Tambahkan jadwal pembayaran untuk mulai melacak budget.")
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
                            Label("Hapus", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if !schedule.isPaid {
                            Button {
                                Task { await markPaid(schedule) }
                            } label: {
                                Label("Lunas", systemImage: "checkmark.circle")
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
    let categoryId: String
    let schedules: [PaymentSchedule]
    let totalBudget: Double
    let onReload: () async -> Void

    private var category: BudgetCategory {
        BudgetCategory.build(from: schedules).first { $0.id == categoryId }
            ?? BudgetCategory(
                id: categoryId,
                name: BudgetCategory.label(for: categoryId),
                iconName: BudgetCategory.icon(for: categoryId),
                allocated: 0,
                spent: 0,
                commitment: 0
            )
    }

    private var filteredSchedules: [PaymentSchedule] {
        schedules.filter { ($0.category ?? "other") == categoryId }
    }

    var body: some View {
        PaymentScheduleListView(
            title: category.name,
            schedules: filteredSchedules,
            onReload: onReload,
            categorySummary: category,
            totalBudget: totalBudget
        )
    }
}

struct BudgetSummaryDetailView: View {
    let totalBudget: Double
    let schedules: [PaymentSchedule]
    let onReload: () async -> Void

    private var categories: [BudgetCategory] {
        BudgetCategory.build(from: schedules)
    }

    private var metrics: BudgetSummaryMetrics {
        BudgetSummaryMetrics.make(
            budget: WeddingBudget(id: nil, totalBudget: totalBudget, currency: "IDR", notes: nil),
            categories: categories
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                summaryCard

                if categories.isEmpty {
                    ContentUnavailableView(
                        "Belum ada pengeluaran",
                        systemImage: "chart.pie",
                        description: Text("Tambahkan expense untuk melihat ringkasan per kategori.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    Text("Per Kategori")
                        .font(AppFont.medium(16))
                        .foregroundStyle(AppTheme.sageDark)

                    VStack(spacing: 10) {
                        ForEach(categories) { category in
                            NavigationLink {
                                BudgetCategoryDetailView(
                                    categoryId: category.id,
                                    schedules: schedules,
                                    totalBudget: totalBudget,
                                    onReload: onReload
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
        .navigationTitle("Ringkasan Anggaran")
        .navigationBarTitleDisplayMode(.large)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Anggaran")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
            Text(CurrencyFormatter.rupiah(metrics.totalBudget))
                .font(AppFont.medium(22))
                .foregroundStyle(AppTheme.sageDark)

            HStack(spacing: 10) {
                summaryMetric(title: "Terpakai", amount: metrics.spent, percent: metrics.percent(metrics.spent), tint: AppTheme.sageDark)
                summaryMetric(title: "Komitmen", amount: metrics.commitment, percent: metrics.percent(metrics.commitment), tint: AppTheme.gold)
                summaryMetric(title: "Sisa", amount: metrics.remaining, percent: metrics.percent(metrics.remaining), tint: AppTheme.ink.opacity(0.55))
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
    let categories: [BudgetCategory]
    let totalBudget: Double
    let schedules: [PaymentSchedule]
    let onReload: () async -> Void

    var body: some View {
        List {
            if categories.isEmpty {
                ContentUnavailableView(
                    "Belum ada kategori",
                    systemImage: "square.grid.2x2",
                    description: Text("Tambahkan pengeluaran untuk melihat ringkasan per kategori.")
                )
            } else {
                ForEach(categories) { category in
                    NavigationLink {
                        BudgetCategoryDetailView(
                            categoryId: category.id,
                            schedules: schedules,
                            totalBudget: totalBudget,
                            onReload: onReload
                        )
                    } label: {
                        BudgetCategoryRow(category: category, total: totalBudget)
                            .listRowInsets(EdgeInsets())
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Kategori Budget")
    }
}

private struct PaymentScheduleRow: View {
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
                    Text("Dibayar: \(paidAtDisplay)")
                        .font(AppFont.regular(11))
                        .foregroundStyle(.secondary)
                } else if let dueDate = schedule.dueDate, !dueDate.isEmpty {
                    Text("Jatuh tempo: \(dueDate)")
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

struct EditTotalBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss

    let budget: WeddingBudget
    let onSaved: (WeddingBudget) -> Void

    @State private var totalBudgetText = ""
    @State private var notes = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                Section("Total Anggaran") {
                    TextField("Nominal", text: $totalBudgetText)
                        .keyboardType(.numberPad)
                    TextField("Catatan", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Atur Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task { await save() }
                    }
                    .disabled(isLoading || parsedAmount == nil)
                }
            }
            .onAppear {
                if budget.totalBudget > 0 {
                    totalBudgetText = String(Int(budget.totalBudget))
                }
                notes = budget.notes ?? ""
            }
        }
    }

    private var parsedAmount: Double? {
        let digits = totalBudgetText.filter(\.isNumber)
        guard !digits.isEmpty, let value = Double(digits) else { return nil }
        return value
    }

    private func save() async {
        guard let amount = parsedAmount else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var payload: [String: Any] = [
            "total_budget": amount,
            "currency": budget.currency ?? "IDR",
        ]

        if !notes.isEmpty {
            payload["notes"] = notes
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
    let reportText: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(reportText)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Laporan Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: reportText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
