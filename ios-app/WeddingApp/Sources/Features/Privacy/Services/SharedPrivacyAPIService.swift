import Foundation

protocol SharedPrivacyAPIServiceProtocol: Sendable {
    func fetchDirectory() async throws -> [SharedDirectoryUser]
    func fetchProfile(userId: Int) async throws -> (SharedDirectoryUser, String?)
    func fetchWedding(userId: Int) async throws -> (SharedWeddingPayload, String?)
    func fetchGuests(userId: Int) async throws -> ([Guest], String?)
    func fetchBudget(userId: Int) async throws -> (SharedBudgetPayload, String?)
    func requestVendorContact(userId: Int) async throws -> (SharedVendorContactResult, String?)
}

struct SharedPrivacyAPIService: SharedPrivacyAPIServiceProtocol {
    func fetchDirectory() async throws -> [SharedDirectoryUser] {
        let envelope: Envelope<[SharedDirectoryUser]> = try await APIClient.shared.request("shared/directory")
        return envelope.data
    }

    func fetchProfile(userId: Int) async throws -> (SharedDirectoryUser, String?) {
        let envelope: SharedDataEnvelope<SharedDirectoryUser> = try await APIClient.shared.request(
            "shared/users/\(userId)/profile"
        )
        return (envelope.data, envelope.meta?.viewerRole)
    }

    func fetchWedding(userId: Int) async throws -> (SharedWeddingPayload, String?) {
        let envelope: SharedDataEnvelope<SharedWeddingPayload> = try await APIClient.shared.request(
            "shared/users/\(userId)/wedding"
        )
        return (envelope.data, envelope.meta?.viewerRole)
    }

    func fetchGuests(userId: Int) async throws -> ([Guest], String?) {
        let envelope: SharedDataEnvelope<[Guest]> = try await APIClient.shared.request(
            "shared/users/\(userId)/guests"
        )
        return (envelope.data, envelope.meta?.viewerRole)
    }

    func fetchBudget(userId: Int) async throws -> (SharedBudgetPayload, String?) {
        let envelope: SharedDataEnvelope<SharedBudgetPayload> = try await APIClient.shared.request(
            "shared/users/\(userId)/budget"
        )
        return (envelope.data, envelope.meta?.viewerRole)
    }

    func requestVendorContact(userId: Int) async throws -> (SharedVendorContactResult, String?) {
        let envelope: SharedMessageEnvelope<SharedVendorContactResult> = try await APIClient.shared.request(
            "shared/users/\(userId)/vendor-contact",
            method: "POST"
        )
        return (envelope.data, envelope.message)
    }
}
