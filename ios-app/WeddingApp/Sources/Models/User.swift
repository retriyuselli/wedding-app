import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?
    let whatsapp: String?
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct UserResponse: Codable {
    let user: User
}
