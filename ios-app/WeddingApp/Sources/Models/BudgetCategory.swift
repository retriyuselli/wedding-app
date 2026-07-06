import Foundation

struct BudgetCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let iconName: String
    /// Total expense entries recorded in this category (paid + unpaid).
    let allocated: Double
    let spent: Double
    let commitment: Double

    var totalRecorded: Double { spent + commitment }

    var spentRatio: Double {
        totalRecorded == 0 ? 0 : spent / totalRecorded
    }

    static let paymentCategoryOptions: [(key: String, label: String)] = [
        ("venue", "Venue"),
        ("catering", "Catering"),
        ("decoration", "Dekorasi"),
        ("photo_video", "Foto & Video"),
        ("entertainment", "Entertainment"),
        ("makeup", "Makeup & Busana"),
        ("transport", "Transportasi"),
        ("wo", "Wedding Organizer"),
        ("other", "Lainnya"),
    ]

    static func icon(for key: String) -> String {
        switch key.lowercased() {
        case "venue": return "building.columns"
        case "catering": return "fork.knife"
        case "decoration", "dekorasi": return "leaf"
        case "photo_video", "fotografi": return "camera"
        case "makeup", "busana": return "figure.dress.line.vertical.figure"
        case "entertainment": return "music.note"
        case "transport": return "car"
        case "wo": return "person.badge.shield.checkmark"
        default: return "ellipsis"
        }
    }

    static func label(for key: String) -> String {
        paymentCategoryOptions.first(where: { $0.key == key })?.label ?? key.capitalized
    }

    static func build(from schedules: [PaymentSchedule]) -> [BudgetCategory] {
        guard !schedules.isEmpty else { return [] }

        let grouped = Dictionary(grouping: schedules) { $0.category ?? "other" }
        return grouped
            .map { key, items in make(id: key, items: items) }
            .sorted { $0.totalRecorded > $1.totalRecorded }
    }

    static func make(id: String, items: [PaymentSchedule]) -> BudgetCategory {
        let spent = items.filter(\.isPaid).reduce(0) { $0 + $1.amount }
        let commitment = items.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
        let label = items.first?.categoryLabel ?? Self.label(for: id)

        return BudgetCategory(
            id: id,
            name: label,
            iconName: Self.icon(for: id),
            allocated: spent + commitment,
            spent: spent,
            commitment: commitment
        )
    }
}
