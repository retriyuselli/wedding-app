import Foundation

struct PaymentSchedule: Decodable, Identifiable, Hashable {
    let id: Int
    var weddingEventId: Int?
    var customerPaymentMethodId: Int?
    var title: String
    var vendorName: String?
    var category: String?
    var categoryLabel: String?
    var amount: Double
    var dueDate: String?
    var status: String
    var statusLabel: String?
    var paidAt: String?
    var notes: String?
    var proofUrl: String?
    var sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case weddingEventId
        case customerPaymentMethodId
        case title
        case vendorName
        case category
        case categoryLabel
        case amount
        case dueDate
        case status
        case statusLabel
        case paidAt
        case notes
        case proofUrl
        case sortOrder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        weddingEventId = Self.decodeFlexibleInt(from: container, forKey: .weddingEventId)
        customerPaymentMethodId = Self.decodeFlexibleInt(from: container, forKey: .customerPaymentMethodId)
        title = try container.decode(String.self, forKey: .title)
        vendorName = try container.decodeIfPresent(String.self, forKey: .vendorName)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        categoryLabel = try container.decodeIfPresent(String.self, forKey: .categoryLabel)
        amount = Self.decodeFlexibleDouble(from: container, forKey: .amount)
        dueDate = try container.decodeIfPresent(String.self, forKey: .dueDate)
        status = try container.decode(String.self, forKey: .status)
        statusLabel = try container.decodeIfPresent(String.self, forKey: .statusLabel)
        paidAt = try container.decodeIfPresent(String.self, forKey: .paidAt)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        proofUrl = try container.decodeIfPresent(String.self, forKey: .proofUrl)
        sortOrder = Self.decodeFlexibleInt(from: container, forKey: .sortOrder)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PaymentSchedule, rhs: PaymentSchedule) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.amount == rhs.amount
            && lhs.status == rhs.status
            && lhs.category == rhs.category
            && lhs.dueDate == rhs.dueDate
            && lhs.paidAt == rhs.paidAt
            && lhs.proofUrl == rhs.proofUrl
            && lhs.notes == rhs.notes
            && lhs.customerPaymentMethodId == rhs.customerPaymentMethodId
    }

    var normalizedStatus: String {
        status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var isPaid: Bool {
        normalizedStatus == "paid"
    }

    var isOverdue: Bool {
        normalizedStatus == "overdue"
    }

    func resolvedCategoryKey(default defaultKey: String) -> String {
        guard let category else {
            return defaultKey
        }

        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultKey : trimmed
    }

    var displayStatusLabel: String {
        if isPaid {
            return L10n.Budget.paid
        }

        if isOverdue {
            if let statusLabel, !statusLabel.isEmpty {
                return statusLabel
            }

            return L10n.Budget.overdue
        }

        if let statusLabel, !statusLabel.isEmpty {
            return statusLabel
        }

        return L10n.Budget.unpaid
    }

    var displayStatusColorName: String {
        if isPaid {
            return "paid"
        }

        if isOverdue {
            return "overdue"
        }

        return "pending"
    }

    var paidAtDisplay: String? {
        guard let paidAt, !paidAt.isEmpty else {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: paidAt) ?? ISO8601DateFormatter().date(from: paidAt) {
            return Self.paidAtDisplayFormatter.string(from: date)
        }

        return String(paidAt.prefix(10))
    }

    func matchesSearch(_ query: String) -> Bool {
        Self.matchesSearch(query, in: [
            title,
            vendorName,
            category,
            categoryLabel,
            notes,
            dueDate,
            displayStatusLabel,
            String(Int(amount)),
            CurrencyFormatter.rupiah(amount),
        ])
    }

    private static func matchesSearch(_ query: String, in values: [String?]) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else {
            return true
        }

        return values.contains { value in
            value?.localizedCaseInsensitiveContains(normalizedQuery) == true
        }
    }

    private static let paidAtDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    private static func decodeFlexibleInt(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Int? {
        if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
            return value
        }

        if let value = try? container.decodeIfPresent(String.self, forKey: key),
           let intValue = Int(value) {
            return intValue
        }

        return nil
    }

    private static func decodeFlexibleDouble(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Double {
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }

        if let value = try? container.decode(Int.self, forKey: key) {
            return Double(value)
        }

        if let value = try? container.decode(String.self, forKey: key),
           let doubleValue = Double(value) {
            return doubleValue
        }

        return 0
    }
}
