import Foundation

struct GuestExcelImportResult: Decodable, Hashable {
    let imported: Int
    let skipped: Int
    let errors: [String]
}
