import Foundation

struct WeddingInfo: Codable, Identifiable {
    let id: Int?
    var groomName: String?
    var brideName: String?
    var budaya: String?
    var songlist: [String]?
    var avatarUrl: String?
}
