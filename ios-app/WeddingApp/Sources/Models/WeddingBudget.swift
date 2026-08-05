import Foundation

struct WeddingBudget: Codable, Identifiable {
    let id: Int?
    var totalBudget: Double
    var currency: String?
    var notes: String?
}
