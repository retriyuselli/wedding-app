import Foundation

struct WeddingQuote: Codable, Identifiable, Hashable {
    let id: Int
    let quote: String
    let sortOrder: Int?

    static let fallback: [WeddingQuote] = [
        WeddingQuote(id: -1, quote: "Pernikahan yang sempurna bukan soal detailnya, melainkan tentang merayakan cinta kalian.", sortOrder: 1),
        WeddingQuote(id: -2, quote: "Pernikahan bukan hanya tentang hari pernikahan, tapi tentang semua hari setelahnya.", sortOrder: 2),
        WeddingQuote(id: -3, quote: "Dua jiwa, satu hati — awal dari kebersamaan yang indah selamanya.", sortOrder: 3),
    ]
}
