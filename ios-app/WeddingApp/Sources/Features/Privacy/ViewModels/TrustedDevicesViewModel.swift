import Foundation

@MainActor
final class TrustedDevicesViewModel: ObservableObject {
    @Published private(set) var devices: [TrustedDevice] = []
    @Published var isLoading = false
    @Published var isBusy = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let repository: any PrivacyRepositoryProtocol

    init(repository: any PrivacyRepositoryProtocol = PrivacyRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            devices = try await repository.trustedDevices()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func trustThisDevice() async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            _ = try await repository.trustCurrentDevice()
            successMessage = "Perangkat ini ditandai sebagai tepercaya."
            await load()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func toggleTrust(_ device: TrustedDevice) async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            _ = try await repository.setDeviceTrusted(id: device.id, trusted: !device.isTrusted)
            successMessage = device.isTrusted ? "Kepercayaan perangkat dicabut." : "Perangkat dipercaya."
            await load()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func delete(_ device: TrustedDevice) async {
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            try await repository.removeTrustedDevice(id: device.id)
            successMessage = "Perangkat dihapus dari daftar."
            await load()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func retry() async {
        await load()
    }
}
