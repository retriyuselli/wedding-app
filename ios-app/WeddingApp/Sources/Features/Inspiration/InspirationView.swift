import SwiftUI

struct InspirationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared

    @State private var items: [InspirationItem] = []
    @State private var searchText = ""
    @State private var filter = InspirationFilter()
    @State private var draftFilter = InspirationFilter()
    @State private var selectedCategory: InspirationCategory = .all
    @State private var showFilterSheet = false
    @State private var showSavedOnly = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPaywall = false
    @ObservedObject private var savedStore = SavedInspirationStore.shared
    @ObservedObject private var likedStore = LikedInspirationStore.shared

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

    private var filteredItems: [InspirationItem] {
        items
            .filter { item in
                let matchCategory: Bool
                if selectedCategory == .all {
                    matchCategory = filter.categories.isEmpty || filter.categories.contains(item.category)
                } else {
                    matchCategory = item.category == selectedCategory
                }

                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                let matchSearch = query.isEmpty
                    || item.title.localizedCaseInsensitiveContains(query)
                    || (item.description?.localizedCaseInsensitiveContains(query) ?? false)
                    || item.category.label.localizedCaseInsensitiveContains(query)

                let matchLikes = filter.minimumLikes == nil || item.likes >= (filter.minimumLikes ?? 0)
                let matchSaved = !filter.savedOnly || savedStore.contains(item.id)
                let matchSavedHeader = !showSavedOnly || savedStore.contains(item.id)

                return matchCategory && matchSearch && matchLikes && matchSaved && matchSavedHeader
            }
            .sorted { $0.likes > $1.likes }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    searchBar

                    categorySection

                    if filter.isActive {
                        activeFilterRow
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                    }

                    latestSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .premiumContentLock(isPremium: isPremium, showPaywall: $showPaywall)
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if isPremium && isLoading && items.isEmpty {
                ProgressView()
            }
        }
        .task {
            if isPremium {
                await load()
            } else {
                await loadPreview()
            }
        }
        .refreshable {
            if isPremium {
                await load()
            } else {
                await loadPreview()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onUnlocked: {
                Task { await load() }
            })
            .environmentObject(session)
        }
        .sheet(isPresented: $showFilterSheet) {
            InspirationFilterSheet(
                filter: $draftFilter,
                onApply: { applied in
                    filter = applied
                    showFilterSheet = false
                },
                onReset: {
                    draftFilter.reset()
                    filter.reset()
                    showFilterSheet = false
                }
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.iconOnChip)
                    .frame(width: 42, height: 42)
                    .background {
                        Circle()
                            .fill(AppTheme.iconChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle().stroke(AppTheme.iconChipStroke, lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(L10n.Inspiration.title)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Text(L10n.Inspiration.subtitle)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(AppTheme.gold)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSavedOnly.toggle()
                }
            } label: {
                Image(systemName: showSavedOnly ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(showSavedOnly ? AppTheme.labelOnLightSurface : AppTheme.iconOnChip)
                    .frame(width: 42, height: 42)
                    .background {
                        Circle()
                            .fill(showSavedOnly ? AppTheme.selectedChipFill : AppTheme.iconChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                showSavedOnly ? AppTheme.sage.opacity(0.35) : AppTheme.iconChipStroke,
                                lineWidth: 1
                            )
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.inkMuted(0.45))

                TextField(L10n.Inspiration.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.titleOnGlass)
                    .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.inkMuted(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .premiumGlassCard(cornerRadius: 16)

            Button {
                draftFilter = filter
                showFilterSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 13, weight: .semibold))
                    Text(L10n.Common.filter)
                        .font(AppFont.medium(13))
                }
                .foregroundStyle(filter.isActive ? AppTheme.labelOnLightSurface : AppTheme.inkMuted(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(filter.isActive ? AppTheme.selectedChipFill : AppTheme.chipIdleFill)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            filter.isActive ? AppTheme.sage.opacity(0.35) : AppTheme.iconChipStroke,
                            lineWidth: filter.isActive ? 1.5 : 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Categories

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Common.category)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Spacer()
                NavigationLink {
                    InspirationCategoriesView(items: items)
                } label: {
                    HStack(spacing: 3) {
                        Text(L10n.Common.seeAll)
                            .font(AppFont.regular(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.sageMuted(0.85))
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(InspirationCategory.allCases) { category in
                        categoryChip(category)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }

    private func categoryChip(_ category: InspirationCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: .semibold))
                Text(category.label)
                    .font(AppFont.medium(12))
                    .lineLimit(1)
                Text("\(count(for: category))")
                    .font(AppFont.medium(11))
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : AppTheme.labelOnLightSurface)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        (isSelected ? Color.white.opacity(0.22) : AppTheme.selectedChipFill.opacity(0.95)),
                        in: Capsule()
                    )
            }
            .foregroundStyle(isSelected ? .white : AppTheme.iconOnChip)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                if isSelected {
                    Capsule().fill(AppTheme.brandGradientEnd)
                } else {
                    Capsule()
                        .fill(AppTheme.chipIdleFill)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .overlay {
                Capsule()
                    .stroke(
                        isSelected ? Color.white.opacity(0.2) : AppTheme.iconChipStroke,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private func count(for category: InspirationCategory) -> Int {
        if category == .all {
            return items.count
        }
        return items.filter { $0.category == category }.count
    }

    // MARK: - Latest Grid

    private var latestSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(showSavedOnly ? L10n.Inspiration.saved : L10n.Inspiration.latest)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.titleOnGlass)

            if filteredItems.isEmpty {
                emptyStateCard
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            InspirationDetailView(item: item)
                        } label: {
                            InspirationGridCard(
                                item: item,
                                isSaved: savedStore.contains(item.id),
                                isLiked: likedStore.contains(item.id),
                                likes: likedStore.likesCount(for: item.id, fallback: item.likes)
                            ) {
                                savedStore.toggle(item.id)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var activeFilterLabels: [String] {
        var labels: [String] = []
        if !filter.categories.isEmpty {
            labels.append(filter.categories.map(\.label).sorted().joined(separator: ", "))
        }
        if let minimumLikes = filter.minimumLikes {
            labels.append(L10n.Inspiration.likesChip(minimumLikes))
        }
        if filter.savedOnly {
            labels.append(L10n.Inspiration.savedLabel)
        }
        return labels
    }

    private var activeFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(activeFilterLabels, id: \.self) { label in
                    Text(label)
                        .font(AppFont.medium(11))
                        .foregroundStyle(AppTheme.sageDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.lightSage, in: Capsule())
                }

                Button(L10n.Common.reset) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filter.reset()
                    }
                }
                .font(AppFont.medium(11))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.mist, in: Capsule())
            }
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(AppTheme.sage.opacity(0.65))

            Text(showSavedOnly ? L10n.Inspiration.emptySavedTitle : L10n.Inspiration.emptySearchTitle)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.sageDark)

            Text(showSavedOnly
                ? L10n.Inspiration.emptySavedSub
                : L10n.Inspiration.emptySearchSub)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .premiumGlassCard(cornerRadius: 22)
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[InspirationItem]> = try await APIClient.shared.request("inspirations")
            items = envelope.data
            savedStore.sync(with: envelope.data)
            likedStore.sync(with: envelope.data)
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func loadPreview() async {
        errorMessage = nil
        if let envelope: Envelope<[InspirationItem]> = try? await APIClient.shared.request("inspirations"),
           !envelope.data.isEmpty {
            items = envelope.data
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let json = """
        [
          {"id":-1,"title":"Dekorasi Garden Soft","description":"Nuansa hijau sage dengan bunga putih","category":"dekorasi","likes":128,"views":400,"image_url":null,"thumbnail_symbol":"leaf.fill","is_saved":false,"is_liked":false},
          {"id":-2,"title":"Gaun Modern Minimal","description":"Siluet clean untuk resepsi indoor","category":"gaun","likes":96,"views":310,"image_url":null,"thumbnail_symbol":"sparkles","is_saved":false,"is_liked":false},
          {"id":-3,"title":"Makeup Natural Glow","description":"Look soft untuk sesi akad","category":"makeup","likes":84,"views":250,"image_url":null,"thumbnail_symbol":"paintbrush.pointed.fill","is_saved":false,"is_liked":false},
          {"id":-4,"title":"Venue Outdoor Terrace","description":"Pemandangan terbuka saat golden hour","category":"venue","likes":112,"views":360,"image_url":null,"thumbnail_symbol":"building.2.fill","is_saved":false,"is_liked":false}
        ]
        """
        items = (try? decoder.decode([InspirationItem].self, from: Data(json.utf8))) ?? []
    }
}

// MARK: - Grid Card

private struct InspirationGridCard: View {
    let item: InspirationItem
    let isSaved: Bool
    let isLiked: Bool
    let likes: Int
    let onToggleSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                inspirationImage(
                    imageUrl: item.imageUrl,
                    symbol: item.thumbnailSymbol,
                    tint: item.thumbnailTint
                )
                .frame(height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSaved ? AppTheme.labelOnLightSurface : AppTheme.iconOnChip)
                        .frame(width: 28, height: 28)
                        .background {
                            Circle()
                                .fill(isSaved ? AppTheme.selectedChipFill : AppTheme.iconChipFill)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .overlay {
                            Circle().stroke(AppTheme.iconChipStroke, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .padding(8)

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
                    .padding(8)
                }
                .frame(height: 130)
            }

            Text(item.title)
                .font(AppFont.semibold(13))
                .foregroundStyle(AppTheme.titleOnGlass)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let description = item.description, !description.isEmpty {
                Text(description)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.5))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(isLiked ? AppTheme.peachDark : AppTheme.inkMuted(0.5))
                    Text(formattedCount(likes))
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                }

                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.sageMuted(0.85))
                    Text(formattedCount(item.views))
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                }
            }
        }
        .padding(10)
        .premiumGlassCard(cornerRadius: 18)
    }

    private func formattedCount(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", Double(value) / 1000)
        }
        return "\(value)"
    }
}

// MARK: - Filter Sheet

private struct InspirationFilterSheet: View {
    @Binding var filter: InspirationFilter
    let onApply: (InspirationFilter) -> Void
    let onReset: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        categorySection
                        likesSection
                        toggleSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Inspiration.filterTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button(action: onReset) {
                        Text(L10n.Common.reset)
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.ink.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.mist, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button { onApply(filter) } label: {
                        Text(L10n.Common.apply)
                            .font(AppFont.medium(15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(.ultraThinMaterial)
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var categorySection: some View {
        filterSection(L10n.Common.category) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                ForEach(InspirationCategory.filterableCases) { category in
                    let isSelected = filter.categories.contains(category)
                    Button {
                        if isSelected {
                            filter.categories.remove(category)
                        } else {
                            filter.categories.insert(category)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 12, weight: .medium))
                            Text(category.label)
                                .font(AppFont.medium(12))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(isSelected ? .white : AppTheme.sageDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? AppTheme.sageDark : AppTheme.lightSage, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var likesSection: some View {
        filterSection(L10n.Inspiration.likesSection) {
            HStack(spacing: 8) {
                ForEach(InspirationFilter.likesOptions, id: \.label) { option in
                    let isSelected = filter.minimumLikes == option.value
                    Button {
                        filter.minimumLikes = option.value
                    } label: {
                        Text(option.label)
                            .font(AppFont.medium(11))
                            .foregroundStyle(isSelected ? .white : AppTheme.ink.opacity(0.65))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? AppTheme.sageDark : AppTheme.mist, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var toggleSection: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Inspiration.filterSavedOnly)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(L10n.Inspiration.filterSavedOnlySub)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer()

            Toggle("", isOn: $filter.savedOnly)
                .labelsHidden()
                .tint(AppTheme.sageDark)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }

    private func filterSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.semibold(15))
                .foregroundStyle(AppTheme.sageDark)

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .premiumGlassCard(cornerRadius: 16)
        }
    }
}

// MARK: - Detail View

struct InspirationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var savedStore = SavedInspirationStore.shared
    @ObservedObject private var likedStore = LikedInspirationStore.shared

    let item: InspirationItem

    private var isSaved: Bool {
        savedStore.contains(item.id)
    }

    private var isLiked: Bool {
        likedStore.contains(item.id)
    }

    private var displayLikes: Int {
        likedStore.likesCount(for: item.id, fallback: item.likes)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage

                    VStack(alignment: .leading, spacing: 18) {
                        categoryTag

                        Text(item.title)
                            .font(AppFont.semibold(22))
                            .foregroundStyle(AppTheme.sageDark)
                            .fixedSize(horizontal: false, vertical: true)

                        statsRow

                        if let description = item.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.Common.description)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.ink)
                                Text(description)
                                    .font(AppFont.regular(13))
                                    .foregroundStyle(AppTheme.ink.opacity(0.6))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .premiumGlassCard(cornerRadius: 18)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                }
                .padding(.bottom, 90)
            }

            saveBar
        }
        .ignoresSafeArea(edges: .top)
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var heroImage: some View {
        ZStack(alignment: .topLeading) {
            inspirationImage(
                imageUrl: item.imageUrl,
                symbol: item.thumbnailSymbol,
                tint: item.thumbnailTint
            )
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .clipped()

            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.labelOnLightSurface)
                    .frame(width: 42, height: 42)
                    .background {
                        Circle()
                            .fill(AppTheme.selectedChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle().stroke(AppTheme.iconChipStroke, lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.12), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.leading, 20)
            .padding(.top, 60)
        }
    }

    private var categoryTag: some View {
        HStack(spacing: 6) {
            Image(systemName: item.category.iconName)
                .font(.system(size: 11, weight: .semibold))
            Text(item.category.label)
                .font(AppFont.medium(12))
        }
        .foregroundStyle(AppTheme.labelOnLightSurface)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(AppTheme.selectedChipFill, in: Capsule())
        .overlay {
            Capsule().stroke(AppTheme.iconChipStroke, lineWidth: 1)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 20) {
            Button {
                likedStore.toggle(item.id, currentLikes: displayLikes)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isLiked ? AppTheme.peachDark : AppTheme.inkMuted(0.5))
                    Text(L10n.Inspiration.likes(formattedCount(displayLikes)))
                        .font(AppFont.regular(13))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 6) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.sageMuted(0.85))
                Text(L10n.Inspiration.views(formattedCount(item.views)))
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.inkMuted(0.6))
            }
        }
    }

    private var saveBar: some View {
        Button {
            savedStore.toggle(item.id)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                Text(isSaved ? L10n.Inspiration.savedLabel : L10n.Inspiration.saveInspiration)
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSaved ? AppTheme.sage : AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    private func formattedCount(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", Double(value) / 1000)
        }
        return "\(value)"
    }
}

// MARK: - All Categories

struct InspirationCategoriesView: View {
    let items: [InspirationItem]

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Inspiration.allCategories,
                        subtitle: L10n.Inspiration.allCategoriesSub
                    )

                    VStack(spacing: 10) {
                        categoryRow(
                            category: .all,
                            count: items.count,
                            subtitle: L10n.Inspiration.seeAllSub
                        )

                        ForEach(InspirationCategory.filterableCases) { category in
                            let count = items.filter { $0.category == category }.count
                            if count > 0 {
                                categoryRow(
                                    category: category,
                                    count: count,
                                    subtitle: L10n.Inspiration.categoryCount(count)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func categoryRow(category: InspirationCategory, count: Int, subtitle: String) -> some View {
        NavigationLink {
            InspirationCategoryItemsView(category: category, items: items)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: category.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.label)
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.ink)
                    Text(subtitle)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer(minLength: 8)

                Text("\(count)")
                    .font(AppFont.semibold(13))
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.lightSage, in: Capsule())

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.28))
            }
            .padding(14)
            .premiumGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Items

struct InspirationCategoryItemsView: View {
    let category: InspirationCategory
    let items: [InspirationItem]

    @ObservedObject private var savedStore = SavedInspirationStore.shared
    @ObservedObject private var likedStore = LikedInspirationStore.shared

    private var filteredItems: [InspirationItem] {
        let categoryItems = category == .all
            ? items
            : items.filter { $0.category == category }

        return categoryItems.sorted { $0.likes > $1.likes }
    }

    private var pageTitle: String {
        category == .all ? L10n.Inspiration.allInspirations : category.label
    }

    private var pageSubtitle: String {
        L10n.Inspiration.categoryCount(filteredItems.count)
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: pageTitle,
                        subtitle: pageSubtitle
                    )

                    if filteredItems.isEmpty {
                        MoreEmptyState(
                            icon: "sparkles",
                            title: L10n.Inspiration.categoryEmptyTitle,
                            message: L10n.Inspiration.categoryEmptyMessage
                        )
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                            ],
                            spacing: 16
                        ) {
                            ForEach(filteredItems) { item in
                                NavigationLink {
                                    InspirationDetailView(item: item)
                                } label: {
                                    InspirationGridCard(
                                        item: item,
                                        isSaved: savedStore.contains(item.id),
                                        isLiked: likedStore.contains(item.id),
                                        likes: likedStore.likesCount(for: item.id, fallback: item.likes)
                                    ) {
                                        savedStore.toggle(item.id)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Shared Image

@ViewBuilder
private func inspirationImage(imageUrl: String?, symbol: String, tint: Color) -> some View {
    if let imageUrl, let url = URL(string: imageUrl) {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                inspirationPlaceholder(symbol: symbol, tint: tint)
            default:
                inspirationPlaceholder(symbol: symbol, tint: tint)
                    .overlay { ProgressView() }
            }
        }
    } else {
        inspirationPlaceholder(symbol: symbol, tint: tint)
    }
}

private func inspirationPlaceholder(symbol: String, tint: Color) -> some View {
    ZStack {
        LinearGradient(
            colors: [tint.opacity(0.35), tint.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        Image(systemName: symbol)
            .font(.system(size: 28, weight: .light))
            .foregroundStyle(tint.opacity(0.75))
    }
}
