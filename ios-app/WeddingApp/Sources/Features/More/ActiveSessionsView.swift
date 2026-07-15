import SwiftUI

struct ActiveSessionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore

    @State private var sessions: [ActiveSession] = []
    @State private var isLoading = false
    @State private var isRevoking = false
    @State private var errorMessage: String?
    @State private var sessionToRevoke: ActiveSession?
    @State private var showRevokeOthersConfirmation = false

    private var otherSessionsCount: Int {
        sessions.filter { !$0.isCurrent }.count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Sessions.title,
                        subtitle: L10n.Sessions.subtitle
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    infoCard

                    if isLoading && sessions.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if sessions.isEmpty {
                        MoreEmptyState(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: L10n.Sessions.emptyTitle,
                            message: L10n.Sessions.emptyMessage
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(sessions) { item in
                                sessionRow(item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, otherSessionsCount > 0 ? 100 : 24)
            }

            if otherSessionsCount > 0 {
                revokeOthersButton
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await load() }
        .refreshable { await load() }
        .alert(L10n.Sessions.alertEndTitle, isPresented: Binding(
            get: { sessionToRevoke != nil },
            set: { if !$0 { sessionToRevoke = nil } }
        )) {
            Button(L10n.Sessions.alertEndAction, role: .destructive) {
                if let sessionToRevoke {
                    Task { await revoke(sessionToRevoke) }
                }
            }
            Button(L10n.Common.cancel, role: .cancel) {
                sessionToRevoke = nil
            }
        } message: {
            if let sessionToRevoke {
                Text(revokeMessage(for: sessionToRevoke))
            }
        }
        .alert(L10n.Sessions.alertEndAllTitle, isPresented: $showRevokeOthersConfirmation) {
            Button(L10n.Sessions.alertEndAllAction, role: .destructive) {
                Task { await revokeOthers() }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Sessions.alertEndAllMessage)
        }
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.sageDark.opacity(0.75))

            Text(L10n.Sessions.info)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }

    private func sessionRow(_ item: ActiveSession) -> some View {
        HStack(spacing: 14) {
            Image(systemName: deviceIcon(for: item.deviceName))
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 44, height: 44)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(item.deviceName)
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    if item.isCurrent {
                        Text(L10n.Sessions.thisDevice)
                            .font(AppFont.medium(10))
                            .foregroundStyle(AppTheme.sageDark)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.lightSage, in: Capsule())
                    }
                }

                Text(activityText(for: item))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer(minLength: 8)

            if !item.isCurrent || sessions.count > 1 {
                Button {
                    sessionToRevoke = item
                } label: {
                    Text(item.isCurrent ? L10n.Sessions.logout : L10n.Sessions.end)
                        .font(AppFont.medium(12))
                        .foregroundStyle(item.isCurrent ? Color.red.opacity(0.8) : AppTheme.sageDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            (item.isCurrent ? Color.red.opacity(0.08) : AppTheme.lightSage),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
                .disabled(isRevoking)
            }
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }

    private var revokeOthersButton: some View {
        Button {
            showRevokeOthersConfirmation = true
        } label: {
            HStack(spacing: 8) {
                if isRevoking {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(L10n.Sessions.endAll)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isRevoking)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[ActiveSession]> = try await APIClient.shared.request("auth/sessions")
            sessions = envelope.data
        } catch {
            errorMessage = error.userFacingMessage
            sessions = []
        }
    }

    private func revoke(_ item: ActiveSession) async {
        isRevoking = true
        errorMessage = nil
        defer {
            isRevoking = false
            sessionToRevoke = nil
        }

        do {
            let response: RevokeSessionResponse = try await APIClient.shared.request(
                "auth/sessions/\(item.id)",
                method: "DELETE"
            )

            if response.loggedOutCurrentDevice == true {
                session.clearSession()
                dismiss()
                return
            }

            sessions.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func revokeOthers() async {
        isRevoking = true
        errorMessage = nil
        defer { isRevoking = false }

        do {
            let _: RevokeOtherSessionsResponse = try await APIClient.shared.request(
                "auth/sessions/others",
                method: "DELETE"
            )
            await load()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func deviceIcon(for name: String) -> String {
        let lowered = name.lowercased()
        if lowered.contains("ipad") { return "ipad" }
        if lowered.contains("mac") { return "laptopcomputer" }
        if lowered.contains("watch") { return "applewatch" }
        return "iphone"
    }

    private func activityText(for item: ActiveSession) -> String {
        if let lastUsed = displayDate(fromISO: item.lastUsedAt) {
            return L10n.Sessions.lastActive(lastUsed)
        }

        if let createdAt = displayDate(fromISO: item.createdAt) {
            return L10n.Sessions.loginSince(createdAt)
        }

        return L10n.Sessions.active
    }

    private func revokeMessage(for item: ActiveSession) -> String {
        if item.isCurrent {
            return L10n.Sessions.alertEndCurrent
        }

        return L10n.Sessions.alertEndDevice(item.deviceName)
    }

    private func displayDate(fromISO raw: String?) -> String? {
        guard let raw else { return nil }

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
                display.dateFormat = "d MMM yyyy, HH:mm"
                return display.string(from: date)
            }
        }

        return nil
    }
}
