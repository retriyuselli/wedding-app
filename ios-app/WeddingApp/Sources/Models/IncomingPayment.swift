import Foundation

struct IncomingPayment: Codable, Identifiable, Hashable {
    let id: Int
    var bankName: String?
    var amount: Double
    var transferDate: String?
    var senderName: String?
    var description: String?
    var referenceNumber: String?
    var proofUrl: String?
    let status: String
    var statusLabel: String?
    var confirmedAt: String?
    var rejectionReason: String?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case bankName
        case amount
        case transferDate
        case senderName
        case description
        case referenceNumber
        case proofUrl
        case status
        case statusLabel
        case confirmedAt
        case rejectionReason
        case notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        bankName = try container.decodeIfPresent(String.self, forKey: .bankName)
        amount = Self.decodeFlexibleDouble(from: container, forKey: .amount)
        transferDate = try container.decodeIfPresent(String.self, forKey: .transferDate)
        senderName = try container.decodeIfPresent(String.self, forKey: .senderName)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        referenceNumber = try container.decodeIfPresent(String.self, forKey: .referenceNumber)
        proofUrl = try container.decodeIfPresent(String.self, forKey: .proofUrl)
        status = try container.decode(String.self, forKey: .status)
        statusLabel = try container.decode(String.self, forKey: .statusLabel)
        confirmedAt = try container.decodeIfPresent(String.self, forKey: .confirmedAt)
        rejectionReason = try container.decodeIfPresent(String.self, forKey: .rejectionReason)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }

    var normalizedStatus: String {
        status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var isConfirmed: Bool {
        normalizedStatus == "confirmed"
    }

    var isRejected: Bool {
        normalizedStatus == "rejected"
    }

    var displayStatusLabel: String {
        if let statusLabel, !statusLabel.isEmpty {
            return statusLabel
        }

        switch normalizedStatus {
        case "confirmed": return "Dikonfirmasi"
        case "rejected": return "Ditolak"
        default: return "Menunggu"
        }
    }

    var displaySenderName: String {
        guard let senderName, !senderName.isEmpty else {
            return "Tanpa nama"
        }

        return senderName
    }

    var transferDateDisplay: String? {
        guard let transferDate, !transferDate.isEmpty else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: String(transferDate.prefix(10))) else {
            return String(transferDate.prefix(10))
        }

        return Self.displayDateFormatter.string(from: date)
    }

    var subtitleLine: String {
        var parts: [String] = []

        if let transferDateDisplay {
            parts.append(transferDateDisplay)
        }

        if let bankName, !bankName.isEmpty {
            parts.append(bankName)
        }

        return parts.joined(separator: " · ")
    }

    func matchesSearch(_ query: String) -> Bool {
        Self.matchesSearch(query, in: [
            senderName,
            bankName,
            description,
            referenceNumber,
            notes,
            transferDate,
            transferDateDisplay,
            displayStatusLabel,
            String(Int(amount)),
            CurrencyFormatter.rupiah(amount),
        ])
    }

    private static func matchesSearch(_ query: String, in values: [String?]) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else {
            return true
        }

        return values.contains { value in
            value?.localizedCaseInsensitiveContains(normalizedQuery) == true
        }
    }

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    private static func decodeFlexibleDouble(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Double {
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }

        if let value = try? container.decode(Int.self, forKey: key) {
            return Double(value)
        }

        if let value = try? container.decode(String.self, forKey: key),
           let doubleValue = Double(value) {
            return doubleValue
        }

        return 0
    }
}

enum IncomingPaymentFilter: String, CaseIterable, Identifiable {
    case all
    case menunggu
    case confirmed
    case rejected

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "Semua"
        case .menunggu: return "Menunggu"
        case .confirmed: return "Dikonfirmasi"
        case .rejected: return "Ditolak"
        }
    }

    func matches(_ payment: IncomingPayment, pendingStatus: String) -> Bool {
        switch self {
        case .all:
            return true
        case .menunggu:
            return payment.normalizedStatus == pendingStatus
        case .confirmed:
            return payment.normalizedStatus == "confirmed"
        case .rejected:
            return payment.normalizedStatus == "rejected"
        }
    }
}

struct IncomingPaymentMetrics {
    let totalAll: Double
    let totalConfirmed: Double
    let pendingCount: Int

    static func make(from payments: [IncomingPayment], pendingStatus: String) -> IncomingPaymentMetrics {
        let totalAll = payments.reduce(0) { $0 + $1.amount }
        let totalConfirmed = payments.filter(\.isConfirmed).reduce(0) { $0 + $1.amount }
        let pendingCount = payments.filter { $0.normalizedStatus == pendingStatus }.count

        return IncomingPaymentMetrics(
            totalAll: totalAll,
            totalConfirmed: totalConfirmed,
            pendingCount: pendingCount
        )
    }

    static func from(summary: WeddingBudgetSummary) -> IncomingPaymentMetrics {
        IncomingPaymentMetrics(
            totalAll: summary.incomingTotal,
            totalConfirmed: summary.incomingConfirmedTotal,
            pendingCount: summary.incomingPendingCount
        )
    }

    /// Prefer live payment list when available — summary `incoming_*` may be missing or stale.
    static func resolve(
        payments: [IncomingPayment],
        summary: WeddingBudgetSummary?,
        pendingStatus: String
    ) -> IncomingPaymentMetrics {
        if !payments.isEmpty {
            return make(from: payments, pendingStatus: pendingStatus)
        }

        if let summary {
            return from(summary: summary)
        }

        return make(from: [], pendingStatus: pendingStatus)
    }
}
