import SwiftUI

// MARK: - API Models

struct VendorCategoryInfo: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let icon: String?
}

struct VendorFacilitySection: Codable, Hashable, Identifiable {
    let title: String
    let items: [String]

    var id: String { "\(title)-\(items.joined(separator: "|"))" }
}

struct VendorPackage: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let description: String?
    let price: String?
    let priceType: String?
    let priceTypeLabel: String?
    let capacityMin: Int?
    let capacityMax: Int?
    let durationHours: Int?
    let inclusions: [String]
    let facilitySections: [VendorFacilitySection]?
    let exclusions: [String]?
    let coverImageUrl: String?
    let isFeatured: Bool
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, price
        case priceType
        case priceTypeLabel
        case capacityMin
        case capacityMax
        case durationHours
        case inclusions
        case facilitySections
        case exclusions
        case coverImageUrl
        case isFeatured
        case sortOrder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = Self.decodeFlexibleString(from: container, forKey: .price)
        priceType = try container.decodeIfPresent(String.self, forKey: .priceType)
        priceTypeLabel = try container.decodeIfPresent(String.self, forKey: .priceTypeLabel)
        capacityMin = try container.decodeIfPresent(Int.self, forKey: .capacityMin)
        capacityMax = try container.decodeIfPresent(Int.self, forKey: .capacityMax)
        durationHours = try container.decodeIfPresent(Int.self, forKey: .durationHours)
        inclusions = try container.decodeIfPresent([String].self, forKey: .inclusions) ?? []
        facilitySections = try container.decodeIfPresent([VendorFacilitySection].self, forKey: .facilitySections)
        exclusions = try container.decodeIfPresent([String].self, forKey: .exclusions)
        coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImageUrl)
        isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
    }

    private static func decodeFlexibleString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key) {
            return value
        }

        if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
            return String(value)
        }

        if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
            return String(value)
        }

        return nil
    }

    var priceValue: Double? {
        guard let price else { return nil }
        return Double(price)
    }

    var displaySections: [VendorFacilitySection] {
        if let facilitySections, !facilitySections.isEmpty {
            return facilitySections
        }

        if inclusions.isEmpty {
            return []
        }

        return [VendorFacilitySection(title: "Fasilitas", items: inclusions)]
    }

    var displayExclusions: [String] {
        (exclusions ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

struct Vendor: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let description: String?
    let logoUrl: String?
    let coverImageUrl: String?
    let province: String?
    let city: String?
    let address: String?
    let phone: String?
    let email: String?
    let website: String?
    let instagram: String?
    let isVerified: Bool
    let isFeatured: Bool
    let category: VendorCategoryInfo?
    let packagesCount: Int?
    let startingPrice: String?
    let packages: [VendorPackage]?

    var startingPriceValue: Double? {
        guard let startingPrice else { return nil }
        return Double(startingPrice)
    }
}

// MARK: - Presentation Model

struct VendorItem: Identifiable, Hashable {
    let id: Int
    let slug: String
    let name: String
    let categorySlug: String
    let categoryLabel: String
    let categoryIcon: String?
    let province: String
    let city: String
    let description: String?
    let rating: Double?
    let reviewCount: Int?
    let packagesCount: Int
    let startingPrice: Double?
    let tags: [String]
    let isVerified: Bool
    let isFeatured: Bool
    let isSaved: Bool
    let logoUrl: String?
    let coverImageUrl: String?

    var logoSymbol: String {
        VendorCategoryAppearance.logoSymbol(for: categoryIcon, slug: categorySlug)
    }

    var logoTint: Color {
        VendorCategoryAppearance.logoTint(for: categorySlug)
    }

    var thumbnailSymbol: String {
        VendorCategoryAppearance.thumbnailSymbol(for: categoryIcon, slug: categorySlug)
    }

    var thumbnailTint: Color {
        VendorCategoryAppearance.thumbnailTint(for: categorySlug)
    }

    init(api vendor: Vendor, isSaved: Bool = false) {
        id = vendor.id
        slug = vendor.slug
        name = vendor.name
        categorySlug = vendor.category?.slug ?? "venue"
        categoryLabel = vendor.category?.name ?? "Vendor"
        categoryIcon = vendor.category?.icon
        province = vendor.province ?? "—"
        city = vendor.city ?? "—"
        description = vendor.description
        rating = nil
        reviewCount = nil
        packagesCount = vendor.packagesCount ?? vendor.packages?.count ?? 0
        startingPrice = vendor.startingPriceValue
        isVerified = vendor.isVerified
        isFeatured = vendor.isFeatured
        self.isSaved = isSaved
        logoUrl = vendor.logoUrl
        coverImageUrl = vendor.coverImageUrl

        var tagList: [String] = []
        if packagesCount > 0 {
            tagList.append("\(packagesCount) Paket")
        }
        if let startingPrice = vendor.startingPriceValue {
            tagList.append("Dari \(CurrencyFormatter.rupiahShort(startingPrice))")
        }
        if vendor.isFeatured {
            tagList.append("Unggulan")
        }
        tags = tagList
    }

    static let samples: [VendorItem] = [
        VendorItem(
            id: 1,
            slug: "grand-ballroom",
            name: "Grand Ballroom",
            categorySlug: "venue",
            categoryLabel: "Venue",
            categoryIcon: "building.columns",
            province: "Sumatera Selatan",
            city: "Palembang",
            description: nil,
            rating: 4.9,
            reviewCount: 128,
            packagesCount: 3,
            startingPrice: 35_000_000,
            tags: ["3 Paket", "Indoor"],
            isVerified: true,
            isFeatured: true,
            isSaved: false,
            logoUrl: nil,
            coverImageUrl: nil
        ),
    ]

    private init(
        id: Int,
        slug: String,
        name: String,
        categorySlug: String,
        categoryLabel: String,
        categoryIcon: String?,
        province: String,
        city: String,
        description: String?,
        rating: Double?,
        reviewCount: Int?,
        packagesCount: Int,
        startingPrice: Double?,
        tags: [String],
        isVerified: Bool,
        isFeatured: Bool,
        isSaved: Bool,
        logoUrl: String?,
        coverImageUrl: String?
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.categorySlug = categorySlug
        self.categoryLabel = categoryLabel
        self.categoryIcon = categoryIcon
        self.province = province
        self.city = city
        self.description = description
        self.rating = rating
        self.reviewCount = reviewCount
        self.packagesCount = packagesCount
        self.startingPrice = startingPrice
        self.tags = tags
        self.isVerified = isVerified
        self.isFeatured = isFeatured
        self.isSaved = isSaved
        self.logoUrl = logoUrl
        self.coverImageUrl = coverImageUrl
    }
}

enum VendorCategoryAppearance {
    static func icon(for apiIcon: String?, slug: String) -> String {
        if let apiIcon, !apiIcon.isEmpty {
            return apiIcon
        }

        return defaultIcon(for: slug)
    }

    static func logoSymbol(for apiIcon: String?, slug: String) -> String {
        let icon = icon(for: apiIcon, slug: slug)

        if icon.contains(".fill") || ["fork.knife", "music.note"].contains(icon) {
            return icon
        }

        return "\(icon).fill"
    }

    static func thumbnailSymbol(for apiIcon: String?, slug: String) -> String {
        switch slug {
        case "catering":
            return "takeoutbag.and.cup.and.straw.fill"
        case "fotografi", "videografi", "prewedding", "photo-booth":
            return "photo.on.rectangle.angled"
        case "mua":
            return "face.smiling"
        case "entertainment", "mc":
            return "music.mic"
        case "busana":
            return "hanger"
        case "wedding-organizer":
            return "calendar.badge.checkmark"
        default:
            return icon(for: apiIcon, slug: slug)
        }
    }

    static func logoTint(for slug: String) -> Color {
        switch slug {
        case "dekorasi", "florist", "kue", "hantaran":
            return AppTheme.gold
        case "fotografi", "videografi", "prewedding", "photo-booth":
            return AppTheme.ink
        case "mua":
            return AppTheme.peachDark
        case "entertainment", "mc", "sound-lighting":
            return AppTheme.plum
        case "busana":
            return AppTheme.peach
        default:
            return AppTheme.sageDark
        }
    }

    static func thumbnailTint(for slug: String) -> Color {
        switch slug {
        case "catering", "kue", "busana":
            return AppTheme.gold
        case "dekorasi", "florist", "hantaran":
            return AppTheme.peach
        case "fotografi", "videografi", "prewedding", "photo-booth", "entertainment", "mc", "sound-lighting":
            return AppTheme.plum
        case "mua":
            return AppTheme.softPeach
        default:
            return AppTheme.sage
        }
    }

    private static func defaultIcon(for slug: String) -> String {
        switch slug {
        case "venue": return "building.columns"
        case "catering": return "fork.knife"
        case "dekorasi": return "leaf"
        case "florist": return "camera.macro"
        case "fotografi": return "camera"
        case "videografi": return "video"
        case "mua": return "paintbrush"
        case "busana": return "tshirt"
        case "entertainment": return "music.note"
        case "wedding-organizer": return "calendar.badge.checkmark"
        case "mc": return "mic.fill"
        case "undangan": return "envelope.open"
        case "souvenir": return "gift"
        case "kue": return "birthday.cake"
        case "perhiasan": return "ring.circle"
        case "transportasi": return "car"
        case "akomodasi": return "bed.double"
        case "sound-lighting": return "speaker.wave.3"
        case "photo-booth": return "camera.viewfinder"
        case "prewedding": return "heart.text.square"
        case "honeymoon": return "airplane.departure"
        case "hantaran": return "basket"
        case "rental": return "chair.lounge"
        case "legal": return "doc.text"
        default: return "storefront"
        }
    }
}

enum VendorSortOption: String, CaseIterable, Identifiable {
    case popular = "popular"
    case newest = "newest"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .popular: return "Populer"
        case .newest: return "Terbaru"
        }
    }
}

struct VendorFilter: Equatable {
    var categorySlugs: Set<String> = []
    var province: String?
    var city: String?
    var verifiedOnly: Bool = false
    var savedOnly: Bool = false

    var isActive: Bool {
        !categorySlugs.isEmpty
            || (province != nil && province != VendorFilter.allProvincesLabel)
            || (city != nil && city != VendorFilter.allCitiesLabel)
            || verifiedOnly
            || savedOnly
    }

    static let allProvincesLabel = "Semua Provinsi"
    static let allCitiesLabel = "Semua Kota"

    mutating func reset() {
        self = VendorFilter()
    }
}

struct VendorRoute: Hashable, Identifiable {
    let slug: String

    var id: String { slug }
}
