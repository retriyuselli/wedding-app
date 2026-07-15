import Foundation

extension DateFormatter {
    /// Parse tanggal dari API — format `yyyy-MM-dd`, locale en_US_POSIX.
    static let apiInput: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = Calendar.current.timeZone
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Parse `yyyy-MM-dd` (or ISO prefix) as a calendar day in the user's timezone.
    static func calendarDate(from apiString: String) -> Date? {
        let trimmed = String(apiString.prefix(10))
        guard trimmed.count == 10 else { return nil }

        let parts = trimmed.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    /// Format a calendar day for API (`yyyy-MM-dd`) without timezone drift.
    static func apiDateString(from date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else {
            return apiInput.string(from: date)
        }
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    /// Tampilkan tanggal ke user sesuai bahasa aktif — format `d MMMM yyyy`.
    static func displayLocaleDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
