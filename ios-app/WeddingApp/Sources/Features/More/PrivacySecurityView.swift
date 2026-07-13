import SwiftUI

struct PrivacySecurityView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = PrivacySecurityViewModel()

    @State private var showSocialLoginPasswordAlert = false

    private var usesSocialLogin: Bool {
        session.currentUser?.hasSocialLogin ?? false
    }

    private var passwordSubtitle: String {
        if usesSocialLogin {
            return L10n.Privacy.loginViaSocial
        }

        if let updatedAt = session.currentUser?.passwordChangedAt ?? session.currentUser?.updatedAt,
           let formatted = displayDate(fromISO: updatedAt) {
            return L10n.Privacy.passwordLastChanged(formatted)
        }

        return L10n.Privacy.passwordUpdateHint
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.title,
                        subtitle: L10n.Privacy.subtitle
                    )

                    if let errorMessage = viewModel.errorMessage, viewModel.summary == nil {
                        VStack(spacing: 8) {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                            Button("Coba lagi") {
                                Task { await viewModel.retry() }
                            }
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageDark)
                        }
                    }

                    summaryCard
                    privacySettingsSection
                    accountSecuritySection
                    privacyPolicyCard
                    helpRow
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .refreshable { await viewModel.retry() }
        .alert(L10n.Common.notAvailable, isPresented: $showSocialLoginPasswordAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(L10n.Privacy.socialLoginPassword)
        }
    }

    private var summaryCard: some View {
        NavigationLink {
            SecuritySummaryView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.summary?.title ?? L10n.Privacy.accountSafe)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.sageDark)
                    Text(viewModel.summary?.message ?? L10n.Privacy.accountSafeSub)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.28))
                }
            }
            .padding(16)
            .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var privacySettingsSection: some View {
        section(title: L10n.Privacy.privacySettings) {
            NavigationLink {
                DataVisibilityView()
            } label: {
                rowContent(
                    icon: "lock",
                    title: L10n.Privacy.dataVisibility,
                    subtitle: L10n.Privacy.dataVisibilitySub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            divider
            NavigationLink {
                RemindersPreferencesView()
            } label: {
                rowContent(
                    icon: "bell.slash",
                    title: L10n.Privacy.notifications,
                    subtitle: L10n.Privacy.notificationsSub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            divider
            NavigationLink {
                AppPermissionsView()
            } label: {
                rowContent(
                    icon: "chart.bar",
                    title: L10n.Privacy.permissions,
                    subtitle: L10n.Privacy.permissionsSub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            divider
            NavigationLink {
                DataExportView()
            } label: {
                rowContent(
                    icon: "arrow.down.to.line",
                    title: L10n.Privacy.downloadData,
                    subtitle: L10n.Privacy.downloadDataSub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            divider
            NavigationLink {
                DeleteAccountView()
            } label: {
                rowContent(
                    icon: "trash",
                    title: L10n.Privacy.deleteAccount,
                    subtitle: L10n.Privacy.deleteAccountSub,
                    isDestructive: true
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var accountSecuritySection: some View {
        section(title: L10n.Privacy.accountSecurity) {
            Group {
                if usesSocialLogin {
                    Button {
                        showSocialLoginPasswordAlert = true
                    } label: {
                        rowContent(
                            icon: "key",
                            title: L10n.Privacy.changePassword,
                            subtitle: passwordSubtitle
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        rowContent(
                            icon: "key",
                            title: L10n.Privacy.changePassword,
                            subtitle: passwordSubtitle
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            divider
            NavigationLink {
                TrustedDevicesView()
            } label: {
                rowContent(
                    icon: "iphone",
                    title: L10n.Privacy.trustedDevices,
                    subtitle: L10n.Privacy.trustedDevicesSub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            divider
            NavigationLink {
                TwoFactorSettingsView()
            } label: {
                rowContent(
                    icon: "checkmark.shield",
                    title: L10n.Privacy.twoFactor,
                    subtitle: L10n.Privacy.twoFactorSub,
                    trailingText: viewModel.twoFactorEnabled
                        ? L10n.Privacy.twoFactorActive
                        : L10n.Privacy.twoFactorInactive
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            divider
            NavigationLink {
                ActiveSessionsView()
            } label: {
                rowContent(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: L10n.Privacy.activeSessions,
                    subtitle: L10n.Privacy.activeSessionsSub
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var privacyPolicyCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.sageDark.opacity(0.8))

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Privacy.commitment)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Privacy.privacyPolicy)
                            .font(AppFont.medium(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
    }

    private var helpRow: some View {
        NavigationLink {
            HelpCenterAPIView()
        } label: {
            rowContent(
                icon: "questionmark.circle",
                title: L10n.Privacy.helpCenter,
                subtitle: L10n.Privacy.helpCenterSub
            )
            .padding(14)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
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
        trailingText: String? = nil,
        isDestructive: Bool = false
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(isDestructive ? Color.red.opacity(0.75) : AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(
                    (isDestructive ? Color.red.opacity(0.10) : AppTheme.sage.opacity(0.12)),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(isDestructive ? Color.red.opacity(0.85) : AppTheme.ink)
                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            if let trailingText {
                Text(trailingText)
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
    }

    private func displayDate(fromISO raw: String) -> String? {
        let parsers = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd",
        ]

        for format in parsers {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                let display = DateFormatter()
                display.locale = LocalizationManager.shared.locale
                display.dateFormat = "d MMM yyyy"
                return display.string(from: date)
            }
        }

        return nil
    }
}
