import Foundation

extension DateFormatter {
    /// Parse tanggal dari API — format `yyyy-MM-dd`, locale en_US_POSIX.
    static let apiInput: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Tampilkan tanggal ke user sesuai bahasa aktif — format `d MMMM yyyy`.
    static func displayLocaleDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
