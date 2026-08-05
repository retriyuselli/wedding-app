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
    let roles: [String]?
    let isPremium: Bool?
    let premiumProductId: String?
    let premiumActivatedAt: String?
    let createdAt: String?
    let updatedAt: String?

    var isPremiumActive: Bool { isPremium == true }
    var isSuperAdmin: Bool { roles?.contains("super_admin") == true }

    /// First registration / join day for the account.
    var joinedAtDate: Date? {
        guard let createdAt else { return nil }
        if let day = DateFormatter.calendarDate(from: createdAt) {
            return day
        }
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFractional.date(from: createdAt) {
            return Calendar.current.startOfDay(for: date)
        }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: createdAt) {
            return Calendar.current.startOfDay(for: date)
        }
        return nil
    }
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
