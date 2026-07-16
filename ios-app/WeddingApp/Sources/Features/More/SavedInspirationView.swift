import SwiftUI

struct SavedInspirationView: View {
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared
    @ObservedObject private var savedStore = SavedInspirationStore.shared
    @State private var items: [InspirationItem] = []
    @State private var isLoading = false
    @State private var showPaywall = false

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

    private var savedItems: [InspirationItem] {
        items
            .filter { savedStore.contains($0.id) }
            .sorted { $0.likes > $1.likes }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.More.inspiration,
                        subtitle: L10n.More.inspirationSub
                    )

                    if savedItems.isEmpty {
                        MoreEmptyState(
                            icon: "heart",
                            title: L10n.Inspiration.savedEmptyTitle,
                            message: L10n.Inspiration.savedEmptyMessage
                        )
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                            ],
                            spacing: 16
                        ) {
                            ForEach(savedItems) { item in
                                SavedInspirationCard(
                                    item: item,
                                    onToggleSave: { savedStore.toggle(item.id) }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .premiumContentLock(isPremium: isPremium, showPaywall: $showPaywall)
            .overlay {
                if isPremium && isLoading && items.isEmpty {
                    ProgressView()
                }
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task {
            guard isPremium else { return }
            await load()
        }
        .refreshable {
            guard isPremium else { return }
            await load()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onUnlocked: {
                Task { await load() }
            })
            .environmentObject(session)
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let envelope: Envelope<[InspirationItem]> = try await APIClient.shared.request(
                "inspirations",
                queryItems: [URLQueryItem(name: "saved_only", value: "1")]
            )
            items = envelope.data
            savedStore.sync(with: envelope.data)
        } catch {
            items = []
        }
    }
}

private struct SavedInspirationCard: View {
    let item: InspirationItem
    let onToggleSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                inspirationThumbnail
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button(action: onToggleSave) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(width: 28, height: 28)
                        .background {
                            Circle()
                                .fill(Color.white.opacity(0.78))
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.65), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .padding(10)

                VStack {
                    Spacer()
                    HStack {
                        Text(item.category.label)
                            .font(AppFont.medium(10))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.28), in: Capsule())
                        Spacer()
                    }
                    .padding(10)
                }
            }

            Text(item.title)
                .font(AppFont.semibold(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.peachDark)
                Text(formattedLikes(item.likes))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }
        }
        .padding(12)
        .premiumGlassCard(cornerRadius: 20)
    }

    @ViewBuilder
    private var inspirationThumbnail: some View {
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    thumbnailPlaceholder
                }
            }
        } else {
            thumbnailPlaceholder
        }
    }

    private var thumbnailPlaceholder: some View {
        LinearGradient(
            colors: [item.thumbnailTint.opacity(0.35), item.thumbnailTint.opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: item.thumbnailSymbol)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(item.thumbnailTint.opacity(0.8))
        }
    }

    private func formattedLikes(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1f rb", Double(value) / 1000)
        }
        return "\(value)"
    }
}
