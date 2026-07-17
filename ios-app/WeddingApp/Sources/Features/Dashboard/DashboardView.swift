import Combine
import SwiftUI
import UIKit

struct DashboardView: View {
    @State private var selectedTab: DashboardTab = .home

    var body: some View {
        NativeDashboardTabs(selectedTab: $selectedTab)
    }
}

private struct NativeDashboardTabs: View {
    @Binding var selectedTab: DashboardTab
    @ObservedObject private var appearance = AppearanceStore.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView { tab in
                selectedTab = tab
            }
            .tabItem { Label(L10n.Tab.home, systemImage: DashboardTab.home.iconName) }
            .tag(DashboardTab.home)

            ChecklistView()
                .tabItem { Label(L10n.Tab.checklist, systemImage: DashboardTab.checklist.iconName) }
                .tag(DashboardTab.checklist)

            GuestView()
                .tabItem { Label(L10n.Tab.guest, systemImage: DashboardTab.guests.iconName) }
                .tag(DashboardTab.guests)

            BudgetView()
                .tabItem { Label(L10n.Tab.budget, systemImage: DashboardTab.budget.iconName) }
                .tag(DashboardTab.budget)

            MoreView()
                .tabItem { Label(L10n.Tab.more, systemImage: DashboardTab.more.iconName) }
                .tag(DashboardTab.more)
        }
        .tint(AppTheme.sageDark)
        .onAppear { applyTabBarContrast() }
        .onChange(of: appearance.theme) { _, _ in applyTabBarContrast() }
        .onChange(of: appearance.colorPalette) { _, _ in applyTabBarContrast() }
    }

    private func applyTabBarContrast() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        let selected = UIColor { traits in
            let token = AppearanceStore.currentPalette.definition.sageDark
            let useDark: Bool = {
                switch AppearanceStore.currentTheme {
                case .light: return false
                case .dark: return true
                case .system: return traits.userInterfaceStyle == .dark
                }
            }()
            let rgb = useDark ? token.dark : token.light
            return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
        }

        let unselected = UIColor { traits in
            let useDark: Bool = {
                switch AppearanceStore.currentTheme {
                case .light: return false
                case .dark: return true
                case .system: return traits.userInterfaceStyle == .dark
                }
            }()
            return useDark
                ? UIColor(white: 0.72, alpha: 1)
                : UIColor(white: 0.42, alpha: 1)
        }

        let item = appearance.stackedLayoutAppearance
        item.normal.iconColor = unselected
        item.normal.titleTextAttributes = [.foregroundColor: unselected]
        item.selected.iconColor = selected
        item.selected.titleTextAttributes = [.foregroundColor: selected]

        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = unselected
        UITabBar.appearance().tintColor = selected
    }
}

private enum DashboardTab: String, CaseIterable {
    case home = "Home"
    case checklist = "Checklist"
    case guests = "Guests"
    case budget = "Budget"
    case more = "More"

    var iconName: String {
        switch self {
        case .home: return "house"
        case .checklist: return "checklist"
        case .guests: return "person.2"
        case .budget: return "creditcard"
        case .more: return "ellipsis"
        }
    }
}

private struct HomeDashboardView: View {
    let selectTab: (DashboardTab) -> Void

    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var categoriesStore = BudgetCategoriesStore.shared
    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var budget = WeddingBudget(id: nil, totalBudget: 0, currency: nil, notes: "")
    @State private var events: [WeddingEvent] = []
    @State private var guests: [Guest] = []
    @State private var quotes: [WeddingQuote] = []
    @State private var checklistSummary: ChecklistSummary?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var quoteIndex = 0
    @State private var showVendor = false
    @State private var showInspiration = false
    @State private var showMessages = false
    @State private var showNotifications = false
    @State private var unreadNotificationCount = 0

    private var displayQuotes: [WeddingQuote] {
        quotes.isEmpty ? WeddingQuote.fallback : quotes
    }

    private let quoteTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    private var weddingDate: Date? {
        countdownTarget.map { Calendar.current.startOfDay(for: $0) }
    }

    /// Target datetime for the home countdown (reception day + start time when available).
    private var countdownTarget: Date? {
        guard let (event, day) = countdownEventAndDay else { return nil }

        var parts = Calendar.current.dateComponents([.year, .month, .day], from: day)
        if let time = WeddingEventTime.date(from: event.waktuMulai) {
            let timeParts = Calendar.current.dateComponents([.hour, .minute], from: time)
            parts.hour = timeParts.hour
            parts.minute = timeParts.minute
            parts.second = 0
        } else {
            parts.hour = 0
            parts.minute = 0
            parts.second = 0
        }
        return Calendar.current.date(from: parts)
    }

    /// Progress bar still tracks reception; milestones mark other events on the same timeline.
    private var countdownWindowStart: Date? {
        guard let target = countdownTarget else { return nil }
        return Calendar.current.date(byAdding: .day, value: -365, to: target)
    }

    private var countdownEventAndDay: (WeddingEvent, Date)? {
        let datedEvents: [(WeddingEvent, Date)] = events.compactMap { event in
            guard let raw = event.tglAcara,
                  let date = DateFormatter.calendarDate(from: raw) else { return nil }
            return (event, date)
        }

        guard !datedEvents.isEmpty else { return nil }

        return datedEvents.first { $0.0.jenisAcara.lowercased() == "resepsi" }
            ?? datedEvents.first { $0.0.jenisAcara.lowercased() == "akad" }
            ?? datedEvents.sorted { $0.1 < $1.1 }.last
    }

    private var countdownMilestones: [CountdownMilestone] {
        guard let start = countdownWindowStart,
              let target = countdownTarget else { return [] }

        let total = target.timeIntervalSince(start)
        guard total > 0 else { return [] }

        let preferredOrder = ["lamaran", "pengajian", "akad", "resepsi"]

        return events.compactMap { event -> CountdownMilestone? in
            guard let raw = event.tglAcara,
                  let day = DateFormatter.calendarDate(from: raw) else { return nil }

            let jenis = event.jenisAcara.lowercased()
            let position = min(max(day.timeIntervalSince(start) / total, 0), 1)
            let isPrimary = jenis == "resepsi"
                || (jenis == "akad" && !events.contains { $0.jenisAcara.lowercased() == "resepsi" })

            return CountdownMilestone(
                id: event.id,
                title: event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara),
                position: position,
                isPrimary: isPrimary,
                sortKey: preferredOrder.firstIndex(of: jenis) ?? preferredOrder.count
            )
        }
        .sorted {
            if $0.position != $1.position { return $0.position < $1.position }
            return $0.sortKey < $1.sortKey
        }
    }

    private var coupleName: String {
        let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if bride.isEmpty && groom.isEmpty {
            return L10n.Dashboard.defaultCouple
        }

        return [bride, groom].filter { !$0.isEmpty }.joined(separator: " & ")
    }

    private var couplePhotoURL: URL? {
        guard let raw = info.couplePhotoUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }
        return URL(string: raw)
    }

    private var primaryLocation: String {
        events.compactMap(\.lokasiAcara).first { !$0.isEmpty } ?? L10n.Dashboard.defaultVenue
    }

    private var summaryEvents: [WeddingEvent] {
        let preferredOrder = ["lamaran", "pengajian", "akad", "resepsi"]

        let sorted = events.sorted { lhs, rhs in
            let li = lhs.sortOrder
                ?? (preferredOrder.firstIndex(of: lhs.jenisAcara.lowercased()).map { $0 + 1 })
                ?? 99
            let ri = rhs.sortOrder
                ?? (preferredOrder.firstIndex(of: rhs.jenisAcara.lowercased()).map { $0 + 1 })
                ?? 99
            if li != ri { return li < ri }

            let ld = lhs.tglAcara.flatMap { DateFormatter.calendarDate(from: $0) } ?? .distantFuture
            let rd = rhs.tglAcara.flatMap { DateFormatter.calendarDate(from: $0) } ?? .distantFuture
            return ld < rd
        }

        return Array(sorted.prefix(4))
    }

    private func summaryEventDateText(for event: WeddingEvent) -> String {
        guard let raw = event.tglAcara,
              let date = DateFormatter.calendarDate(from: raw) else {
            return L10n.More.dateNotSet
        }
        return DateFormatter.displayLocaleDate(date)
    }

    private var countdownProgress: Double {
        guard let target = countdownTarget,
              let start = countdownWindowStart else { return 0 }
        let total = target.timeIntervalSince(start)
        guard total > 0 else { return 1 }
        return min(max(Date().timeIntervalSince(start) / total, 0), 1)
    }

    private func eventIcon(for jenisAcara: String) -> String {
        switch jenisAcara.lowercased() {
        case "akad": return "calendar"
        case "resepsi": return "party.popper"
        case "pengajian": return "building.columns"
        case "lamaran": return "sparkles"
        default: return "heart"
        }
    }

    private var preparationProgress: Double {
        checklistSummary?.progress ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        homeHeader

                        VStack(alignment: .leading, spacing: 18) {
                            weddingSummaryCard
                            weddingProgressCard
                            quoteCard
                        }

                        nextUpSection
                            .padding(.top, 16)

                        quickActionsCard
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .overlay {
                if isLoading && events.isEmpty && guests.isEmpty {
                    ProgressView()
                }
            }
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .openMessages)) { _ in
                showMessages = true
            }
            .navigationDestination(isPresented: $showVendor) {
                VendorView()
            }
            .navigationDestination(isPresented: $showInspiration) {
                InspirationView()
            }
            .navigationDestination(isPresented: $showMessages) {
                MessagesView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsSheet { count in
                    unreadNotificationCount = count
                }
                .environmentObject(session)
            }
        }
    }

    private var homeHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Dashboard.welcome)
                    .fontWeight(.bold)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.78))

                HStack(spacing: 6) {
                    Text(L10n.Auth.brandWedding)
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.sageDark)
                    Text(L10n.Auth.brandApp)
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.gold)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.58)

                Text(L10n.Dashboard.planTogether)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
                    .lineSpacing(1)
            }

            Spacer(minLength: 8)

            Button {
                showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(AppTheme.iconOnChrome)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.chrome, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(AppTheme.hairline, lineWidth: 1)
                        }
                        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)

                    if unreadNotificationCount > 0 {
                        Circle()
                            .fill(AppTheme.gold)
                            .frame(width: 12, height: 12)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            }
                            .offset(x: 1, y: -1)
                    }
                }
            }
            .accessibilityLabel(L10n.Dashboard.notifications)
        }
        .padding(.top, 8)
    }

    private var weddingSummaryCard: some View {
        let photoWidth: CGFloat = 122
        let photoHeight: CGFloat = 162

        return VStack(alignment: .leading, spacing: 16) {
            CoupleAvatarImage(
                photoURL: couplePhotoURL,
                width: photoWidth,
                height: photoHeight,
                showsFloralBackdrop: false
            )
            .frame(width: photoWidth, height: photoHeight)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 12)

            Text(coupleName)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .center)

            if !summaryEvents.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12, alignment: .topLeading),
                        GridItem(.flexible(), spacing: 12, alignment: .topLeading),
                    ],
                    alignment: .leading,
                    spacing: 14
                ) {
                    ForEach(summaryEvents) { event in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: eventIcon(for: event.jenisAcara))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.gold)
                                .frame(width: 16, alignment: .center)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara))
                                    .font(AppFont.semibold(13))
                                    .foregroundStyle(AppTheme.sageDark)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)

                                Text(summaryEventDateText(for: event))
                                    .font(AppFont.regular(11))
                                    .foregroundStyle(AppTheme.ink.opacity(0.48))
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Label(weddingDate.map { DateFormatter.displayLocaleDate($0) } ?? L10n.More.dateNotSet, systemImage: "calendar")
                    Label(primaryLocation, systemImage: "mappin")
                }
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.52))
            }

            WeddingCountdownBadge(
                target: countdownTarget,
                progress: countdownProgress,
                milestones: countdownMilestones
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.surface.opacity(0.96),
                                AppTheme.cream.opacity(0.92),
                                AppTheme.lightSage.opacity(0.55),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.42)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppTheme.hairline,
                            AppTheme.sage.opacity(0.18),
                            AppTheme.gold.opacity(0.12),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 24, y: 12)
        .shadow(color: AppTheme.gold.opacity(0.06), radius: 8, y: 3)
    }

    private var weddingProgressCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.Dashboard.weddingProgress)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                Button {
                    selectTab(.checklist)
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.seeAll)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.55))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 20) {
                ProgressRing(progress: preparationProgress)
                    .frame(width: 108, height: 108)

                VStack(spacing: 0) {
                    ProgressStatRow(color: AppTheme.sageDark, title: L10n.Dashboard.completed, value: "\(checklistSummary?.completed ?? 0)")
                    Divider().overlay(AppTheme.sage.opacity(0.22))
                    ProgressStatRow(color: AppTheme.gold, title: L10n.Dashboard.inProgress, value: "\(checklistSummary?.inProgress ?? 0)")
                    Divider().overlay(AppTheme.sage.opacity(0.22))
                    ProgressStatRow(color: AppTheme.statusMuted, title: L10n.Dashboard.toDo, value: "\(checklistSummary?.todo ?? 0)")
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .premiumGlassCard(cornerRadius: 32)
    }

    private var quoteCard: some View {
        VStack(spacing: 18) {
            Text("\u{201C}")
                .font(.system(size: 44, weight: .light, design: .serif))
                .foregroundStyle(AppTheme.quoteAccent)
                .frame(height: 22)

            TabView(selection: $quoteIndex) {
                ForEach(displayQuotes) { item in
                    Text(item.quote)
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 72)

            HStack(spacing: 7) {
                ForEach(displayQuotes) { item in
                    Capsule()
                        .fill(.white.opacity(item.id == quoteIndex ? 1 : 0.45))
                        .frame(width: item.id == quoteIndex ? 16 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: quoteIndex)
                }
            }
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, minHeight: 148)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.quoteGradientLeading,
                            AppTheme.quoteGradientMid,
                            AppTheme.quoteGradientTrailing,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            HStack {
                Image(systemName: "laurel.leading")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(AppTheme.quoteAccent.opacity(0.55))

                Spacer()

                Image(systemName: "laurel.trailing")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(AppTheme.quoteAccent.opacity(0.55))
            }
            .padding(.horizontal, 16)
            .allowsHitTesting(false)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: AppTheme.quoteGradientMid.opacity(0.28), radius: 22, y: 10)
        .onReceive(quoteTimer) { _ in
            guard !displayQuotes.isEmpty else { return }

            withAnimation(.easeInOut(duration: 0.6)) {
                let currentIndex = displayQuotes.firstIndex(where: { $0.id == quoteIndex }) ?? 0
                let nextIndex = (currentIndex + 1) % displayQuotes.count
                quoteIndex = displayQuotes[nextIndex].id
            }
        }
    }

    private var nextUpSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.Dashboard.nextUp)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                Button {
                    selectTab(.checklist)
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.seeAll)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.55))
                }
                .buttonStyle(.plain)
            }

            nextUpRow
        }
    }

    private var nextUpRow: some View {
        HStack(spacing: 12) {
            ForEach(nextUpItems.prefix(3)) { item in
                NextUpCard(item: item)
            }
        }
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 0) {
                QuickActionButton(title: L10n.Dashboard.tasks, iconName: "list.clipboard") { selectTab(.checklist) }
                QuickActionButton(title: L10n.Dashboard.vendors, iconName: "storefront") { showVendor = true }
                QuickActionButton(title: L10n.Dashboard.inspiration, iconName: "heart") { showInspiration = true }
                QuickActionButton(title: L10n.Tab.budget, iconName: "creditcard") { selectTab(.budget) }
                QuickActionButton(title: L10n.Dashboard.messages, iconName: "bubble.left") { showMessages = true }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .premiumGlassCard(cornerRadius: 28)
    }

    private var nextUpItems: [NextUpItem] {
        let mapped = events.prefix(3).enumerated().map { index, event in
            NextUpItem(
                id: event.id,
                title: event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara),
                dateText: event.tglAcara.flatMap { DateFormatter.calendarDate(from: $0) }.map { DateFormatter.nextUpDisplay.string(from: $0) } ?? L10n.Dashboard.setDate,
                badgeText: event.tglAcara.flatMap(daysUntilText) ?? L10n.Dashboard.upcoming,
                iconName: ["person.2", "birthday.cake", "figure.dress.line.vertical.figure"][index % 3]
            )
        }

        if !mapped.isEmpty {
            return mapped
        }

        return [
            NextUpItem(id: -1, title: L10n.Dashboard.sampleVenueMeeting, dateText: "Sat, 14 Jun 2025", badgeText: L10n.Dashboard.inDays(3), iconName: "person.2"),
            NextUpItem(id: -2, title: L10n.Dashboard.sampleTasting, dateText: "Sun, 22 Jun 2025", badgeText: L10n.Dashboard.inDays(11), iconName: "birthday.cake"),
            NextUpItem(id: -3, title: L10n.Dashboard.sampleFitting, dateText: "Fri, 27 Jun 2025", badgeText: L10n.Dashboard.inDays(16), iconName: "figure.dress.line.vertical.figure"),
        ]
    }

    private func daysUntilText(from rawDate: String) -> String? {
        guard let date = DateFormatter.calendarDate(from: rawDate) else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: date)
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0

        if days <= 0 {
            return L10n.Dashboard.today
        }

        return L10n.Dashboard.inDays(days)
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")

            info = try await infoEnvelope.data
            events = try await eventEnvelope.data
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let budgetEnvelope: NullableEnvelope<WeddingBudget> = try await APIClient.shared.request("wedding-budget")
            budget = budgetEnvelope.data ?? WeddingBudget(id: nil, totalBudget: 0, currency: nil, notes: "")
        } catch {
            budget = WeddingBudget(id: nil, totalBudget: 0, currency: nil, notes: "")
        }

        do {
            let guestEnvelope: Envelope<[Guest]> = try await APIClient.shared.request("guests")
            guests = guestEnvelope.data
        } catch {
            guests = []
        }

        do {
            let summaryEnvelope: Envelope<ChecklistSummary> = try await APIClient.shared.request("customer-preparation-tasks/summary")
            checklistSummary = summaryEnvelope.data
        } catch {
            checklistSummary = nil
        }

        do {
            let quoteEnvelope: Envelope<[WeddingQuote]> = try await APIClient.shared.request("wedding-quotes")
            quotes = quoteEnvelope.data
        } catch {
            quotes = []
        }

        do {
            let notificationEnvelope: Envelope<[CustomerNotification]> = try await APIClient.shared.request(
                "customer-notifications",
                queryItems: [URLQueryItem(name: "unread_only", value: "1")]
            )
            unreadNotificationCount = notificationEnvelope.data.count
        } catch {
            // Keep the last known badge count if the inbox request fails.
        }

        if let firstQuote = displayQuotes.first {
            quoteIndex = firstQuote.id
        }
    }
}

private struct ProgressRing: View {
    let progress: Double
    var showSubtitle = true

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.sage.opacity(0.14), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [AppTheme.sage, AppTheme.gold, AppTheme.sageDark],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AppTheme.sage.opacity(0.25), radius: 6, y: 2)

            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(AppFont.semibold(26))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.sageDark)

                if showSubtitle {
                    Text(L10n.Dashboard.completed)
                        .font(AppFont.medium(10))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }
            }
        }
    }
}

private struct ProgressStatRow: View {
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .shadow(color: color.opacity(0.35), radius: 3, y: 1)

            Text(title)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.ink.opacity(0.88))

            Spacer()

            Text(value)
                .font(AppFont.semibold(15))
                .monospacedDigit()
                .foregroundStyle(AppTheme.sageDark)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
        }
        .padding(.vertical, 10)
    }
}

private struct NextUpItem: Identifiable {
    let id: Int
    let title: String
    let dateText: String
    let badgeText: String
    let iconName: String
}

private struct NextUpCard: View {
    let item: NextUpItem

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: item.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppTheme.iconOnChrome)
                .frame(width: 48, height: 48)
                .background {
                    Circle()
                        .fill(AppTheme.chrome)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(AppTheme.hairline, lineWidth: 1)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 3)

            VStack(spacing: 4) {
                Text(item.title)
                    .font(AppFont.semibold(13))
                    .foregroundStyle(AppTheme.sageDark)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(item.dateText)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Text(item.badgeText)
                .font(AppFont.semibold(11))
                .foregroundStyle(AppTheme.sageDark)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.lightSage.opacity(0.85), in: Capsule())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 158)
        .premiumGlassCard(cornerRadius: 22)
    }
}

private struct QuickActionButton: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.iconOnChrome)
                    .frame(width: 48, height: 48)
                    .background {
                        Circle()
                            .fill(AppTheme.chrome)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle()
                            .stroke(AppTheme.hairline, lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 3)

                Text(title)
                    .font(AppFont.medium(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct CountdownMilestone: Identifiable {
    let id: Int
    let title: String
    let position: Double
    let isPrimary: Bool
    let sortKey: Int
}

private struct WeddingCountdownBadge: View {
    let target: Date?
    var progress: Double = 0
    var milestones: [CountdownMilestone] = []

    @ObservedObject private var appearance = AppearanceStore.shared

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let parts = Self.parts(until: target, from: context.date)
            let percent = Int((progress * 100).rounded())

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.gold)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.Dashboard.countdownLabel)
                            .font(AppFont.semibold(11))
                            .foregroundStyle(AppTheme.sageDark.opacity(0.72))
                            .tracking(0.6)

                        Text(L10n.Dashboard.countdownBigDay)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(AppTheme.sageDark)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppTheme.gold.opacity(0.75))
                }

                HStack(spacing: 8) {
                    countdownTile(value: parts.days, label: L10n.Dashboard.countdownDays, padded: false)
                    countdownTile(value: parts.hours, label: L10n.Dashboard.countdownHours)
                    countdownTile(value: parts.minutes, label: L10n.Dashboard.countdownMinutes)
                    countdownTile(value: parts.seconds, label: L10n.Dashboard.countdownSeconds)
                }
                .id(appearance.countdownFont.id)

                VStack(alignment: .leading, spacing: 8) {
                    GeometryReader { proxy in
                        let width = proxy.size.width

                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.sage.opacity(0.14))

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.sage, AppTheme.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(width * progress, 8))

                            ForEach(milestones) { milestone in
                                let size: CGFloat = milestone.isPrimary ? 10 : 8
                                Circle()
                                    .fill(milestone.isPrimary ? AppTheme.gold : AppTheme.chrome)
                                    .frame(width: size, height: size)
                                    .overlay {
                                        Circle()
                                            .stroke(
                                                milestone.isPrimary ? AppTheme.chrome : AppTheme.sageDark.opacity(0.55),
                                                lineWidth: 1.5
                                            )
                                    }
                                    .shadow(color: AppTheme.sageDark.opacity(0.12), radius: 2, y: 1)
                                    .offset(x: max(0, min(width - size, width * milestone.position - size / 2)))
                                    .accessibilityLabel(milestone.title)
                            }
                        }
                    }
                    .frame(height: 10)

                    if milestones.count > 1 {
                        HStack(spacing: 0) {
                            ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                                Text(shortMilestoneTitle(milestone.title))
                                    .font(AppFont.medium(9))
                                    .foregroundStyle(
                                        milestone.isPrimary
                                            ? AppTheme.sageDark
                                            : AppTheme.ink.opacity(0.72)
                                    )
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: milestoneLabelAlignment(index: index, total: milestones.count)
                                    )
                            }
                        }
                    }

                    Text(L10n.Dashboard.countdownProgress(percent))
                        .font(AppFont.medium(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.48))
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.gold)
                        .padding(.top, 2)

                    Text(L10n.Dashboard.countdownEncourage)
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.lightSage.opacity(0.78),
                                    AppTheme.surface.opacity(0.85),
                                    AppTheme.cream.opacity(0.55),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.55)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
        }
    }

    private func shortMilestoneTitle(_ title: String) -> String {
        let lowered = title.lowercased()
        if lowered.contains("resepsi") { return L10n.Events.resepsi }
        if lowered.contains("akad") { return L10n.Events.akad }
        if lowered.contains("pengajian") { return L10n.Events.pengajian }
        if lowered.contains("lamaran") { return L10n.Events.lamaran }
        return title
    }

    private func milestoneLabelAlignment(index: Int, total: Int) -> Alignment {
        if total <= 1 { return .center }
        if index == 0 { return .leading }
        if index == total - 1 { return .trailing }
        return .center
    }

    private func countdownTile(value: Int, label: String, padded: Bool = true) -> some View {
        VStack(spacing: 0) {
            Text(padded ? String(format: "%02d", value) : "\(value)")
                .font(AppFont.countdown(28))
                .foregroundStyle(AppTheme.sageDark)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.bottom, -2)

            Text(label)
                .font(AppFont.medium(10))
                .foregroundStyle(AppTheme.ink.opacity(0.65))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.chrome.opacity(0.92))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 10, y: 4)
    }

    private static func parts(until target: Date?, from now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        guard let target else {
            return (0, 0, 0, 0)
        }

        let remaining = max(Int(target.timeIntervalSince(now)), 0)
        let days = remaining / 86_400
        let hours = (remaining % 86_400) / 3_600
        let minutes = (remaining % 3_600) / 60
        let seconds = remaining % 60
        return (days, hours, minutes, seconds)
    }
}

private extension DateFormatter {
    static let nextUpDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter
    }()
}
