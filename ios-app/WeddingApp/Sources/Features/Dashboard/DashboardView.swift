import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: DashboardTab = .home

    var body: some View {
        NativeDashboardTabs(selectedTab: $selectedTab)
            .task {
                await PushNotificationManager.shared.promptForAuthorizationIfNeeded()
            }
    }
}

private struct NativeDashboardTabs: View {
    @Binding var selectedTab: DashboardTab

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

    private var displayQuotes: [WeddingQuote] {
        quotes.isEmpty ? WeddingQuote.fallback : quotes
    }

    private let quoteTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    private var weddingDate: Date? {
        events.compactMap { event in
            guard let tglAcara = event.tglAcara else { return nil }
            return DateFormatter.apiInput.date(from: tglAcara)
        }
        .sorted()
        .last
    }

    private var daysRemaining: Int? {
        guard let weddingDate else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: weddingDate)
        return max(Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0, 0)
    }

    private var coupleName: String {
        let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if bride.isEmpty && groom.isEmpty {
            return "Wedding Couple"
        }

        return [bride, groom].filter { !$0.isEmpty }.joined(separator: " & ")
    }

    private var primaryLocation: String {
        events.compactMap(\.lokasiAcara).first { !$0.isEmpty } ?? "Wedding venue"
    }

    private var preparationProgress: Double {
        checklistSummary?.progress ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        homeHeader
                        weddingSummaryCard
                        weddingProgressCard
                        quoteCard
                        nextUpSection
                        quickActionsCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
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
                NotificationsSheet()
            }
        }
    }

    private var homeHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Dashboard.welcome)
                    .fontWeight(.bold)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.78))

                HStack(spacing: 6) {
                    Text("Wedding")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.sageDark)
                    Text("App")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.gold)
                }
                .font(AppFont.regular(38))
                .lineLimit(1)
                .minimumScaleFactor(0.58)

                Text(L10n.Dashboard.planTogether)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            Button {
                showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(AppTheme.ink.opacity(0.78))
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.86), in: Circle())
                        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)

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
            .accessibilityLabel(L10n.Dashboard.notifications)
            .padding(.top, 2)
        }
        .frame(height: 128, alignment: .top)
        .padding(.top, 8)
    }

    private var weddingSummaryCard: some View {
        let cardHeight: CGFloat = 182

        return HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 9) {
                Text(coupleName)
                    .font(AppFont.medium(22))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                VStack(alignment: .leading, spacing: 7) {
                    Label(weddingDate.map { DateFormatter.weddingDateOnly.string(from: $0) } ?? L10n.More.dateNotSet, systemImage: "calendar")
                    Label(primaryLocation, systemImage: "mappin")
                }
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.ink.opacity(0.52))
                .lineLimit(1)
                .minimumScaleFactor(0.68)

                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20, weight: .regular))

                    VStack(alignment: .leading, spacing: -2) {
                        Text(daysRemaining.map(String.init) ?? "385")
                            .font(AppFont.medium(24))
                        Text(L10n.Dashboard.daysToGo)
                            .font(AppFont.medium(12))
                    }
                }
                .foregroundStyle(AppTheme.sageDark)
                .padding(.horizontal, 11)
                .padding(.vertical, 9)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.top, 4)
            }
            .padding(.leading, 20)
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity, alignment: .leading)

            CoupleAvatarImage(
                width: 168,
                height: cardHeight
            )
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 16, y: 8)
    }

    private var weddingProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.Dashboard.weddingProgress)
                    .font(AppFont.medium(18))
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                Button {
                    selectTab(.checklist)
                } label: {
                    Label(L10n.Common.seeAll, systemImage: "chevron.right")
                        .font(AppFont.regular(13))
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 22) {
                ProgressRing(progress: preparationProgress)
                    .frame(width: 100, height: 100)

                VStack(spacing: 12) {
                    ProgressStatRow(color: AppTheme.sageDark, title: L10n.Dashboard.completed, value: "\(checklistSummary?.completed ?? 0)")
                    Divider()
                    ProgressStatRow(color: AppTheme.gold, title: L10n.Dashboard.inProgress, value: "\(checklistSummary?.inProgress ?? 0)")
                    Divider()
                    ProgressStatRow(color: AppTheme.mist, title: L10n.Dashboard.toDo, value: "\(checklistSummary?.todo ?? 0)")
                }
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    private var quoteCard: some View {
        VStack(spacing: 8) {
            Text("\u{201C}")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .frame(height: 20)

            TabView(selection: $quoteIndex) {
                ForEach(displayQuotes) { item in
                    Text(item.quote)
                        .font(AppFont.regular(12))
                        .lineSpacing(1)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 6)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 62)

            HStack(spacing: 6) {
                ForEach(displayQuotes) { item in
                    Circle()
                        .fill(.white.opacity(item.id == quoteIndex ? 1 : 0.4))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(.horizontal, 52)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, minHeight: 128)
        .background {
            LinearGradient(colors: [AppTheme.sage, AppTheme.sageDark], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .overlay {
            HStack {
                Image(systemName: "laurel.leading")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(AppTheme.gold.opacity(0.72))

                Spacer()

                Image(systemName: "laurel.trailing")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(AppTheme.gold.opacity(0.72))
            }
            .padding(.horizontal, 14)
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: AppTheme.sageDark.opacity(0.14), radius: 16, y: 8)
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
            HStack {
                Text(L10n.Dashboard.nextUp)
                    .font(AppFont.semibold(18))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                Button {
                    selectTab(.checklist)
                } label: {
                    Label(L10n.Common.seeAll, systemImage: "chevron.right")
                        .font(AppFont.regular(13))
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.secondary)
                }
            }

            nextUpRow
        }
    }

    private var nextUpRow: some View {
        HStack(spacing: 10) {
            ForEach(nextUpItems.prefix(3)) { item in
                NextUpCard(item: item)
            }
        }
        .padding(.vertical, 2)
    }

    private var quickActionsCard: some View {
        HStack(spacing: 0) {
            QuickActionButton(title: L10n.Dashboard.tasks, iconName: "list.clipboard") { selectTab(.checklist) }
            QuickActionButton(title: L10n.Dashboard.vendors, iconName: "storefront") { showVendor = true }
            QuickActionButton(title: L10n.Dashboard.inspiration, iconName: "heart") { showInspiration = true }
            QuickActionButton(title: L10n.Tab.budget, iconName: "creditcard") { selectTab(.budget) }
            QuickActionButton(title: L10n.Dashboard.messages, iconName: "bubble.left") { showMessages = true }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 14, y: 7)
    }

    private var nextUpItems: [NextUpItem] {
        let mapped = events.prefix(3).enumerated().map { index, event in
            NextUpItem(
                id: event.id,
                title: event.jenisLabel ?? event.jenisAcara.capitalized,
                dateText: event.tglAcara.flatMap { DateFormatter.apiInput.date(from: $0) }.map { DateFormatter.nextUpDisplay.string(from: $0) } ?? "Set date",
                badgeText: event.tglAcara.flatMap(daysUntilText) ?? "Upcoming",
                iconName: ["person.2", "birthday.cake", "figure.dress.line.vertical.figure"][index % 3]
            )
        }

        if !mapped.isEmpty {
            return mapped
        }

        return [
            NextUpItem(id: -1, title: "Venue Meeting", dateText: "Sat, 14 Jun 2025", badgeText: "In 3 days", iconName: "person.2"),
            NextUpItem(id: -2, title: "Tasting Session", dateText: "Sun, 22 Jun 2025", badgeText: "In 11 days", iconName: "birthday.cake"),
            NextUpItem(id: -3, title: "Fitting Dress", dateText: "Fri, 27 Jun 2025", badgeText: "In 16 days", iconName: "figure.dress.line.vertical.figure"),
        ]
    }

    private func daysUntilText(from rawDate: String) -> String? {
        guard let date = DateFormatter.apiInput.date(from: rawDate) else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: date)
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0

        if days <= 0 {
            return "Today"
        }

        return "In \(days) days"
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let budgetEnvelope: Envelope<WeddingBudget> = APIClient.shared.request("wedding-budget")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")
            async let guestEnvelope: Envelope<[Guest]> = APIClient.shared.request("guests")
            async let summaryEnvelope: Envelope<ChecklistSummary> = APIClient.shared.request("customer-preparation-tasks/summary")

            info = try await infoEnvelope.data
            budget = try await budgetEnvelope.data
            events = try await eventEnvelope.data
            guests = try await guestEnvelope.data
            checklistSummary = try await summaryEnvelope.data
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let quoteEnvelope: Envelope<[WeddingQuote]> = try await APIClient.shared.request("wedding-quotes")
            quotes = quoteEnvelope.data
        } catch {
            quotes = []
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
                .stroke(AppTheme.mist, lineWidth: 13)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppTheme.sageDark, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text("\(Int(progress * 100))%")
                    .font(AppFont.medium(27))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Dashboard.completed)
                    .font(AppFont.regular(10))
                    .foregroundStyle(.secondary)
                    .opacity(showSubtitle ? 1 : 0)
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
                .frame(width: 12, height: 12)

            Text(title)
                .font(AppFont.regular(15))
                .foregroundStyle(AppTheme.ink)

            Spacer()

            Text(value)
                .font(AppFont.medium(15))
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.ink)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
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
        VStack(spacing: 8) {
            Image(systemName: item.iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 46, height: 46)
                .background(AppTheme.sage.opacity(0.10), in: Circle())

            VStack(spacing: 3) {
                Text(item.title)
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(item.dateText)
                    .font(AppFont.regular(11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Text(item.badgeText)
                .font(AppFont.medium(11))
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.sageDark)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 146)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 14, y: 7)
    }
}

private struct QuickActionButton: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: iconName)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 46, height: 46)
                    .background(AppTheme.sage.opacity(0.10), in: Circle())

                Text(title)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                VStack(spacing: 20) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.4))

                    VStack(spacing: 6) {
                        Text(L10n.Dashboard.noNotifications)
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundStyle(AppTheme.sageDark)

                        Text(L10n.Dashboard.noNotificationsSub)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.sageDark)
                }
            }
            .navigationTitle(L10n.Dashboard.notifications)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension DateFormatter {
    static let weddingDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    static let nextUpDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter
    }()
}
