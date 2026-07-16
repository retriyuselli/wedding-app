import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var showLogoutConfirmation = false
    @State private var showComingSoon = false
    @State private var showPaywall = false

    private var coupleName: String {
        let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if bride.isEmpty && groom.isEmpty {
            return session.currentUser?.name ?? "Wedding Couple"
        }
        return [bride, groom].filter { !$0.isEmpty }.joined(separator: " & ")
    }

    private var joinedDateText: String {
        guard let date = session.currentUser?.joinedAtDate else {
            return L10n.More.dateNotSet
        }
        let dateText = DateFormatter.displayLocaleDate(date)
        return "\(dateText) · \(membershipDurationText(from: date))"
    }

    private var accountEmail: String {
        let email = session.currentUser?.email.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return email.isEmpty ? L10n.More.emailNotSet : email
    }

    private func membershipDurationText(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date, to: Date())
        let years = max(components.year ?? 0, 0)
        let months = max(components.month ?? 0, 0)
        let days = max(components.day ?? 0, 0)

        if years > 0 {
            return months > 0
                ? L10n.More.joinedYearsMonths(years, months)
                : L10n.More.joinedYears(years)
        }
        if months > 0 {
            return L10n.More.joinedMonths(months)
        }
        if days > 0 {
            return L10n.More.joinedDays(days)
        }
        return L10n.More.joinedToday
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        profileCard
                        weddingProCard
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(session)
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
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(joinedDateText)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))

                    Text(accountEmail)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
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
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.lightSage.opacity(0.72))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 28)
    }

    private var weddingProCard: some View {
        Button {
            if session.isPremium {
                return
            }
            showPaywall = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: session.isPremium ? "checkmark.seal.fill" : "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.iconChipFill, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.More.weddingPro)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(session.isPremium ? L10n.Premium.menuActiveSub : L10n.More.weddingProSub)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Text(session.isPremium ? L10n.Premium.statusActive : L10n.Premium.unlockCta)
                    .font(AppFont.medium(11))
                    .foregroundStyle(session.isPremium ? AppTheme.sageDark : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        if session.isPremium {
                            Capsule().fill(AppTheme.lightSage.opacity(0.8))
                        } else {
                            Capsule().fill(
                                LinearGradient(
                                    colors: [AppTheme.sage, AppTheme.sageDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        }
                    }
            }
            .padding(16)
            .premiumGlassCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
        .disabled(session.isPremium)
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
            .premiumGlassCard(cornerRadius: 22)
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
                subtitle: LanguageFeature.isSelectionEnabled
                    ? LanguageStore.shared.selected.nativeSubtitle
                    : L10n.Language.indonesian,
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
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 44, height: 44)
                .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.More.shareApp)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Text(L10n.More.shareAppSub)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.7))
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
                    .foregroundStyle(AppTheme.labelOnLightSurface)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(AppTheme.selectedChipFill, in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                    }
            }
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 22)
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
                .premiumGlassCard(cornerRadius: 16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.22), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func load() async {
        do {
            let infoEnvelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
            info = infoEnvelope.data
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
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppTheme.sage.opacity(0.12))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                }

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

