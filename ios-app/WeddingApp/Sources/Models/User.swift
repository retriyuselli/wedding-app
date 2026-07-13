import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?
    let whatsapp: String?
    let hasSocialLogin: Bool?
    let twoFactorEnabled: Bool?
    let passwordChangedAt: String?
    let updatedAt: String?
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct LoginAPIResponse: Codable {
    let user: User?
    let token: String?
    let requiresTwoFactor: Bool?
    let twoFactorToken: String?
    let message: String?

    var authResponse: AuthResponse? {
        guard let user, let token else { return nil }
        return AuthResponse(user: user, token: token)
    }

    var challenge: TwoFactorChallengeResponse? {
        guard requiresTwoFactor == true, let twoFactorToken else { return nil }
        return TwoFactorChallengeResponse(
            requiresTwoFactor: true,
            twoFactorToken: twoFactorToken,
            message: message ?? "Kode verifikasi telah dikirim."
        )
    }
}

struct UserResponse: Codable {
    let user: User
}

struct MessageResponse: Codable {
    let message: String
}
