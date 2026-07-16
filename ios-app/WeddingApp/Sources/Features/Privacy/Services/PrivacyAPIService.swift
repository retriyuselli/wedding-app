import Foundation

protocol PrivacyAPIServiceProtocol: Sendable {
    func fetchSummary() async throws -> PrivacySecuritySummary
    func fetchVisibility() async throws -> PrivacyVisibilitySettings
    func updateVisibility(
        _ settings: PrivacyVisibilitySettings,
        partnerEmail: String?
    ) async throws -> (PrivacyVisibilitySettings, String?)
    func fetchAppPermissions() async throws -> [AppPermissionItem]
    func downloadDataExport() async throws -> (Data, String)
    func fetchTwoFactorStatus() async throws -> TwoFactorStatus
    func requestEnableTwoFactor() async throws -> String
    func confirmEnableTwoFactor(code: String) async throws -> (TwoFactorStatus, String)
    func requestDisableTwoFactor() async throws -> String
    func confirmDisableTwoFactor(code: String, password: String?) async throws -> (TwoFactorStatus, String)
    func fetchTrustedDevices(currentIdentifier: String) async throws -> [TrustedDevice]
    func registerTrustedDevice(name: String, identifier: String, trusted: Bool) async throws -> TrustedDevice
    func updateTrustedDevice(id: Int, isTrusted: Bool) async throws -> TrustedDevice
    func deleteTrustedDevice(id: Int) async throws
    func fetchHelpCenter(locale: String) async throws -> HelpCenterPayload
    func verifyTwoFactorLogin(token: String, code: String, deviceName: String) async throws -> AuthResponse
}

struct PrivacyAPIService: PrivacyAPIServiceProtocol {
    func fetchSummary() async throws -> PrivacySecuritySummary {
        let envelope: Envelope<PrivacySecuritySummary> = try await APIClient.shared.request("privacy/summary")
        return envelope.data
    }

    func fetchVisibility() async throws -> PrivacyVisibilitySettings {
        let envelope: Envelope<PrivacyVisibilitySettings> = try await APIClient.shared.request("privacy/visibility")
        return envelope.data
    }

    func updateVisibility(
        _ settings: PrivacyVisibilitySettings,
        partnerEmail: String?
    ) async throws -> (PrivacyVisibilitySettings, String?) {
        var json: [String: Any] = [
            "profile_visibility": settings.profileVisibility,
            "wedding_visibility": settings.weddingVisibility,
            "guest_list_visibility": settings.guestListVisibility,
            "budget_visibility": settings.budgetVisibility,
            "show_in_directory": settings.showInDirectory,
            "allow_vendor_contact": settings.allowVendorContact,
        ]

        if let partnerEmail {
            json["partner_email"] = partnerEmail
        }

        let response: VisibilityUpdateResponse = try await APIClient.shared.request(
            "privacy/visibility",
            method: "PUT",
            json: json
        )
        return (response.data, response.message)
    }

    func fetchAppPermissions() async throws -> [AppPermissionItem] {
        let envelope: Envelope<[AppPermissionItem]> = try await APIClient.shared.request("privacy/app-permissions")
        return envelope.data
    }

    func downloadDataExport() async throws -> (Data, String) {
        try await APIClient.shared.downloadFile(
            "privacy/data-export",
            fallbackFileName: "wedding-app-data-export.zip"
        )
    }

    func fetchTwoFactorStatus() async throws -> TwoFactorStatus {
        let envelope: Envelope<TwoFactorStatus> = try await APIClient.shared.request("privacy/two-factor")
        return envelope.data
    }

    func requestEnableTwoFactor() async throws -> String {
        let response: MessageResponse = try await APIClient.shared.request(
            "privacy/two-factor/enable",
            method: "POST"
        )
        return response.message
    }

    func confirmEnableTwoFactor(code: String) async throws -> (TwoFactorStatus, String) {
        let response: MessageEnvelope = try await APIClient.shared.request(
            "privacy/two-factor/confirm",
            method: "POST",
            json: ["code": code]
        )
        let status = response.data ?? TwoFactorStatus(enabled: true, method: "email", email: nil)
        return (status, response.message)
    }

    func requestDisableTwoFactor() async throws -> String {
        let response: MessageResponse = try await APIClient.shared.request(
            "privacy/two-factor/disable",
            method: "POST"
        )
        return response.message
    }

    func confirmDisableTwoFactor(code: String, password: String?) async throws -> (TwoFactorStatus, String) {
        var json: [String: Any] = ["code": code]
        if let password, !password.isEmpty {
            json["password"] = password
        }
        let response: MessageEnvelope = try await APIClient.shared.request(
            "privacy/two-factor/confirm-disable",
            method: "POST",
            json: json
        )
        let status = response.data ?? TwoFactorStatus(enabled: false, method: "email", email: nil)
        return (status, response.message)
    }

    func fetchTrustedDevices(currentIdentifier: String) async throws -> [TrustedDevice] {
        let envelope: Envelope<[TrustedDevice]> = try await APIClient.shared.request(
            "privacy/trusted-devices",
            queryItems: [URLQueryItem(name: "current_device_identifier", value: currentIdentifier)]
        )
        return envelope.data
    }

    func registerTrustedDevice(name: String, identifier: String, trusted: Bool) async throws -> TrustedDevice {
        let response: TrustedDeviceCreateResponse = try await APIClient.shared.request(
            "privacy/trusted-devices",
            method: "POST",
            json: [
                "device_name": name,
                "device_identifier": identifier,
                "platform": DeviceIdentity.platform,
                "is_trusted": trusted,
            ]
        )
        return response.data
    }

    func updateTrustedDevice(id: Int, isTrusted: Bool) async throws -> TrustedDevice {
        let response: TrustedDeviceCreateResponse = try await APIClient.shared.request(
            "privacy/trusted-devices/\(id)",
            method: "PUT",
            json: ["is_trusted": isTrusted]
        )
        return response.data
    }

    func deleteTrustedDevice(id: Int) async throws {
        try await APIClient.shared.requestNoContent("privacy/trusted-devices/\(id)", method: "DELETE")
    }

    func fetchHelpCenter(locale: String) async throws -> HelpCenterPayload {
        let envelope: Envelope<HelpCenterPayload> = try await APIClient.shared.request(
            "help-center",
            queryItems: [URLQueryItem(name: "locale", value: locale)]
        )
        return envelope.data
    }

    func verifyTwoFactorLogin(token: String, code: String, deviceName: String) async throws -> AuthResponse {
        try await APIClient.shared.request(
            "auth/two-factor/verify",
            method: "POST",
            json: [
                "two_factor_token": token,
                "code": code,
                "device_name": deviceName,
            ]
        )
    }
}

private struct VisibilityUpdateResponse: Codable {
    let data: PrivacyVisibilitySettings
    let message: String?
}

private struct TrustedDeviceCreateResponse: Codable {
    let data: TrustedDevice
    let message: String?
}
