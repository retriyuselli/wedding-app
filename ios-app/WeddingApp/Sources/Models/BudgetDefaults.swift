import Foundation

struct BudgetDefaults: Equatable {
    var currency: String
    var expenseCategory: String
    var categoryIcon: String
    var expenseStatus: String
    var incomingPaymentStatus: String

    var isLoaded: Bool {
        !currency.isEmpty
    }

    #if DEBUG
    static let preview = BudgetDefaults(
        currency: "IDR",
        expenseCategory: "other",
        categoryIcon: "ellipsis",
        expenseStatus: "pending",
        incomingPaymentStatus: "menunggu"
    )
    #endif
}

struct BudgetPaymentCategoriesResponse: Decodable {
    let data: [BudgetPaymentCategory]
    let meta: BudgetDefaultsMeta

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([BudgetPaymentCategory].self, forKey: .data)
        meta = try container.decodeIfPresent(BudgetDefaultsMeta.self, forKey: .meta) ?? .fallback
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
}

struct BudgetDefaultsMeta: Decodable {
    let defaultCurrency: String
    let defaultExpenseCategory: String
    let defaultCategoryIcon: String
    let defaultExpenseStatus: String
    let defaultIncomingPaymentStatus: String

    var asBudgetDefaults: BudgetDefaults {
        BudgetDefaults(
            currency: defaultCurrency,
            expenseCategory: defaultExpenseCategory,
            categoryIcon: defaultCategoryIcon,
            expenseStatus: defaultExpenseStatus,
            incomingPaymentStatus: defaultIncomingPaymentStatus
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        defaultCurrency = Self.decodeString(from: container, forKey: .defaultCurrency) ?? Self.fallback.defaultCurrency
        defaultExpenseCategory = Self.decodeString(from: container, forKey: .defaultExpenseCategory) ?? Self.fallback.defaultExpenseCategory
        defaultCategoryIcon = Self.decodeString(from: container, forKey: .defaultCategoryIcon) ?? Self.fallback.defaultCategoryIcon
        defaultExpenseStatus = Self.decodeString(from: container, forKey: .defaultExpenseStatus) ?? Self.fallback.defaultExpenseStatus
        defaultIncomingPaymentStatus = Self.decodeString(from: container, forKey: .defaultIncomingPaymentStatus) ?? Self.fallback.defaultIncomingPaymentStatus
    }

    private enum CodingKeys: String, CodingKey {
        case defaultCurrency
        case defaultExpenseCategory
        case defaultCategoryIcon
        case defaultExpenseStatus
        case defaultIncomingPaymentStatus
    }

    static let fallback = BudgetDefaultsMeta(
        defaultCurrency: "IDR",
        defaultExpenseCategory: "other",
        defaultCategoryIcon: "ellipsis",
        defaultExpenseStatus: "pending",
        defaultIncomingPaymentStatus: "menunggu"
    )

    private init(
        defaultCurrency: String,
        defaultExpenseCategory: String,
        defaultCategoryIcon: String,
        defaultExpenseStatus: String,
        defaultIncomingPaymentStatus: String
    ) {
        self.defaultCurrency = defaultCurrency
        self.defaultExpenseCategory = defaultExpenseCategory
        self.defaultCategoryIcon = defaultCategoryIcon
        self.defaultExpenseStatus = defaultExpenseStatus
        self.defaultIncomingPaymentStatus = defaultIncomingPaymentStatus
    }

    private static func decodeString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> String? {
        if let value = try? container.decode(String.self, forKey: key), !value.isEmpty {
            return value
        }

        return nil
    }
}
