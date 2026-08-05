import Foundation

struct BudgetPaymentCategory: Codable, Identifiable, Hashable {
    let key: String
    let label: String
    let icon: String

    var id: String { key }

    init(key: String, label: String, icon: String) {
        self.key = key
        self.label = label
        self.icon = icon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        key = try container.decode(String.self, forKey: .key)
        label = try container.decode(String.self, forKey: .label)
        icon = try container.decode(String.self, forKey: .icon)
    }
}
