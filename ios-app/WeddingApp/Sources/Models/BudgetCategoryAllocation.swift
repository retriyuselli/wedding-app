import Foundation

struct BudgetCategoryAllocation: Codable, Identifiable, Hashable {
    let id: Int
    let category: String
    let categoryLabel: String?
    var allocatedAmount: Double
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case categoryLabel
        case allocatedAmount
        case notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        category = try container.decode(String.self, forKey: .category)
        categoryLabel = try container.decodeIfPresent(String.self, forKey: .categoryLabel)
        allocatedAmount = Self.decodeFlexibleDouble(from: container, forKey: .allocatedAmount)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
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
