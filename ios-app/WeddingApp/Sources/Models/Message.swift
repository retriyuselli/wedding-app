import SwiftUI

enum MessageCategory: String, CaseIterable, Identifiable, Hashable, Decodable {
    case all = "all"
    case vendor = "vendor"
    case committee = "committee"
    case support = "support"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "Semua"
        case .vendor: return "Vendor"
        case .committee: return "Panitia"
        case .support: return "Support"
        }
    }

    var iconName: String {
        switch self {
        case .all: return "tray.full"
        case .vendor: return "storefront"
        case .committee: return "person.3"
        case .support: return "headphones"
        }
    }

    /// SF Symbol untuk avatar thread berdasarkan kategori.
    var avatarSymbol: String {
        switch self {
        case .all, .vendor: return "building.columns.fill"
        case .committee: return "person.3.fill"
        case .support: return "heart.circle.fill"
        }
    }

    var avatarTint: Color {
        switch self {
        case .all, .vendor: return AppTheme.sageDark
        case .committee: return AppTheme.plum
        case .support: return AppTheme.peachDark
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = MessageCategory(rawValue: raw) ?? .support
    }
}

enum SupportMessageTopic: String, CaseIterable, Identifiable, Hashable {
    case account
    case budget
    case checklist
    case guests
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .account: return "Akun & Login"
        case .budget: return "Budget & Pembayaran"
        case .checklist: return "Checklist & Persiapan"
        case .guests: return "Tamu & Undangan"
        case .other: return "Lainnya"
        }
    }
}

struct MessageThread: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let category: MessageCategory
    let avatarUrl: String?
    let isOnline: Bool
    let lastMessage: String?
    let lastMessageAt: Date?
    let unreadCount: Int
    let hasUnread: Bool
    var messages: [ChatMessageItem]

    var avatarSymbol: String { category.avatarSymbol }
    var avatarTint: Color { category.avatarTint }

    var timeLabel: String {
        guard let lastMessageAt else { return "" }
        return MessageTimeFormatter.relativeLabel(for: lastMessageAt)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, category, avatarUrl, isOnline, lastMessage, lastMessageAt, unreadCount, hasUnread, messages
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decodeIfPresent(MessageCategory.self, forKey: .category) ?? .support
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        isOnline = try container.decodeIfPresent(Bool.self, forKey: .isOnline) ?? false
        lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        lastMessageAt = try container.decodeIfPresent(Date.self, forKey: .lastMessageAt)
        unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
        hasUnread = try container.decodeIfPresent(Bool.self, forKey: .hasUnread) ?? false
        messages = try container.decodeIfPresent([ChatMessageItem].self, forKey: .messages) ?? []
    }
}

struct ChatMessageItem: Identifiable, Hashable, Decodable {
    let id: Int
    let body: String
    let topic: String?
    let isOutgoing: Bool
    let createdAt: Date?

    var text: String { body }

    var topicLabel: String? {
        guard let topic else { return nil }
        return SupportMessageTopic(rawValue: topic)?.label ?? topic
    }

    var timeLabel: String {
        guard let createdAt else { return "Baru" }
        return DateFormatter.messageThreadTime.string(from: createdAt)
    }
}

enum MessageTimeFormatter {
    static func relativeLabel(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return DateFormatter.messageThreadTime.string(from: date)
        }

        if calendar.isDateInYesterday(date) {
            return "Kemarin"
        }

        return DateFormatter.messageThreadDate.string(from: date)
    }
}

struct MessageFilter: Equatable {
    var category: MessageCategory = .all
    var unreadOnly: Bool = false

    var isActive: Bool {
        category != .all || unreadOnly
    }

    mutating func reset() {
        self = MessageFilter()
    }
}

extension DateFormatter {
    static let messageThreadTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let messageThreadDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
}
