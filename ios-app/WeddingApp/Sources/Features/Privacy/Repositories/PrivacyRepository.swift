import Foundation

protocol PrivacyRepositoryProtocol: Sendable {
    func securitySummary() async throws -> PrivacySecuritySummary
    func visibilitySettings() async throws -> PrivacyVisibilitySettings
    func saveVisibility(
        _ settings: PrivacyVisibilitySettings,
        partnerEmail: String?
    ) async throws -> (PrivacyVisibilitySettings, String?)
    func appPermissions() async throws -> [AppPermissionItem]
    func exportAccountData() async throws -> URL
    func twoFactorStatus() async throws -> TwoFactorStatus
    func startEnableTwoFactor() async throws -> String
    func finishEnableTwoFactor(code: String) async throws -> (TwoFactorStatus, String)
    func startDisableTwoFactor() async throws -> String
    func finishDisableTwoFactor(code: String, password: String?) async throws -> (TwoFactorStatus, String)
    func trustedDevices() async throws -> [TrustedDevice]
    func trustCurrentDevice() async throws -> TrustedDevice
    func setDeviceTrusted(id: Int, trusted: Bool) async throws -> TrustedDevice
    func removeTrustedDevice(id: Int) async throws
    func helpCenter(locale: String) async throws -> HelpCenterPayload
    func completeTwoFactorLogin(token: String, code: String) async throws -> AuthResponse
}

struct PrivacyRepository: PrivacyRepositoryProtocol {
    private let service: any PrivacyAPIServiceProtocol

    init(service: any PrivacyAPIServiceProtocol = PrivacyAPIService()) {
        self.service = service
    }

    func securitySummary() async throws -> PrivacySecuritySummary {
        try await service.fetchSummary()
    }

    func visibilitySettings() async throws -> PrivacyVisibilitySettings {
        try await service.fetchVisibility()
    }

    func saveVisibility(
        _ settings: PrivacyVisibilitySettings,
        partnerEmail: String?
    ) async throws -> (PrivacyVisibilitySettings, String?) {
        try await service.updateVisibility(settings, partnerEmail: partnerEmail)
    }

    func appPermissions() async throws -> [AppPermissionItem] {
        try await service.fetchAppPermissions()
    }

    func exportAccountData() async throws -> URL {
        let downloaded = try await service.downloadDataExport()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(downloaded.1)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try downloaded.0.write(to: url, options: .atomic)
        return url
    }

    func twoFactorStatus() async throws -> TwoFactorStatus {
        try await service.fetchTwoFactorStatus()
    }

    func startEnableTwoFactor() async throws -> String {
        try await service.requestEnableTwoFactor()
    }

    func finishEnableTwoFactor(code: String) async throws -> (TwoFactorStatus, String) {
        try await service.confirmEnableTwoFactor(code: code)
    }

    func startDisableTwoFactor() async throws -> String {
        try await service.requestDisableTwoFactor()
    }

    func finishDisableTwoFactor(code: String, password: String?) async throws -> (TwoFactorStatus, String) {
        try await service.confirmDisableTwoFactor(code: code, password: password)
    }

    func trustedDevices() async throws -> [TrustedDevice] {
        try await service.fetchTrustedDevices(currentIdentifier: DeviceIdentity.identifier)
    }

    func trustCurrentDevice() async throws -> TrustedDevice {
        try await service.registerTrustedDevice(
            name: DeviceIdentity.name,
            identifier: DeviceIdentity.identifier,
            trusted: true
        )
    }

    func setDeviceTrusted(id: Int, trusted: Bool) async throws -> TrustedDevice {
        try await service.updateTrustedDevice(id: id, isTrusted: trusted)
    }

    func removeTrustedDevice(id: Int) async throws {
        try await service.deleteTrustedDevice(id: id)
    }

    func helpCenter(locale: String) async throws -> HelpCenterPayload {
        try await service.fetchHelpCenter(locale: locale)
    }

    func completeTwoFactorLogin(token: String, code: String) async throws -> AuthResponse {
        try await service.verifyTwoFactorLogin(
            token: token,
            code: code,
            deviceName: DeviceIdentity.name
        )
    }
}
