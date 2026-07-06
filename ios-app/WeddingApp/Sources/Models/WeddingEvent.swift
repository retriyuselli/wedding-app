import Foundation

struct WeddingEvent: Codable, Identifiable {
    let id: Int
    var jenisAcara: String
    let jenisLabel: String?
    var tglAcara: String?
    var lokasiAcara: String?
    var catatan: String?

    static let jenisOptions = ["lamaran", "pengajian", "akad", "resepsi"]
}
