import Foundation

struct SharedDirectoryUser: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let avatarUrl: String?
    let profileVisibility: String?
    let showInDirectory: Bool?
    let allowVendorContact: Bool?
    let couplePreview: String?
    let budaya: String?
}

struct SharedWeddingPayload: Codable {
    let weddingInfo: WeddingInfo
    let events: [WeddingEvent]
}

struct SharedBudgetPayload: Decodable {
    let budget: WeddingBudget
    let summary: WeddingBudgetSummary
}

struct SharedVendorContactResult: Codable, Hashable {
    let userId: Int
    let allowVendorContact: Bool
    let whatsapp: String?
    let email: String?
}

struct ViewerRoleMeta: Codable, Hashable {
    let viewerRole: String?
}

struct SharedDataEnvelope<T: Decodable>: Decodable {
    let data: T
    let meta: ViewerRoleMeta?
}

struct SharedMessageEnvelope<T: Decodable>: Decodable {
    let message: String?
    let data: T
}
