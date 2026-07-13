import Foundation

struct FamilyMember: Codable, Identifiable, Hashable {
    let id: Int
    var no: Int?
    var name: String
    var role: String?
    var phone: String?
    var rsvpStatus: String
    var rsvpUpdatedByName: String?
    var rsvpUpdatedAt: String?

    var subtitleLine: String {
        guard let role, !role.isEmpty else {
            return L10n.Guest.familyMemberFallback
        }
        return role
    }
}
