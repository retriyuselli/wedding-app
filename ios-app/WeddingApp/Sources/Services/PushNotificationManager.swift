import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private var pendingToken: String?

    private override init() {
        super.init()
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorizationAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                await self.refreshAuthorizationStatus()

                guard granted else { return }

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
        Task { await syncDeviceTokenIfPossible() }
    }

    func syncDeviceTokenIfPossible() async {
        guard let token = pendingToken, KeychainStore.loadToken() != nil else { return }

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
        } catch {
            #if DEBUG
            print("Device token sync failed: \(error)")
            #endif
        }
    }

    func unregisterCurrentDeviceToken() async {
        guard let token = pendingToken else { return }

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
    }

    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        let destination = userInfo["destination"] as? String

        guard destination == "messages" else { return }

        NotificationCenter.default.post(name: .openMessages, object: nil)
    }
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

        guard destination == "messages" else { return }

        await MainActor.run {
            NotificationCenter.default.post(name: .openMessages, object: nil)
        }
    }
}

private struct DeviceTokenRegistration: Decodable {
    let id: Int
    let platform: String
}
