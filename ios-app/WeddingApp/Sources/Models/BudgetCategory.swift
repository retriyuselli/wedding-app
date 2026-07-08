import Foundation

struct BudgetCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let iconName: String
    /// User-defined budget allocation for this category.
    let plannedAllocation: Double
    let spent: Double
    let commitment: Double

    var totalRecorded: Double { spent + commitment }

    /// Persentase expense dalam kategori yang sudah dibayar (bukan yang masih komitmen).
    var paidRecordedRatio: Double {
        totalRecorded == 0 ? 0 : spent / totalRecorded
    }

    var spentRatio: Double {
        paidRecordedRatio
    }

    var usageAgainstPlanRatio: Double {
        guard plannedAllocation > 0 else {
            return spentRatio
        }

        return min(spent / plannedAllocation, 1)
    }

    var hasPlannedAllocation: Bool {
        plannedAllocation > 0
    }

    static func icon(for key: String, options: [BudgetPaymentCategory], defaultIcon: String) -> String {
        options.first(where: { $0.key == key })?.icon ?? defaultIcon
    }

    static func label(for key: String, options: [BudgetPaymentCategory]) -> String {
        options.first(where: { $0.key == key })?.label ?? key.capitalized
    }

    static func allocationsMap(
        from allocations: [BudgetCategoryAllocation]
    ) -> [String: BudgetCategoryAllocation] {
        Dictionary(uniqueKeysWithValues: allocations.map { ($0.category, $0) })
    }

    static func build(
        from schedules: [PaymentSchedule],
        options: [BudgetPaymentCategory] = [],
        allocations: [BudgetCategoryAllocation] = [],
        defaults: BudgetDefaults
    ) -> [BudgetCategory] {
        guard !schedules.isEmpty else { return [] }

        let allocationMap = allocationsMap(from: allocations)
        let grouped = Dictionary(grouping: schedules) {
            $0.resolvedCategoryKey(default: defaults.expenseCategory)
        }

        return grouped
            .map { key, items in
                make(
                    id: key,
                    items: items,
                    options: options,
                    defaults: defaults,
                    plannedAllocation: allocationMap[key]?.allocatedAmount ?? 0
                )
            }
            .sorted { $0.totalRecorded > $1.totalRecorded }
    }

    static func buildAll(
        from schedules: [PaymentSchedule],
        options: [BudgetPaymentCategory],
        allocations: [BudgetCategoryAllocation] = [],
        defaults: BudgetDefaults
    ) -> [BudgetCategory] {
        let categoryOptions = options
        let allocationMap = allocationsMap(from: allocations)
        let grouped = Dictionary(grouping: schedules) {
            $0.resolvedCategoryKey(default: defaults.expenseCategory)
        }
        let knownKeys = Set(categoryOptions.map(\.key))

        var result = categoryOptions.map { option in
            make(
                id: option.key,
                items: grouped[option.key] ?? [],
                options: categoryOptions,
                labelOverride: option.label,
                defaults: defaults,
                plannedAllocation: allocationMap[option.key]?.allocatedAmount ?? 0
            )
        }

        for (key, items) in grouped where !knownKeys.contains(key) {
            result.append(
                make(
                    id: key,
                    items: items,
                    options: categoryOptions,
                    defaults: defaults,
                    plannedAllocation: allocationMap[key]?.allocatedAmount ?? 0
                )
            )
        }

        return result.sorted { lhs, rhs in
            if lhs.plannedAllocation == rhs.plannedAllocation {
                if lhs.totalRecorded == rhs.totalRecorded {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.totalRecorded > rhs.totalRecorded
            }

            return lhs.plannedAllocation > rhs.plannedAllocation
        }
    }

    static func make(
        id: String,
        items: [PaymentSchedule],
        options: [BudgetPaymentCategory] = [],
        labelOverride: String? = nil,
        defaults: BudgetDefaults,
        plannedAllocation: Double = 0
    ) -> BudgetCategory {
        let spent = items.filter(\.isPaid).reduce(0) { $0 + $1.amount }
        let commitment = items.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let label = labelOverride ?? items.first?.categoryLabel ?? Self.label(for: id, options: options)

        return BudgetCategory(
            id: id,
            name: label,
            iconName: Self.icon(for: id, options: options, defaultIcon: defaults.categoryIcon),
            plannedAllocation: plannedAllocation,
            spent: spent,
            commitment: commitment
        )
    }
}
