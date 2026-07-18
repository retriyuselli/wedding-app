import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var lastTestMessage: String?

    private static let tokenDefaultsKey = "push.apnsDeviceToken"

    private var pendingToken: String? {
        didSet {
            if let pendingToken {
                UserDefaults.standard.set(pendingToken, forKey: Self.tokenDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.tokenDefaultsKey)
            }
        }
    }

    private override init() {
        super.init()
        pendingToken = UserDefaults.standard.string(forKey: Self.tokenDefaultsKey)
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self

        Task {
            await refreshAuthorizationStatus()
            if isAuthorized {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized
            || authorizationStatus == .provisional
            || authorizationStatus == .ephemeral
    }

    /// Minta izin (jika belum) dan daftarkan ulang ke APNs setelah user login.
    func prepareAfterAuthentication() async {
        await refreshAuthorizationStatus()

        switch authorizationStatus {
        case .notDetermined:
            requestAuthorizationAndRegister()
        case .authorized, .provisional, .ephemeral:
            UIApplication.shared.registerForRemoteNotifications()
            await syncDeviceTokenIfPossible()
        case .denied:
            #if DEBUG
            print("[Push] Notifications denied — buka Pengaturan iOS untuk mengaktifkan.")
            #endif
        @unknown default:
            break
        }
    }

    func promptForAuthorizationIfNeeded() async {
        await prepareAfterAuthentication()
    }

    func requestAuthorizationAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                await self.refreshAuthorizationStatus()

                guard granted else {
                    #if DEBUG
                    print("[Push] User menolak izin notifikasi.")
                    #endif
                    return
                }

                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func updateDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        pendingToken = token

        #if DEBUG
        print("[Push] Device token received (\(token.prefix(12))...)")
        #endif

        Task { await syncDeviceTokenIfPossible() }
    }

    func syncDeviceTokenIfPossible() async {
        guard let token = pendingToken else {
            #if DEBUG
            print("[Push] Belum ada device token dari APNs — tunggu registerForRemoteNotifications.")
            #endif
            return
        }

        guard KeychainStore.loadToken() != nil else {
            #if DEBUG
            print("[Push] Token APNs ada, tapi user belum login — sync ditunda.")
            #endif
            return
        }

        do {
            let _: Envelope<DeviceTokenRegistration> = try await APIClient.shared.request(
                "device-tokens",
                method: "POST",
                json: [
                    "token": token,
                    "platform": "ios",
                    "device_name": UIDevice.current.name,
                ]
            )

            #if DEBUG
            print("[Push] Device token synced to backend")
            #endif
        } catch {
            #if DEBUG
            print("[Push] Device token sync failed: \(error)")
            #endif
        }
    }

    func unregisterCurrentDeviceToken() async {
        guard let token = pendingToken else {
            return
        }

        do {
            try await APIClient.shared.requestNoContent(
                "device-tokens",
                method: "DELETE",
                json: ["token": token]
            )
        } catch {
            #if DEBUG
            print("Device token unregister failed: \(error)")
            #endif
        }

        pendingToken = nil
    }

    /// Menampilkan banner sistem lokal (berguna untuk uji tanpa APNs).
    func scheduleLocalBanner(
        title: String,
        body: String,
        delay: TimeInterval = 1,
        userInfo: [AnyHashable: Any] = ["destination": "messages", "type": "local_test"]
    ) async throws {
        await refreshAuthorizationStatus()

        guard isAuthorized else {
            throw PushNotificationError.notAuthorized
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 0.5), repeats: false)
        let request = UNNotificationRequest(
            identifier: "weddingapp.local.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await UNUserNotificationCenter.current().add(request)
    }

    /// Kirim banner uji: lokal dulu, lalu remote lewat backend bila token sudah terdaftar.
    func sendTestBanner() async {
        lastTestMessage = nil

        do {
            try await scheduleLocalBanner(
                title: L10n.Reminders.testTitle,
                body: L10n.Reminders.testBodyLocal
            )
        } catch {
            if authorizationStatus == .notDetermined {
                requestAuthorizationAndRegister()
                lastTestMessage = L10n.Reminders.testNeedsPermission
            } else if authorizationStatus == .denied {
                lastTestMessage = L10n.Reminders.testDenied
            } else {
                lastTestMessage = L10n.Reminders.testFailed
            }
            return
        }

        await syncDeviceTokenIfPossible()

        do {
            let envelope: Envelope<PushTestResult> = try await APIClient.shared.request(
                "device-tokens/test",
                method: "POST"
            )
            let sent = envelope.data.sent
            lastTestMessage = sent > 0
                ? L10n.Reminders.testRemoteSent(sent)
                : L10n.Reminders.testLocalOnly
        } catch {
            lastTestMessage = L10n.Reminders.testLocalOnly
            #if DEBUG
            print("[Push] Remote test failed: \(error)")
            #endif
        }
    }

    func sendAdminNotification(
        title: String,
        message: String,
        recipientEmail: String?,
        sendToAll: Bool
    ) async throws -> String {
        let response: AdminNotificationResponse = try await APIClient.shared.request(
            "device-tokens/send-notification",
            method: "POST",
            json: [
                "send_to_all": sendToAll,
                "email": recipientEmail ?? NSNull(),
                "title": title,
                "message": message,
            ]
        )

        return response.message
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        routeDestination(userInfo["destination"] as? String)
    }

    private func routeDestination(_ destination: String?) {
        guard destination == "messages" else {
            return
        }

        NotificationCenter.default.post(name: .openMessages, object: nil)
    }
}

enum PushNotificationError: Error {
    case notAuthorized
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let destination = response.notification.request.content.userInfo["destination"] as? String

        await MainActor.run {
            PushNotificationManager.shared.routeDestination(destination)
        }
    }
}

private struct DeviceTokenRegistration: Decodable {
    let id: Int
    let platform: String
}

private struct PushTestResult: Decodable {
    let sent: Int
    let tokenCount: Int
}

private struct AdminNotificationResponse: Decodable {
    let message: String
}
