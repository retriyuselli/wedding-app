import Foundation

struct BillingEntitlement: Decodable, Hashable {
    let isPremium: Bool
    let premiumProductId: String?
    let premiumActivatedAt: String?
    let sharedPremiumAccess: [SharedPremiumAccess]

    init(
        isPremium: Bool = false,
        premiumProductId: String? = nil,
        premiumActivatedAt: String? = nil,
        sharedPremiumAccess: [SharedPremiumAccess] = []
    ) {
        self.isPremium = isPremium
        self.premiumProductId = premiumProductId
        self.premiumActivatedAt = premiumActivatedAt
        self.sharedPremiumAccess = sharedPremiumAccess
    }
}

struct SharedPremiumAccess: Codable, Hashable, Identifiable {
    var id: Int { userId }
    let userId: Int
    let name: String
    let email: String?
    let resources: [String]

    var canAccessGuests: Bool { resources.contains("guests") }
    var canAccessBudget: Bool { resources.contains("budget") }
}
