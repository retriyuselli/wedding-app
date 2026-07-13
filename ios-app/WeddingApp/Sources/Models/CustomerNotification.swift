import Foundation
import SwiftUI

struct CustomerNotification: Codable, Identifiable, Hashable {
    let id: Int
    let group: String?
    let title: String
    let message: String?
    let icon: String?
    let destination: String?
    let tint: String?
    var isUnread: Bool
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case group
        case title
        case message
        case icon
        case destination
        case tint
        case isUnread
        case createdAt
        case updatedAt
    }

    init(
        id: Int,
        group: String?,
        title: String,
        message: String?,
        icon: String?,
        destination: String?,
        tint: String?,
        isUnread: Bool,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.group = group
        self.title = title
        self.message = message
        self.icon = icon
        self.destination = destination
        self.tint = tint
        self.isUnread = isUnread
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        group = try container.decodeIfPresent(String.self, forKey: .group)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        destination = try container.decodeIfPresent(String.self, forKey: .destination)
        tint = try container.decodeIfPresent(String.self, forKey: .tint)
        createdAt = try Self.decodeFlexibleDateString(from: container, forKey: .createdAt)
        updatedAt = try Self.decodeFlexibleDateString(from: container, forKey: .updatedAt)

        if let unread = try? container.decode(Bool.self, forKey: .isUnread) {
            isUnread = unread
        } else if let unread = try? container.decode(Int.self, forKey: .isUnread) {
            isUnread = unread != 0
        } else if let unread = try? container.decode(String.self, forKey: .isUnread) {
            isUnread = ["1", "true", "yes"].contains(unread.lowercased())
        } else {
            isUnread = true
        }
    }

    var displayIcon: String {
        guard let icon, !icon.isEmpty else {
            return "bell.fill"
        }
        return icon
    }

    var displayMessage: String {
        guard let message, !message.isEmpty else {
            return ""
        }
        return message
    }

    var groupLabel: String {
        switch group?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "payment": return L10n.Dashboard.notificationGroupPayment
        case "guest": return L10n.Dashboard.notificationGroupGuest
        case "preparation": return L10n.Dashboard.notificationGroupPreparation
        case "system": return L10n.Dashboard.notificationGroupSystem
        default: return L10n.Dashboard.notificationGroupSystem
        }
    }

    var tintColor: Color {
        switch tint?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "success": return AppTheme.sageDark
        case "warning": return AppTheme.gold
        case "danger": return Color.red.opacity(0.8)
        default: return AppTheme.sage
        }
    }

    var relativeCreatedAt: String {
        guard let createdAt, let date = Self.parseDate(createdAt) else {
            return ""
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.current
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private static func decodeFlexibleDateString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> String? {
        if let value = try container.decodeIfPresent(String.self, forKey: key) {
            return value
        }

        return nil
    }

    private static func parseDate(_ value: String) -> Date? {
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFractional.date(from: value) {
            return date
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: value) {
            return date
        }

        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(identifier: "UTC")
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        return fallback.date(from: value)
    }
}
