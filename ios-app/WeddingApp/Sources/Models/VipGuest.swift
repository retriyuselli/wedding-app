import Foundation

struct VipGuest: Codable, Identifiable, Hashable {
    let id: Int
    var no: Int?
    var name: String
    var jabatan: String?
    var instansi: String?
    var phone: String?
    var kategori: String?
    var rsvpStatus: String
    var rsvpUpdatedByName: String?
    var rsvpUpdatedAt: String?
    var catatan: String?

    static let kategoriOptions: [(key: String, labelKey: String)] = [
        ("vip", "guest.vip_category_vip"),
        ("keluarga_besar", "guest.vip_category_family"),
        ("pejabat", "guest.vip_category_official"),
        ("tokoh_masyarakat", "guest.vip_category_figure"),
        ("rekan_bisnis", "guest.vip_category_business"),
        ("teman", "guest.vip_category_friend"),
    ]

    var kategoriLabel: String {
        guard let kategori else { return L10n.Guest.vipCategoryVip }
        return Self.kategoriOptions.first(where: { $0.key == kategori })?.labelKey.localized
            ?? kategori.capitalized
    }

    var subtitleLine: String {
        [jabatan, instansi]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " · ")
    }
}
