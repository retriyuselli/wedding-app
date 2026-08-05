import Foundation

struct Guest: Codable, Identifiable, Hashable {
    let id: Int
    var no: Int?
    var name: String
    var phone: String?
    var email: String?
    var tableNumber: String?
    var rsvpStatus: String
    var rsvpUpdatedByName: String?
    var rsvpUpdatedAt: String?
    var catatan: String?

    static let rsvpOptions = ["menunggu", "hadir", "tidak_hadir"]
}
