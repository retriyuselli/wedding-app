import Foundation

protocol SharedPrivacyRepositoryProtocol: Sendable {
    func directory() async throws -> [SharedDirectoryUser]
    func profile(userId: Int) async throws -> (SharedDirectoryUser, String?)
    func wedding(userId: Int) async throws -> (SharedWeddingPayload, String?)
    func guests(userId: Int) async throws -> ([Guest], String?)
    func budget(userId: Int) async throws -> (SharedBudgetPayload, String?)
    func vendorContact(userId: Int) async throws -> (SharedVendorContactResult, String?)
}

struct SharedPrivacyRepository: SharedPrivacyRepositoryProtocol {
    private let service: any SharedPrivacyAPIServiceProtocol

    init(service: any SharedPrivacyAPIServiceProtocol = SharedPrivacyAPIService()) {
        self.service = service
    }

    func directory() async throws -> [SharedDirectoryUser] {
        try await service.fetchDirectory()
    }

    func profile(userId: Int) async throws -> (SharedDirectoryUser, String?) {
        try await service.fetchProfile(userId: userId)
    }

    func wedding(userId: Int) async throws -> (SharedWeddingPayload, String?) {
        try await service.fetchWedding(userId: userId)
    }

    func guests(userId: Int) async throws -> ([Guest], String?) {
        try await service.fetchGuests(userId: userId)
    }

    func budget(userId: Int) async throws -> (SharedBudgetPayload, String?) {
        try await service.fetchBudget(userId: userId)
    }

    func vendorContact(userId: Int) async throws -> (SharedVendorContactResult, String?) {
        try await service.requestVendorContact(userId: userId)
    }
}
