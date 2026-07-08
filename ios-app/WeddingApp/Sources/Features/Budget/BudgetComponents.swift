import SwiftUI

struct BudgetCategoryRow: View {
    let category: BudgetCategory
    let total: Double

    private var planPercentOfTotal: Int {
        guard category.hasPlannedAllocation, total > 0 else { return 0 }
        return Int((category.plannedAllocation / total * 100).rounded())
    }

    private var usagePercent: Int {
        if category.hasPlannedAllocation {
            return Int((category.usageAgainstPlanRatio * 100).rounded())
        }

        return Int((category.spentRatio * 100).rounded())
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 42, height: 42)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(category.name)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                if category.hasPlannedAllocation {
                    HStack(spacing: 6) {
                        Text("Alokasi \(CurrencyFormatter.rupiah(category.plannedAllocation))")
                        Text("|")
                            .foregroundStyle(AppTheme.ink.opacity(0.25))
                        Text("\(planPercentOfTotal)%")
                    }
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                } else {
                    Text("Belum diatur · \(CurrencyFormatter.rupiah(category.totalRecorded)) tercatat")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                BudgetBar(progress: category.usageAgainstPlanRatio, color: AppTheme.sage)
                    .frame(height: 5)
                    .frame(maxWidth: 110)
            }

            Spacer(minLength: 6)

            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.rupiah(category.spent))
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if category.commitment > 0 {
                    Text("\(CurrencyFormatter.rupiah(category.commitment)) komitmen")
                        .font(AppFont.regular(10))
                        .foregroundStyle(AppTheme.gold.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Text(category.hasPlannedAllocation ? "\(usagePercent)% terpakai" : "\(usagePercent)% dibayar")
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 5)
    }
}

struct BudgetCategorySummaryCard: View {
    let category: BudgetCategory
    let totalBudget: Double

    private var spentPercentOfBudget: Int {
        totalBudget == 0 ? 0 : Int((category.spent / totalBudget * 100).rounded())
    }

    private var paidPercentOfRecorded: Int {
        Int((category.paidRecordedRatio * 100).rounded())
    }

    private var spentPercentOfPlan: Int {
        guard category.hasPlannedAllocation else {
            return paidPercentOfRecorded
        }

        return Int((category.usageAgainstPlanRatio * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Terpakai")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                    Text(CurrencyFormatter.rupiah(category.spent))
                        .font(AppFont.medium(20))
                        .foregroundStyle(AppTheme.sageDark)
                    Text("\(spentPercentOfBudget)% dari total anggaran")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer()

                if category.hasPlannedAllocation {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Alokasi")
                            .font(AppFont.regular(12))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text(CurrencyFormatter.rupiah(category.plannedAllocation))
                            .font(AppFont.medium(16))
                            .foregroundStyle(AppTheme.sageDark)
                        Text("Rencana kategori")
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }
                } else if category.commitment > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Komitmen")
                            .font(AppFont.regular(12))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        Text(CurrencyFormatter.rupiah(category.commitment))
                            .font(AppFont.medium(16))
                            .foregroundStyle(AppTheme.gold)
                        Text("Menunggu bayar")
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }
                }
            }

            BudgetBar(progress: category.usageAgainstPlanRatio, color: AppTheme.sageDark)
                .frame(height: 6)

            Text(
                category.hasPlannedAllocation
                    ? "\(spentPercentOfPlan)% terpakai dari alokasi \(CurrencyFormatter.rupiah(category.plannedAllocation))"
                    : footerRecordedPaymentText
            )
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var footerRecordedPaymentText: String {
        let recorded = CurrencyFormatter.rupiah(category.totalRecorded)
        let paid = CurrencyFormatter.rupiah(category.spent)

        if category.totalRecorded == 0 {
            return "Belum ada expense tercatat"
        }

        if category.commitment > 0, category.spent == 0 {
            return "\(paid) sudah dibayar dari \(recorded) tercatat · sisanya menunggu bayar"
        }

        return "\(paidPercentOfRecorded)% sudah dibayar dari \(recorded) tercatat"
    }
}

struct BudgetDonut: View {
    let segments: [(value: Double, color: Color)]

    private var total: Double { max(segments.reduce(0) { $0 + $1.value }, 0.0001) }

    var body: some View {
        ZStack {
            Circle().stroke(AppTheme.mist.opacity(0.5), lineWidth: 15)

            ForEach(Array(cumulative.enumerated()), id: \.offset) { _, seg in
                Circle()
                    .trim(from: seg.start, to: seg.end)
                    .stroke(seg.color, style: StrokeStyle(lineWidth: 15, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    private var cumulative: [(start: Double, end: Double, color: Color)] {
        var running = 0.0
        var result: [(Double, Double, Color)] = []
        for seg in segments {
            let start = running / total
            running += seg.value
            let end = running / total
            result.append((start, end, seg.color))
        }
        return result
    }
}

struct BudgetBar: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(AppTheme.mist.opacity(0.7))
                Capsule().fill(color)
                    .frame(width: max(0, min(1, progress)) * proxy.size.width)
            }
        }
    }
}

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func rupiah(_ value: Double) -> String {
        let number = formatter.string(from: NSNumber(value: value)) ?? "0"
        return "Rp\(number)"
    }

    static func rupiahShort(_ value: Double) -> String {
        switch value {
        case 1_000_000_000...:
            let amount = value / 1_000_000_000
            return "Rp\(amount.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(amount)) : String(format: "%.1f", amount)) M"
        case 1_000_000...:
            let amount = value / 1_000_000
            return "Rp\(amount.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(amount)) : String(format: "%.1f", amount)) jt"
        case 1_000...:
            let amount = value / 1_000
            return "Rp\(amount.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(amount)) : String(format: "%.1f", amount)) rb"
        default:
            return rupiah(value)
        }
    }
}

struct BudgetSummaryMetrics {
    let totalBudget: Double
    let spent: Double
    let commitment: Double

    var remaining: Double { max(totalBudget - spent - commitment, 0) }

    func percent(_ value: Double) -> Int {
        totalBudget == 0 ? 0 : Int((value / totalBudget * 100).rounded())
    }

    static func make(budget: WeddingBudget, categories: [BudgetCategory]) -> BudgetSummaryMetrics {
        let spent = categories.reduce(0) { $0 + $1.spent }
        let commitment = categories.reduce(0) { $0 + $1.commitment }
        let totalBudget: Double
        if budget.totalBudget > 0 {
            totalBudget = budget.totalBudget
        } else {
            let plannedTotal = categories.reduce(0) { $0 + $1.plannedAllocation }
            totalBudget = plannedTotal > 0
                ? plannedTotal
                : categories.reduce(0) { $0 + $1.totalRecorded }
        }

        return BudgetSummaryMetrics(totalBudget: totalBudget, spent: spent, commitment: commitment)
    }

    static func from(summary: WeddingBudgetSummary) -> BudgetSummaryMetrics {
        BudgetSummaryMetrics(
            totalBudget: summary.totalBudget,
            spent: summary.spent,
            commitment: summary.commitment
        )
    }

    /// Prioritises user-configured `wedding-budget` total; uses summary for spent/commitment.
    static func resolve(
        budget: WeddingBudget,
        summary: WeddingBudgetSummary?,
        categories: [BudgetCategory]
    ) -> BudgetSummaryMetrics {
        let spent: Double
        let commitment: Double

        if let summary {
            spent = summary.spent
            commitment = summary.commitment
        } else {
            spent = categories.reduce(0) { $0 + $1.spent }
            commitment = categories.reduce(0) { $0 + $1.commitment }
        }

        let totalBudget: Double
        if budget.totalBudget > 0 {
            totalBudget = budget.totalBudget
        } else if let summary, summary.totalBudget > 0 {
            totalBudget = summary.totalBudget
        } else {
            return make(budget: budget, categories: categories)
        }

        return BudgetSummaryMetrics(
            totalBudget: totalBudget,
            spent: spent,
            commitment: commitment
        )
    }

    func reportText(categories: [BudgetCategory], incomingTotal: Double) -> String {
        var lines = [
            "Laporan Budget Pernikahan",
            "========================",
            "",
            "Total Anggaran: \(CurrencyFormatter.rupiah(totalBudget))",
            "Terpakai: \(CurrencyFormatter.rupiah(spent)) (\(percent(spent))%)",
            "Komitmen: \(CurrencyFormatter.rupiah(commitment)) (\(percent(commitment))%)",
            "Sisa Anggaran: \(CurrencyFormatter.rupiah(remaining)) (\(percent(remaining))%)",
            "Uang Masuk: \(CurrencyFormatter.rupiah(incomingTotal))",
            "",
            "Ringkasan per Kategori:",
        ]

        for category in categories {
            lines.append("- \(category.name): \(CurrencyFormatter.rupiah(category.spent)) terpakai / \(CurrencyFormatter.rupiah(category.totalRecorded)) tercatat")
            if category.hasPlannedAllocation {
                lines.append("  Alokasi: \(CurrencyFormatter.rupiah(category.plannedAllocation))")
            }
            if category.commitment > 0 {
                lines.append("  Komitmen: \(CurrencyFormatter.rupiah(category.commitment))")
            }
        }

        return lines.joined(separator: "\n")
    }
}
