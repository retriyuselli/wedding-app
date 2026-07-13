import AVFoundation
import Contacts
import Foundation
import Photos
import UIKit
import UserNotifications

struct AppPermissionStatusItem: Identifiable, Hashable {
    let item: AppPermissionItem
    let statusLabel: String
    let isGranted: Bool

    var id: String { item.id }
}

@MainActor
final class AppPermissionsViewModel: ObservableObject {
    @Published private(set) var permissions: [AppPermissionStatusItem] = []
    @Published var isLoading = false
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
            let catalog = try await repository.appPermissions()
            var rows: [AppPermissionStatusItem] = []
            for item in catalog {
                let status = await resolveStatus(for: item.key)
                rows.append(AppPermissionStatusItem(item: item, statusLabel: status.label, isGranted: status.granted))
            }
            permissions = rows
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        successMessage = "Buka Pengaturan iOS untuk mengubah izin aplikasi."
    }

    func retry() async {
        await load()
    }

    private func resolveStatus(for key: String) async -> (label: String, granted: Bool) {
        switch key {
        case "notifications":
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                return ("Diizinkan", true)
            case .denied:
                return ("Ditolak", false)
            default:
                return ("Belum diatur", false)
            }
        case "photos":
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                return ("Diizinkan", true)
            case .denied, .restricted:
                return ("Ditolak", false)
            default:
                return ("Belum diatur", false)
            }
        case "camera":
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return ("Diizinkan", true)
            case .denied, .restricted:
                return ("Ditolak", false)
            default:
                return ("Belum diatur", false)
            }
        case "contacts":
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                return ("Diizinkan", true)
            case .denied, .restricted:
                return ("Ditolak", false)
            default:
                return ("Belum diatur", false)
            }
        default:
            return ("Tidak diketahui", false)
        }
    }
}
