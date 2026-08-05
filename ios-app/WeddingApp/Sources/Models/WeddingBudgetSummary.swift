import Foundation

struct WeddingBudgetSummary: Decodable {
    let totalBudget: Double
    let spent: Double
    let commitment: Double
    let remaining: Double
    let spentPercent: Int
    let commitmentPercent: Int
    let remainingPercent: Int
    let plannedAllocationTotal: Double
    let planCoveragePercent: Int?
    let incomingTotal: Double
    let incomingConfirmedTotal: Double
    let incomingPendingCount: Int

    private enum CodingKeys: String, CodingKey {
        case totalBudget
        case spent
        case commitment
        case remaining
        case spentPercent
        case commitmentPercent
        case remainingPercent
        case plannedAllocationTotal
        case planCoveragePercent
        case incomingTotal
        case incomingConfirmedTotal
        case incomingPendingCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        totalBudget = Self.decodeFlexibleDouble(from: container, forKey: .totalBudget)
        spent = Self.decodeFlexibleDouble(from: container, forKey: .spent)
        commitment = Self.decodeFlexibleDouble(from: container, forKey: .commitment)
        remaining = Self.decodeFlexibleDouble(from: container, forKey: .remaining)
        spentPercent = Self.decodeFlexibleInt(from: container, forKey: .spentPercent) ?? 0
        commitmentPercent = Self.decodeFlexibleInt(from: container, forKey: .commitmentPercent) ?? 0
        remainingPercent = Self.decodeFlexibleInt(from: container, forKey: .remainingPercent) ?? 0
        plannedAllocationTotal = Self.decodeFlexibleDouble(from: container, forKey: .plannedAllocationTotal)
        planCoveragePercent = Self.decodeFlexibleInt(from: container, forKey: .planCoveragePercent)
        incomingTotal = Self.decodeFlexibleDouble(from: container, forKey: .incomingTotal)
        incomingConfirmedTotal = Self.decodeFlexibleDouble(from: container, forKey: .incomingConfirmedTotal)
        incomingPendingCount = Self.decodeFlexibleInt(from: container, forKey: .incomingPendingCount) ?? 0
    }

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

    private static func decodeFlexibleInt(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Int? {
        if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
            return value
        }

        if let value = try? container.decodeIfPresent(String.self, forKey: key),
           let intValue = Int(value) {
            return intValue
        }

        return nil
    }
}
