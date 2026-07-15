import Foundation

struct WeddingEvent: Codable, Identifiable {
    let id: Int
    var jenisAcara: String
    let jenisLabel: String?
    var sortOrder: Int?
    var tglAcara: String?
    var waktuMulai: String?
    var jamSelesai: String?
    var lokasiAcara: String?
    var estimasiTamu: Int?
    var catatan: String?

    static let jenisOptions = ["lamaran", "pengajian", "akad", "resepsi"]

    static func label(for jenis: String) -> String {
        switch jenis.lowercased() {
        case "lamaran": return L10n.Events.lamaran
        case "pengajian": return L10n.Events.pengajian
        case "akad": return L10n.Events.akad
        case "resepsi": return L10n.Events.resepsi
        default: return jenis.capitalized
        }
    }
}

enum WeddingEventTime {
    private static let apiParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "HH.mm"
        return formatter
    }()

    static func date(from apiTime: String?) -> Date? {
        guard let apiTime, !apiTime.isEmpty else {
            return nil
        }

        let normalized = String(apiTime.prefix(5))
        return apiParser.date(from: normalized)
    }

    static func apiString(from date: Date) -> String {
        apiParser.string(from: date)
    }

    static func displayTime(_ apiTime: String?) -> String {
        guard let date = date(from: apiTime) else {
            return ""
        }

        return displayFormatter.string(from: date)
    }

    static func timeRange(waktuMulai: String?, jamSelesai: String?, jenisAcara: String) -> String {
        let start = displayTime(waktuMulai)
        let end = displayTime(jamSelesai)

        if !start.isEmpty, !end.isEmpty {
            return L10n.Events.timeRangeWib(start, end)
        }

        if !start.isEmpty {
            return L10n.Events.timeWib(start)
        }

        return defaultTimeRange(for: jenisAcara)
    }

    static func defaultTimeRange(for jenisAcara: String) -> String {
        switch jenisAcara.lowercased() {
        case "akad": return L10n.Events.defaultTimeAkad
        case "resepsi": return L10n.Events.defaultTimeResepsi
        case "lamaran": return L10n.Events.defaultTimeLamaran
        case "pengajian": return L10n.Events.defaultTimePengajian
        default: return L10n.WeddingDetail.timeNotSet
        }
    }

    static func defaultStart(for jenisAcara: String) -> Date {
        let defaults: [String: (Int, Int)] = [
            "akad": (10, 0),
            "resepsi": (11, 30),
            "lamaran": (14, 0),
            "pengajian": (9, 0),
        ]

        let parts = defaults[jenisAcara.lowercased()] ?? (10, 0)
        return Calendar.current.date(from: DateComponents(hour: parts.0, minute: parts.1)) ?? Date()
    }

    static func defaultEnd(for jenisAcara: String) -> Date {
        let defaults: [String: (Int, Int)] = [
            "akad": (11, 0),
            "resepsi": (15, 0),
            "lamaran": (16, 0),
            "pengajian": (11, 0),
        ]

        let parts = defaults[jenisAcara.lowercased()] ?? (11, 0)
        return Calendar.current.date(from: DateComponents(hour: parts.0, minute: parts.1)) ?? Date()
    }

    static func defaultEventDate(for jenisAcara: String, weddingDay: Date) -> Date {
        let calendar = Calendar.current

        switch jenisAcara.lowercased() {
        case "lamaran":
            return calendar.date(byAdding: .day, value: -60, to: weddingDay) ?? weddingDay
        case "pengajian":
            return calendar.date(byAdding: .day, value: -30, to: weddingDay) ?? weddingDay
        default:
            return weddingDay
        }
    }

    static func defaultWeddingDay(from createdAt: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .month, value: 3, to: createdAt) ?? createdAt
    }
}
