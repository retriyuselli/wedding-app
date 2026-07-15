import SwiftUI

enum InspirationCategory: String, CaseIterable, Identifiable, Hashable, Decodable {
    case all = "all"
    case dekorasi = "dekorasi"
    case gaun = "gaun"
    case makeup = "makeup"
    case katering = "katering"
    case venue = "venue"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return L10n.Common.all
        case .dekorasi: return L10n.InspirationCategory.decoration
        case .gaun: return L10n.InspirationCategory.dress
        case .makeup: return L10n.InspirationCategory.makeup
        case .katering: return L10n.InspirationCategory.catering
        case .venue: return L10n.InspirationCategory.venue
        }
    }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .dekorasi: return "leaf"
        case .gaun: return "figure.dress.line.vertical"
        case .makeup: return "paintbrush"
        case .katering: return "fork.knife"
        case .venue: return "building.2"
        }
    }

    var thumbnailTint: Color {
        switch self {
        case .all, .dekorasi: return AppTheme.sage
        case .gaun: return AppTheme.peach
        case .makeup: return AppTheme.plum
        case .katering: return AppTheme.gold
        case .venue: return AppTheme.sageDark
        }
    }

    static var filterableCases: [InspirationCategory] {
        allCases.filter { $0 != .all }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = InspirationCategory(rawValue: raw) ?? .dekorasi
    }
}

struct InspirationItem: Identifiable, Hashable, Decodable {
    let id: Int
    let title: String
    let description: String?
    let category: InspirationCategory
    let likes: Int
    let views: Int
    let imageUrl: String?
    let thumbnailSymbol: String
    var isSaved: Bool
    var isLiked: Bool

    var thumbnailTint: Color { category.thumbnailTint }

    private enum CodingKeys: String, CodingKey {
        case id, title, description, category, likes, views, imageUrl, thumbnailSymbol, isSaved, isLiked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        category = try container.decodeIfPresent(InspirationCategory.self, forKey: .category) ?? .dekorasi
        likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        views = try container.decodeIfPresent(Int.self, forKey: .views) ?? 0
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        thumbnailSymbol = try container.decodeIfPresent(String.self, forKey: .thumbnailSymbol) ?? "sparkles"
        isSaved = try container.decodeIfPresent(Bool.self, forKey: .isSaved) ?? false
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
    }
}

struct InspirationCategoryGroup: Identifiable {
    let id: InspirationCategory
    let count: Int

    static func from(items: [InspirationItem]) -> [InspirationCategoryGroup] {
        InspirationCategory.filterableCases.compactMap { category in
            let count = items.filter { $0.category == category }.count
            guard count > 0 else { return nil }
            return InspirationCategoryGroup(id: category, count: count)
        }
    }
}

struct InspirationFilter: Equatable {
    var categories: Set<InspirationCategory> = []
    var minimumLikes: Int?
    var savedOnly: Bool = false

    var isActive: Bool {
        !categories.isEmpty || minimumLikes != nil || savedOnly
    }

    static var likesOptions: [(label: String, value: Int?)] {
        [
            (L10n.Inspiration.likesAll, nil),
            (L10n.Inspiration.likes200, 200),
            (L10n.Inspiration.likes500, 500),
        ]
    }

    mutating func reset() {
        self = InspirationFilter()
    }
}
