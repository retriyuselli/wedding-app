import Foundation

struct IncomingPayment: Codable, Identifiable {
    let id: Int
    var amount: Double
    var senderName: String?
    var transferDate: String?
    var status: String?
}
