import Foundation

struct WeddingInfo: Codable, Identifiable {
    let id: Int?
    var groomName: String?
    var brideName: String?
    var groomFullName: String? = nil
    var brideFullName: String? = nil
    var groomPhone: String? = nil
    var bridePhone: String? = nil
    var groomFatherName: String? = nil
    var groomMotherName: String? = nil
    var brideFatherName: String? = nil
    var brideMotherName: String? = nil
    var budaya: String?
    var songlist: [String]?
    var avatarUrl: String? = nil
    var couplePhotoUrl: String? = nil
}
