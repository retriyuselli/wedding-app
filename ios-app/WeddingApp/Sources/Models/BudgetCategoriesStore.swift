import Foundation

@MainActor
final class BudgetCategoriesStore: ObservableObject {
    static let shared = BudgetCategoriesStore()

    @Published private(set) var categories: [BudgetPaymentCategory] = []
    @Published private(set) var defaults = BudgetDefaults(
        currency: "",
        expenseCategory: "",
        categoryIcon: "",
        expenseStatus: "",
        incomingPaymentStatus: ""
    )
    @Published private(set) var isLoaded = false

    private init() {}

    func loadIfNeeded() async {
        guard !isLoaded else {
            return
        }

        do {
            let response: BudgetPaymentCategoriesResponse = try await APIClient.shared.request("budget-payment-categories")
            categories = response.data
            defaults = response.meta.asBudgetDefaults
            isLoaded = true
        } catch {
            categories = []
        }
    }

    func label(for key: String) -> String {
        categories.first(where: { $0.key == key })?.label ?? key.capitalized
    }

    func icon(for key: String) -> String {
        categories.first(where: { $0.key == key })?.icon ?? defaults.categoryIcon
    }

    var defaultExpenseCategory: String {
        defaults.expenseCategory
    }

    var defaultCurrency: String {
        defaults.currency
    }

    var defaultIncomingPaymentStatus: String {
        defaults.incomingPaymentStatus
    }

    func reset() {
        isLoaded = false
        categories = []
        defaults = BudgetDefaults(
            currency: "",
            expenseCategory: "",
            categoryIcon: "",
            expenseStatus: "",
            incomingPaymentStatus: ""
        )
    }
}
