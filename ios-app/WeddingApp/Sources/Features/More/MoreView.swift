import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var events: [WeddingEvent] = []
    @State private var showLogoutConfirmation = false
    @State private var showComingSoon = false

    private var coupleName: String {
        let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if bride.isEmpty && groom.isEmpty {
            return session.currentUser?.name ?? "Wedding Couple"
        }
        return [bride, groom].filter { !$0.isEmpty }.joined(separator: " & ")
    }

    private var weddingDate: Date? {
        events.compactMap { $0.tglAcara.flatMap { DateFormatter.apiInput.date(from: $0) } }
            .sorted()
            .last
    }

    private var primaryLocation: String {
        events.compactMap(\.lokasiAcara).first { !$0.isEmpty } ?? L10n.More.locationNotSet
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        profileCard
                        sectionGroup(title: L10n.More.planningSection, items: planningItems)
                        sectionGroup(title: L10n.More.accountSection, items: accountItems)
                        shareCard
                        logoutButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
            .alert(L10n.More.logoutTitle, isPresented: $showLogoutConfirmation) {
                Button(L10n.Common.logout, role: .destructive) {
                    Task { await session.logout() }
                }
                Button(L10n.Common.cancel, role: .cancel) {}
            } message: {
                Text(L10n.More.logoutMessage)
            }
            .alert(L10n.Common.comingSoon, isPresented: $showComingSoon) {
                Button(L10n.Common.ok, role: .cancel) {}
            } message: {
                Text(L10n.Common.comingSoonMessage)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.More.title)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text(L10n.More.subtitle)
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 88, alignment: .top)
        .padding(.top, 8)
    }

    private var profileCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                UserAvatarCircle(url: session.currentUser?.avatarUrl, size: 66)

                VStack(alignment: .leading, spacing: 3) {
                    Text(coupleName)
                        .font(AppFont.medium(19))
                        .foregroundStyle(AppTheme.sageDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(weddingDate.map { DateFormatter.displayLocaleDate($0) } ?? L10n.More.dateNotSet)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))

                    Text(primaryLocation)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            NavigationLink {
                EditProfileView()
            } label: {
                HStack {
                    Label(L10n.More.editProfile, systemImage: "square.and.pencil")
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.sageDark)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.3))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    private func sectionGroup(title: String, items: [MoreItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    MoreRow(item: items[index], onComingSoon: { showComingSoon = true })
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 12, y: 6)
        }
    }

    private var planningItems: [MoreItem] {
        [
            MoreItem(icon: "calendar", title: L10n.More.weddingDetail, subtitle: L10n.More.weddingDetailSub, destination: .weddingDetail),
            MoreItem(icon: "person.2", title: L10n.More.couple, subtitle: L10n.More.coupleSub, destination: .couple),
            MoreItem(icon: "checklist", title: L10n.More.savedVendors, subtitle: L10n.More.savedVendorsSub, destination: .savedVendors),
            MoreItem(icon: "heart", title: L10n.More.inspiration, subtitle: L10n.More.inspirationSub, destination: .savedInspiration),
            MoreItem(icon: "folder", title: L10n.More.documents, subtitle: L10n.More.documentsSub, destination: .documents),
        ]
    }

    private var accountItems: [MoreItem] {
        [
            MoreItem(icon: "gearshape", title: L10n.More.settings, subtitle: L10n.More.settingsSub, destination: .settings),
            MoreItem(icon: "lock", title: L10n.More.privacy, subtitle: L10n.More.privacySub, destination: .privacySecurity),
            MoreItem(icon: "bell", title: L10n.More.reminders, subtitle: L10n.More.remindersSub, destination: .reminders),
            MoreItem(
                icon: "globe",
                title: L10n.More.language,
                subtitle: LanguageFeature.isSelectionEnabled ? LanguageStore.shared.selected.nativeSubtitle : "Indonesia",
                destination: LanguageFeature.isSelectionEnabled ? .language : nil
            ),
            MoreItem(icon: "questionmark.circle", title: L10n.More.help, subtitle: L10n.More.helpSub, destination: .help),
            MoreItem(icon: "info.circle", title: L10n.More.about, subtitle: L10n.More.aboutSub, destination: .about),
        ]
    }

    private var shareCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "envelope.open")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(AppTheme.sageDark)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.More.shareApp)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.sageDark)
                Text(L10n.More.shareAppSub)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .lineSpacing(1)
            }

            Spacer(minLength: 4)

            ShareLink(
                item: AboutContent.shareURL,
                subject: Text(L10n.More.shareApp),
                message: Text(L10n.More.shareMessage)
            ) {
                Label(L10n.Common.share, systemImage: "square.and.arrow.up")
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.white, in: Capsule())
                    .overlay { Capsule().stroke(AppTheme.sage.opacity(0.2), lineWidth: 1) }
            }
        }
        .padding(16)
        .background(AppTheme.lightSage.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
        }
    }

    private var logoutButton: some View {
        Button {
            showLogoutConfirmation = true
        } label: {
            Label(L10n.More.logoutTitle, systemImage: "rectangle.portrait.and.arrow.right")
                .font(AppFont.medium(15))
                .foregroundStyle(Color.red.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func load() async {
        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")
            info = try await infoEnvelope.data
            events = try await eventEnvelope.data
        } catch {
            // biarkan tampilan pakai data default kalau gagal
        }
    }
}

private struct MoreItem: Identifiable {
    enum Destination {
        case weddingDetail
        case couple
        case savedVendors
        case savedInspiration
        case documents
        case events
        case settings
        case privacySecurity
        case reminders
        case language
        case help
        case about
    }

    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let destination: Destination?
}

private struct MoreRow: View {
    let item: MoreItem
    let onComingSoon: () -> Void

    var body: some View {
        if let destination = item.destination {
            NavigationLink {
                switch destination {
                case .weddingDetail: WeddingDetailView()
                case .couple: CoupleView()
                case .savedVendors: SavedVendorsView()
                case .savedInspiration: InspirationView()
                case .documents: WeddingDocumentsView()
                case .events: EventListView()
                case .settings: SettingsView()
                case .privacySecurity: PrivacySecurityView()
                case .reminders: RemindersPreferencesView()
                case .language: LanguageSettingsView()
                case .help: HelpFAQView()
                case .about: AboutWeddingAppView()
                }
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            Button(action: onComingSoon) {
                rowContent
            }
            .buttonStyle(.plain)
        }
    }

    private var rowContent: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.sage.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(item.subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct UserAvatarCircle: View {
    let url: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = url, !urlString.isEmpty, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        fallbackAvatar
                    @unknown default:
                        fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay { Circle().stroke(AppTheme.gold.opacity(0.5), lineWidth: 1.5) }
    }

    private var fallbackAvatar: some View {
        Image("CouplePortrait")
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

