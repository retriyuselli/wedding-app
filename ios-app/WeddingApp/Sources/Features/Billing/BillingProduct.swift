import Foundation

enum BillingProduct {
    static let proUnlock = "wedding_pro_unlock"
    static let monthly = "wedding_pro_monthly"
    static let allProIds: Set<String> = [proUnlock, monthly]

    static func planTitle(for productId: String, price: String) -> String {
        switch productId {
        case monthly: return L10n.Premium.planMonthly(price)
        default: return L10n.Premium.planLifetime(price)
        }
    }
}
