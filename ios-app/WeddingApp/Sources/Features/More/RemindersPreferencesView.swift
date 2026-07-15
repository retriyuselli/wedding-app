import SwiftUI
import UIKit
import UserNotifications

struct RemindersPreferencesView: View {
    @ObservedObject private var pushManager = PushNotificationManager.shared
    @State private var isSendingTest = false

    private var isAuthorized: Bool {
        pushManager.isAuthorized
    }

    private var statusTitle: String {
        switch pushManager.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return L10n.Reminders.statusOn
        case .denied:
            return L10n.Reminders.statusOff
        case .notDetermined:
            return L10n.Reminders.statusNotSet
        @unknown default:
            return L10n.Reminders.statusNotSet
        }
    }

    private var statusSubtitle: String {
        switch pushManager.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return L10n.Reminders.statusOnSub
        case .denied:
            return L10n.Reminders.statusOffSub
        case .notDetermined:
            return L10n.Reminders.statusNotSetSub
        @unknown default:
            return L10n.Reminders.statusNotSetSub
        }
    }

    private var statusIcon: String {
        isAuthorized ? "bell.badge.fill" : "bell.slash.fill"
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Reminders.title,
                        subtitle: L10n.Reminders.subtitle
                    )

                    statusCard

                    preferenceCard

                    testBannerButton

                    if let message = pushManager.lastTestMessage {
                        Text(message)
                            .font(AppFont.regular(12))
                            .foregroundStyle(AppTheme.inkMuted(0.55))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    openSettingsButton

                    infoCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await pushManager.refreshAuthorizationStatus()
            if isAuthorized {
                await pushManager.syncDeviceTokenIfPossible()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
            Task {
                await pushManager.refreshAuthorizationStatus()
                if pushManager.isAuthorized {
                    await pushManager.syncDeviceTokenIfPossible()
                }
            }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            Image(systemName: statusIcon)
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 48, height: 48)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(statusTitle)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)

                Text(statusSubtitle)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 20)
    }

    private var preferenceCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.Reminders.pushToggle)
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.titleOnGlass)

                    Text(L10n.Reminders.pushToggleSub)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Toggle("", isOn: Binding(
                    get: { isAuthorized },
                    set: { newValue in
                        handleToggleChange(wantsEnabled: newValue)
                    }
                ))
                .labelsHidden()
                .tint(AppTheme.sageDark)
            }
            .padding(14)
        }
        .premiumGlassCard(cornerRadius: 20)
    }

    private var testBannerButton: some View {
        Button {
            Task {
                isSendingTest = true
                await pushManager.sendTestBanner()
                isSendingTest = false
            }
        } label: {
            HStack(spacing: 10) {
                if isSendingTest {
                    ProgressView()
                        .tint(AppTheme.sageDark)
                } else {
                    Image(systemName: "bell.and.waves.left.and.right")
                        .font(.system(size: 15, weight: .medium))
                }

                Text(L10n.Reminders.testButton)
                    .font(AppFont.medium(14))

                Spacer(minLength: 0)
            }
            .foregroundStyle(AppTheme.sageDark)
            .padding(14)
            .premiumGlassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .disabled(isSendingTest)
    }

    private var openSettingsButton: some View {
        Button {
            openSystemSettings()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "gearshape")
                    .font(.system(size: 15, weight: .medium))

                Text(L10n.Reminders.openSettings)
                    .font(AppFont.medium(14))

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(AppTheme.sageDark)
            .padding(14)
            .premiumGlassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.sageDark)
                .padding(.top, 1)

            Text(L10n.Reminders.info)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.55))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }

    private func handleToggleChange(wantsEnabled: Bool) {
        switch pushManager.authorizationStatus {
        case .notDetermined:
            if wantsEnabled {
                pushManager.requestAuthorizationAndRegister()
            }
        case .denied:
            openSystemSettings()
        case .authorized, .provisional, .ephemeral:
            if !wantsEnabled {
                openSystemSettings()
            }
        @unknown default:
            openSystemSettings()
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
