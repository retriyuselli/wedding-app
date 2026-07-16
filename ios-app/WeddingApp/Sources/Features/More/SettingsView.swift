import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var pushManager = PushNotificationManager.shared
    @ObservedObject private var languageStore = LanguageStore.shared
    @ObservedObject private var appearance = AppearanceStore.shared

    @State private var showComingSoon = false
    @State private var showPaywall = false

    private var notificationStatusSubtitle: String {
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

    private var languageSubtitle: String {
        if LanguageFeature.isSelectionEnabled {
            return languageStore.selected.nativeSubtitle
        }
        return L10n.Language.indonesian
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Settings.title,
                        subtitle: L10n.Settings.subtitle
                    )

                    preferencesSection

                    appearanceSection

                    accountSection

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
        }
        .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
            Task { await pushManager.refreshAuthorizationStatus() }
        }
        .alert(L10n.Common.comingSoon, isPresented: $showComingSoon) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.Common.comingSoonMessage)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(session)
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        section(title: L10n.Settings.preferencesSection) {
            NavigationLink {
                RemindersPreferencesView()
            } label: {
                rowContent(
                    icon: "bell",
                    title: L10n.Settings.notifications,
                    subtitle: notificationStatusSubtitle
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            divider

            if LanguageFeature.isSelectionEnabled {
                NavigationLink {
                    LanguageSettingsView()
                } label: {
                    rowContent(
                        icon: "globe",
                        title: L10n.Settings.language,
                        subtitle: languageSubtitle
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    showComingSoon = true
                } label: {
                    rowContent(
                        icon: "globe",
                        title: L10n.Settings.language,
                        subtitle: languageSubtitle,
                        trailingText: L10n.Common.soon
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        section(title: L10n.Settings.appearanceSection) {
            NavigationLink {
                ThemeSettingsView()
            } label: {
                rowContent(
                    icon: "paintpalette",
                    title: L10n.Settings.theme,
                    subtitle: appearance.colorPalette.title
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            divider

            NavigationLink {
                TextSizeSettingsView()
            } label: {
                rowContent(
                    icon: "textformat.size",
                    title: L10n.Settings.textSize,
                    subtitle: appearance.textSize.title
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            divider

            NavigationLink {
                CountdownFontSettingsView()
            } label: {
                rowContent(
                    icon: "timer",
                    title: L10n.Settings.countdown,
                    subtitle: appearance.countdownFont.title
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        section(title: L10n.Settings.accountSection) {
            Button {
                if !session.isPremium {
                    showPaywall = true
                }
            } label: {
                rowContent(
                    icon: session.isPremium ? "checkmark.seal.fill" : "sparkles",
                    title: L10n.Premium.menuTitle,
                    subtitle: session.isPremium ? L10n.Premium.menuActiveSub : L10n.Premium.menuSub,
                    trailingText: session.isPremium ? L10n.Premium.statusActive : nil
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            divider

            NavigationLink {
                EditProfileView()
            } label: {
                rowContent(
                    icon: "person.crop.circle",
                    title: L10n.Settings.editProfile,
                    subtitle: L10n.Settings.editProfileSub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            divider

            NavigationLink {
                PrivacySecurityView()
            } label: {
                rowContent(
                    icon: "lock.shield",
                    title: L10n.Settings.privacySecurity,
                    subtitle: L10n.Settings.privacySecuritySub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark.opacity(0.8))
                .padding(.top, 1)

            Text(L10n.Settings.info)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }

    // MARK: - Building Blocks

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .premiumGlassCard(cornerRadius: 20)
        }
    }

    private var divider: some View {
        Divider()
            .padding(.leading, 62)
    }

    private func rowContent(
        icon: String,
        title: String,
        subtitle: String,
        trailingText: String? = nil
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.sage.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if let trailingText {
                Text(trailingText)
                    .font(AppFont.medium(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.mist, in: Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
    }
}
