import SwiftUI

enum MessageCategory: String, CaseIterable, Identifiable, Hashable {
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
}

struct MessageThread: Identifiable, Hashable {
    let id: Int
    let name: String
    let category: MessageCategory
    let lastMessage: String
    let timeLabel: String
    let unreadCount: Int
    let isOnline: Bool
    let avatarSymbol: String
    let avatarTint: Color
    let messages: [ChatMessageItem]

    var hasUnread: Bool { unreadCount > 0 }

    static let samples: [MessageThread] = [
        MessageThread(
            id: 1,
            name: "Grand Ballroom",
            category: .vendor,
            lastMessage: "Baik, kami konfirmasi jadwal survey venue besok pukul 14.00.",
            timeLabel: "10:24",
            unreadCount: 2,
            isOnline: true,
            avatarSymbol: "building.columns.fill",
            avatarTint: AppTheme.sageDark,
            messages: [
                ChatMessageItem(id: 1, text: "Halo, apakah venue tersedia untuk tanggal 12 Agustus?", isOutgoing: true, timeLabel: "09:50"),
                ChatMessageItem(id: 2, text: "Selamat pagi! Venue masih tersedia untuk tanggal tersebut.", isOutgoing: false, timeLabel: "10:05"),
                ChatMessageItem(id: 3, text: "Baik, kami konfirmasi jadwal survey venue besok pukul 14.00.", isOutgoing: false, timeLabel: "10:24"),
            ]
        ),
        MessageThread(
            id: 2,
            name: "Lavisa Decoration",
            category: .vendor,
            lastMessage: "Desain pelaminan sudah kami kirim via email. Silakan dicek ya.",
            timeLabel: "Kemarin",
            unreadCount: 0,
            isOnline: false,
            avatarSymbol: "leaf.fill",
            avatarTint: AppTheme.gold,
            messages: [
                ChatMessageItem(id: 1, text: "Kami ingin tema rustic dengan dominasi putih dan sage green.", isOutgoing: true, timeLabel: "Kemarin"),
                ChatMessageItem(id: 2, text: "Desain pelaminan sudah kami kirim via email. Silakan dicek ya.", isOutgoing: false, timeLabel: "Kemarin"),
            ]
        ),
        MessageThread(
            id: 3,
            name: "Panitia Akad",
            category: .committee,
            lastMessage: "Checklist akad sudah 80% selesai. Mohon review bagian dekorasi.",
            timeLabel: "Kemarin",
            unreadCount: 1,
            isOnline: true,
            avatarSymbol: "person.3.fill",
            avatarTint: AppTheme.plum,
            messages: [
                ChatMessageItem(id: 1, text: "Bagaimana progres persiapan akad minggu ini?", isOutgoing: true, timeLabel: "Kemarin"),
                ChatMessageItem(id: 2, text: "Checklist akad sudah 80% selesai. Mohon review bagian dekorasi.", isOutgoing: false, timeLabel: "Kemarin"),
            ]
        ),
        MessageThread(
            id: 4,
            name: "Srikandi Catering",
            category: .vendor,
            lastMessage: "Menu tasting dijadwalkan Sabtu, 10.00 WIB.",
            timeLabel: "Sen",
            unreadCount: 0,
            isOnline: false,
            avatarSymbol: "fork.knife",
            avatarTint: AppTheme.sageDark,
            messages: [
                ChatMessageItem(id: 1, text: "Apakah menu prasmanan bisa disesuaikan untuk tamu vegetarian?", isOutgoing: true, timeLabel: "Sen"),
                ChatMessageItem(id: 2, text: "Tentu, kami siapkan opsi menu khusus.", isOutgoing: false, timeLabel: "Sen"),
                ChatMessageItem(id: 3, text: "Menu tasting dijadwalkan Sabtu, 10.00 WIB.", isOutgoing: false, timeLabel: "Sen"),
            ]
        ),
        MessageThread(
            id: 5,
            name: "Support Wedding App",
            category: .support,
            lastMessage: "Ada yang bisa kami bantu terkait perencanaan pernikahan Anda?",
            timeLabel: "Min",
            unreadCount: 0,
            isOnline: true,
            avatarSymbol: "heart.circle.fill",
            avatarTint: AppTheme.peachDark,
            messages: [
                ChatMessageItem(id: 1, text: "Halo, saya butuh bantuan mengatur checklist resepsi.", isOutgoing: true, timeLabel: "Min"),
                ChatMessageItem(id: 2, text: "Ada yang bisa kami bantu terkait perencanaan pernikahan Anda?", isOutgoing: false, timeLabel: "Min"),
            ]
        ),
    ]
}

struct ChatMessageItem: Identifiable, Hashable {
    let id: Int
    let text: String
    let isOutgoing: Bool
    let timeLabel: String
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
