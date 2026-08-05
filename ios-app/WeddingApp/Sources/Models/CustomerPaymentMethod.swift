import Foundation

struct CustomerPaymentMethod: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    var accountNumber: String?
    var accountName: String?
    var isPrimary: Bool?
    var type: String?

    var displayLabel: String {
        if let accountNumber, !accountNumber.isEmpty {
            return "\(name) • \(accountNumber)"
        }
        return name
    }
}
