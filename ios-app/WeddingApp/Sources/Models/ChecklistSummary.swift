import Foundation

/// Ringkasan progres checklist persiapan pernikahan dari endpoint
/// `customer-preparation-tasks/summary`.
struct ChecklistSummary: Decodable, Equatable {
    let total: Int
    let completed: Int
    let inProgress: Int
    let todo: Int
    let progress: Double
}
