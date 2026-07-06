import SwiftUI

enum InspirationCategory: String, CaseIterable, Identifiable, Hashable {
    case all = "all"
    case dekorasi = "dekorasi"
    case tema = "tema"
    case warna = "warna"
    case busana = "busana"
    case foto = "foto"
    case undangan = "undangan"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "Semua"
        case .dekorasi: return "Dekorasi"
        case .tema: return "Tema"
        case .warna: return "Warna"
        case .busana: return "Busana"
        case .foto: return "Foto"
        case .undangan: return "Undangan"
        }
    }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .dekorasi: return "leaf"
        case .tema: return "theatermasks"
        case .warna: return "paintpalette"
        case .busana: return "figure.dress.line.vertical"
        case .foto: return "camera"
        case .undangan: return "envelope"
        }
    }

    static var filterableCases: [InspirationCategory] {
        allCases.filter { $0 != .all }
    }
}

struct InspirationFeatured: Identifiable {
    let id: Int
    let eyebrow: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let imageName: String?
    let gradient: [Color]

    static let samples: [InspirationFeatured] = [
        InspirationFeatured(
            id: 1,
            eyebrow: "Featured Inspiration",
            title: "Garden Wedding",
            subtitle: "Nuansa alami yang romantis dan elegan untuk hari bahagiamu.",
            buttonTitle: "Lihat Ide",
            imageName: "FloralHeader",
            gradient: [AppTheme.surface, AppTheme.lightSage]
        ),
        InspirationFeatured(
            id: 2,
            eyebrow: "Featured Inspiration",
            title: "Classic White",
            subtitle: "Kesederhanaan putih yang timeless untuk momen sakralmu.",
            buttonTitle: "Lihat Ide",
            imageName: "CouplePortrait",
            gradient: [AppTheme.surface, AppTheme.mist]
        ),
        InspirationFeatured(
            id: 3,
            eyebrow: "Featured Inspiration",
            title: "Rustic Charm",
            subtitle: "Sentuhan kayu dan bunga kering yang hangat dan personal.",
            buttonTitle: "Lihat Ide",
            imageName: nil,
            gradient: [AppTheme.cream, AppTheme.softPeach]
        ),
        InspirationFeatured(
            id: 4,
            eyebrow: "Featured Inspiration",
            title: "Modern Minimal",
            subtitle: "Garis bersih dan palet netral untuk pernikahan kontemporer.",
            buttonTitle: "Lihat Ide",
            imageName: nil,
            gradient: [AppTheme.mist, AppTheme.sage.opacity(0.35)]
        ),
    ]
}

struct InspirationItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let category: InspirationCategory
    let likes: Int
    let imageName: String?
    let thumbnailSymbol: String
    let thumbnailTint: Color
    let isSaved: Bool

    static let popularSamples: [InspirationItem] = [
        InspirationItem(
            id: 1,
            title: "White Elegant",
            category: .dekorasi,
            likes: 1240,
            imageName: "FloralHeader",
            thumbnailSymbol: "sparkles",
            thumbnailTint: AppTheme.sage,
            isSaved: false
        ),
        InspirationItem(
            id: 2,
            title: "Rustic Garden",
            category: .tema,
            likes: 980,
            imageName: nil,
            thumbnailSymbol: "leaf.fill",
            thumbnailTint: AppTheme.gold,
            isSaved: true
        ),
        InspirationItem(
            id: 3,
            title: "Sage & Cream",
            category: .warna,
            likes: 860,
            imageName: nil,
            thumbnailSymbol: "paintpalette.fill",
            thumbnailTint: AppTheme.plum,
            isSaved: false
        ),
        InspirationItem(
            id: 4,
            title: "Lace Gown",
            category: .busana,
            likes: 740,
            imageName: "CouplePortrait",
            thumbnailSymbol: "figure.dress.line.vertical",
            thumbnailTint: AppTheme.peach,
            isSaved: false
        ),
    ]
}

struct InspirationCategoryGroup: Identifiable {
    let id: InspirationCategory
    let count: Int
    let imageName: String?
    let thumbnailSymbol: String
    let thumbnailTint: Color

    static let samples: [InspirationCategoryGroup] = [
        InspirationCategoryGroup(id: .dekorasi, count: 356, imageName: "FloralHeader", thumbnailSymbol: "leaf.fill", thumbnailTint: AppTheme.sage),
        InspirationCategoryGroup(id: .tema, count: 124, imageName: nil, thumbnailSymbol: "theatermasks.fill", thumbnailTint: AppTheme.gold),
        InspirationCategoryGroup(id: .warna, count: 98, imageName: nil, thumbnailSymbol: "paintpalette.fill", thumbnailTint: AppTheme.plum),
        InspirationCategoryGroup(id: .busana, count: 210, imageName: "CouplePortrait", thumbnailSymbol: "figure.dress.line.vertical", thumbnailTint: AppTheme.peach),
        InspirationCategoryGroup(id: .foto, count: 167, imageName: nil, thumbnailSymbol: "camera.fill", thumbnailTint: AppTheme.ink),
        InspirationCategoryGroup(id: .undangan, count: 89, imageName: nil, thumbnailSymbol: "envelope.fill", thumbnailTint: AppTheme.sageDark),
    ]
}

struct InspirationFilter: Equatable {
    var categories: Set<InspirationCategory> = []
    var minimumLikes: Int?
    var savedOnly: Bool = false

    var isActive: Bool {
        !categories.isEmpty || minimumLikes != nil || savedOnly
    }

    static let likesOptions: [(label: String, value: Int?)] = [
        ("Semua", nil),
        ("500+", 500),
        ("1.000+", 1000),
    ]

    mutating func reset() {
        self = InspirationFilter()
    }
}
