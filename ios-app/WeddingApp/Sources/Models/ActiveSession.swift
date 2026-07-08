import Foundation

struct ActiveSession: Codable, Identifiable, Hashable {
    let id: Int
    let deviceName: String
    let lastUsedAt: String?
    let createdAt: String?
    let isCurrent: Bool
}

struct RevokeSessionResponse: Codable {
    let message: String
    let loggedOutCurrentDevice: Bool?
}

struct RevokeOtherSessionsResponse: Codable {
    let message: String
    let revokedCount: Int
}
