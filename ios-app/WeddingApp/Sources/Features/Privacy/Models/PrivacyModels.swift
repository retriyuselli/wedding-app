import Foundation

struct PrivacySecuritySummary: Codable, Hashable {
    let status: String
    let title: String
    let message: String
    let score: Int
    let checks: [PrivacySecurityCheck]
}

struct PrivacySecurityCheck: Codable, Identifiable, Hashable {
    var id: String { key }
    let key: String
    let passed: Bool
    let label: String
    let detail: String
}

struct PrivacyVisibilitySettings: Codable, Hashable {
    var profileVisibility: String
    var weddingVisibility: String
    var guestListVisibility: String
    var budgetVisibility: String
    var showInDirectory: Bool
    var allowVendorContact: Bool
}

struct AppPermissionItem: Codable, Identifiable, Hashable {
    let key: String
    let title: String
    let description: String
    let category: String

    var id: String { key }
}

struct TwoFactorStatus: Codable, Hashable {
    let enabled: Bool
    let method: String
    let email: String?
}

struct TwoFactorChallengeResponse: Codable {
    let requiresTwoFactor: Bool
    let twoFactorToken: String
    let message: String
}

struct TrustedDevice: Codable, Identifiable, Hashable {
    let id: Int
    var deviceName: String
    let deviceIdentifier: String
    let platform: String?
    var isTrusted: Bool
    var isCurrent: Bool?
    let lastUsedAt: String?
    let trustedAt: String?
    let createdAt: String?
    let updatedAt: String?
}

struct HelpCenterPayload: Codable, Hashable {
    let supportEmail: String
    let supportWhatsapp: String
    let supportWhatsappUrl: String
    let appVersion: String?
    let lastUpdatedLabel: String?
    let faqs: [HelpCenterFAQ]
    let topics: [HelpCenterTopic]
    let popularGuides: [HelpCenterGuide]?
    let contactMethods: [HelpCenterContactMethod]?
    let locale: String?
}

struct HelpCenterFAQ: Codable, Identifiable, Hashable {
    let id: String
    let question: String
    let answer: String
    let icon: String?
}

struct HelpCenterTopic: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String?
    let iconBg: String?
    let iconText: String?
    let route: String?
}

struct HelpCenterGuide: Codable, Hashable {
    let title: String
    let route: String
}

struct HelpCenterContactMethod: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let action: String
    let href: String
    let external: Bool
}

struct MessageEnvelope: Codable {
    let message: String
    let data: TwoFactorStatus?
}
