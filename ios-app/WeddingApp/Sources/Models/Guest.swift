import Foundation

struct Guest: Codable, Identifiable {
    let id: Int
    var name: String
    var phone: String?
    var email: String?
    var tableNumber: String?
    var rsvpStatus: String
    var catatan: String?

    static let rsvpOptions = ["menunggu", "hadir", "tidak_hadir"]
}
