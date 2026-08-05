import Foundation

enum HelpTopicKind: String, CaseIterable, Identifiable {
    case gettingStarted
    case preparation
    case budget
    case guests
    case security

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gettingStarted: return "book"
        case .preparation: return "checklist"
        case .budget: return "creditcard"
        case .guests: return "person.2"
        case .security: return "lock"
        }
    }

    var title: String {
        switch self {
        case .gettingStarted: return L10n.Help.topicGettingStarted
        case .preparation: return L10n.Help.topicPreparation
        case .budget: return L10n.Help.topicBudget
        case .guests: return L10n.Help.topicGuests
        case .security: return L10n.Help.topicSecurity
        }
    }

    var subtitle: String {
        switch self {
        case .gettingStarted: return L10n.Help.topicGettingStartedSub
        case .preparation: return L10n.Help.topicPreparationSub
        case .budget: return L10n.Help.topicBudgetSub
        case .guests: return L10n.Help.topicGuestsSub
        case .security: return L10n.Help.topicSecuritySub
        }
    }

    var articleCount: Int {
        HelpContent.articles(for: self).count
    }
}

struct HelpArticle: Identifiable, Hashable {
    let id: String
    let topic: HelpTopicKind
    let readMinutes: Int

    private var keyBase: String {
        "help.article.\(id.replacingOccurrences(of: "-", with: "_"))"
    }

    var title: String { "\(keyBase).title".localized }
    var summary: String { "\(keyBase).summary".localized }
    var body: String { "\(keyBase).body".localized }
}

enum HelpContent {
    static let supportEmail = "support@weddingapp.co.id"
    static var serviceDays: String { L10n.Help.serviceDays }
    static var serviceHours: String { L10n.Help.serviceHours }

    static func articles(for topic: HelpTopicKind) -> [HelpArticle] {
        allArticles.filter { $0.topic == topic }
    }

    static func article(id: String) -> HelpArticle? {
        allArticles.first { $0.id == id }
    }

    static var allArticles: [HelpArticle] {
        gettingStartedArticles
            + preparationArticles
            + budgetArticles
            + guestsArticles
            + securityArticles
    }

    private static let gettingStartedArticles: [HelpArticle] = [
        HelpArticle(id: "gs-1", topic: .gettingStarted, readMinutes: 3),
        HelpArticle(id: "gs-2", topic: .gettingStarted, readMinutes: 2),
        HelpArticle(id: "gs-3", topic: .gettingStarted, readMinutes: 3),
        HelpArticle(id: "gs-4", topic: .gettingStarted, readMinutes: 4),
        HelpArticle(id: "gs-5", topic: .gettingStarted, readMinutes: 4),
        HelpArticle(id: "gs-6", topic: .gettingStarted, readMinutes: 5),
    ]

    private static let preparationArticles: [HelpArticle] = [
        HelpArticle(id: "prep-1", topic: .preparation, readMinutes: 4),
        HelpArticle(id: "prep-2", topic: .preparation, readMinutes: 3),
        HelpArticle(id: "prep-3", topic: .preparation, readMinutes: 3),
        HelpArticle(id: "prep-4", topic: .preparation, readMinutes: 4),
        HelpArticle(id: "prep-5", topic: .preparation, readMinutes: 5),
        HelpArticle(id: "prep-6", topic: .preparation, readMinutes: 5),
        HelpArticle(id: "prep-7", topic: .preparation, readMinutes: 3),
        HelpArticle(id: "prep-8", topic: .preparation, readMinutes: 3),
    ]

    private static let budgetArticles: [HelpArticle] = [
        HelpArticle(id: "bud-1", topic: .budget, readMinutes: 3),
        HelpArticle(id: "bud-2", topic: .budget, readMinutes: 3),
        HelpArticle(id: "bud-3", topic: .budget, readMinutes: 4),
        HelpArticle(id: "bud-4", topic: .budget, readMinutes: 3),
        HelpArticle(id: "bud-5", topic: .budget, readMinutes: 4),
        HelpArticle(id: "bud-6", topic: .budget, readMinutes: 3),
        HelpArticle(id: "bud-7", topic: .budget, readMinutes: 5),
    ]

    private static let guestsArticles: [HelpArticle] = [
        HelpArticle(id: "gst-1", topic: .guests, readMinutes: 3),
        HelpArticle(id: "gst-2", topic: .guests, readMinutes: 3),
        HelpArticle(id: "gst-3", topic: .guests, readMinutes: 3),
        HelpArticle(id: "gst-4", topic: .guests, readMinutes: 3),
        HelpArticle(id: "gst-5", topic: .guests, readMinutes: 3),
    ]

    private static let securityArticles: [HelpArticle] = [
        HelpArticle(id: "sec-1", topic: .security, readMinutes: 3),
        HelpArticle(id: "sec-2", topic: .security, readMinutes: 3),
        HelpArticle(id: "sec-3", topic: .security, readMinutes: 4),
        HelpArticle(id: "sec-4", topic: .security, readMinutes: 3),
        HelpArticle(id: "sec-5", topic: .security, readMinutes: 4),
        HelpArticle(id: "sec-6", topic: .security, readMinutes: 3),
    ]
}
