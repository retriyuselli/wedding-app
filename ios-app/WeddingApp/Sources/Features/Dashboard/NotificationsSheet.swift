import SwiftUI

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore

    var onUnreadCountChange: ((Int) -> Void)?

    @State private var notifications: [CustomerNotification] = []
    @State private var unreadOnly = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var unreadCount: Int {
        notifications.filter(\.isUnread).count
    }

    private var visibleNotifications: [CustomerNotification] {
        unreadOnly ? notifications.filter(\.isUnread) : notifications
    }

    private var signedInEmail: String {
        session.currentUser?.email ?? "—"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                Group {
                    if isLoading && notifications.isEmpty {
                        ProgressView()
                    } else if let errorMessage, notifications.isEmpty {
                        ContentUnavailableView(
                            L10n.Dashboard.notificationsLoadError,
                            systemImage: "exclamationmark.triangle",
                            description: Text(errorMessage)
                        )
                    } else if visibleNotifications.isEmpty {
                        emptyState
                    } else {
                        notificationList
                    }
                }
            }
            .navigationTitle(L10n.Dashboard.notifications)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.sageDark)
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            unreadOnly = false
                        } label: {
                            Label(L10n.Common.all, systemImage: unreadOnly ? "circle" : "checkmark.circle.fill")
                        }

                        Button {
                            unreadOnly = true
                        } label: {
                            Label(L10n.Dashboard.unreadOnly, systemImage: unreadOnly ? "checkmark.circle.fill" : "circle")
                        }

                        if unreadCount > 0 {
                            Divider()
                            Button {
                                Task { await markAllVisibleRead() }
                            } label: {
                                Label(L10n.Dashboard.markAllRead, systemImage: "envelope.open")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(AppTheme.sageDark)
                    }
                    .accessibilityLabel(L10n.Common.filter)
                }
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: unreadOnly ? "envelope.open" : "bell.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppTheme.sageDark.opacity(0.4))

            VStack(spacing: 6) {
                Text(unreadOnly ? L10n.Dashboard.noUnreadNotifications : L10n.Dashboard.noNotifications)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text(unreadOnly ? L10n.Dashboard.noUnreadNotificationsSub : L10n.Dashboard.noNotificationsSub)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Text(L10n.Dashboard.notificationsAccountHint(signedInEmail))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }

            #if DEBUG
            Text("API: \(APIConfig.baseURL.host ?? APIConfig.baseURL.absoluteString)")
                .font(AppFont.regular(10))
                .foregroundStyle(AppTheme.ink.opacity(0.35))
            #endif
        }
        .padding(.horizontal, 32)
    }

    private var notificationList: some View {
        List {
            if let errorMessage {
                Text(errorMessage)
                    .font(AppFont.regular(13))
                    .foregroundStyle(.red)
                    .listRowBackground(Color.clear)
            }

            ForEach(visibleNotifications) { notification in
                Button {
                    Task { await open(notification) }
                } label: {
                    notificationRow(notification)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await delete(notification) }
                    } label: {
                        Label(L10n.Common.delete, systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if notification.isUnread {
                        Button {
                            Task { await markRead(notification) }
                        } label: {
                            Label(L10n.Dashboard.markRead, systemImage: "envelope.open")
                        }
                        .tint(AppTheme.sageDark)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func notificationRow(_ notification: CustomerNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notification.displayIcon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(notification.tintColor)
                .frame(width: 42, height: 42)
                .background(notification.tintColor.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(notification.title)
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 4)

                    if !notification.relativeCreatedAt.isEmpty {
                        Text(notification.relativeCreatedAt)
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.4))
                    }
                }

                if !notification.displayMessage.isEmpty {
                    Text(notification.displayMessage)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(notification.groupLabel)
                    .font(AppFont.regular(10))
                    .foregroundStyle(notification.tintColor.opacity(0.9))
            }

            if notification.isUnread {
                Circle()
                    .fill(AppTheme.gold)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(14)
        .background(
            notification.isUnread ? AppTheme.lightSage.opacity(0.55) : AppTheme.surface,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[CustomerNotification]> = try await APIClient.shared.request("customer-notifications")
            notifications = envelope.data
            onUnreadCountChange?(unreadCount)

            #if DEBUG
            print("[Notifications] loaded \(envelope.data.count) for \(signedInEmail) via \(APIConfig.baseURL.absoluteString)")
            #endif
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage

            #if DEBUG
            print("[Notifications] load failed: \(error)")
            #endif
        }
    }

    private func open(_ notification: CustomerNotification) async {
        if notification.isUnread {
            await markRead(notification)
        }
    }

    private func markRead(_ notification: CustomerNotification) async {
        guard notification.isUnread else { return }

        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isUnread = false
            onUnreadCountChange?(unreadCount)
        }

        do {
            let envelope: Envelope<CustomerNotification> = try await APIClient.shared.request(
                "customer-notifications/\(notification.id)/mark-read",
                method: "PATCH"
            )
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index] = envelope.data
            }
            onUnreadCountChange?(unreadCount)
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
            await load()
        }
    }

    private func markAllVisibleRead() async {
        let targets = notifications.filter(\.isUnread)
        for notification in targets {
            await markRead(notification)
        }
    }

    private func delete(_ notification: CustomerNotification) async {
        notifications.removeAll { $0.id == notification.id }
        onUnreadCountChange?(unreadCount)

        do {
            try await APIClient.shared.requestNoContent("customer-notifications/\(notification.id)")
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
            await load()
        }
    }
}
