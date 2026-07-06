import SwiftUI

struct InspirationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var items: [InspirationItem] = InspirationItem.popularSamples
    @State private var searchText = ""
    @State private var filter = InspirationFilter()
    @State private var draftFilter = InspirationFilter()
    @State private var showFilterSheet = false
    @State private var showSavedOnly = false
    @State private var featuredIndex = 0
    @State private var savedItemIDs: Set<Int> = Set(InspirationItem.popularSamples.filter(\.isSaved).map(\.id))
    @FocusState private var isSearchFocused: Bool

    private let featuredTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    private let searchBarID = "inspiration-search-bar"

    private var filteredPopularItems: [InspirationItem] {
        items
            .filter { item in
                let matchCategory = filter.categories.isEmpty || filter.categories.contains(item.category)
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                let matchSearch = query.isEmpty
                    || item.title.localizedCaseInsensitiveContains(query)
                    || item.category.label.localizedCaseInsensitiveContains(query)
                let matchLikes = filter.minimumLikes == nil || item.likes >= (filter.minimumLikes ?? 0)
                let matchSaved = !filter.savedOnly || savedItemIDs.contains(item.id)
                let matchSavedHeader = !showSavedOnly || savedItemIDs.contains(item.id)
                return matchCategory && matchSearch && matchLikes && matchSaved && matchSavedHeader
            }
            .sorted { $0.likes > $1.likes }
    }

    private var filteredCategoryGroups: [InspirationCategoryGroup] {
        InspirationCategoryGroup.samples.filter { group in
            let matchCategory = filter.categories.isEmpty || filter.categories.contains(group.id)
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchSearch = query.isEmpty
                || group.id.label.localizedCaseInsensitiveContains(query)
            return matchCategory && matchSearch
        }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        searchRow
                            .id(searchBarID)
                        categoryRow
                        if filter.isActive {
                            activeFilterRow
                        }
                        if isSearching || filter.isActive || showSavedOnly {
                            searchResultsHeader
                        }
                        if !isSearching && !filter.isActive && !showSavedOnly {
                            featuredCarousel
                        }
                        popularSection
                        categoryGridSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .refreshable {}
                .onChange(of: isSearchFocused) { _, focused in
                    guard focused else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(searchBarID, anchor: .top)
                    }
                }
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
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

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func activateSearch() {
        isSearchFocused = true
    }

    private func openFilterSheet() {
        draftFilter = filter
        isSearchFocused = false
        showFilterSheet = true
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.8))
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 10) {
                    Button(action: activateSearch) {
                        circleButton("magnifyingglass", isActive: isSearchFocused || isSearching)
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSavedOnly.toggle()
                        }
                    } label: {
                        circleButton("bookmark", isActive: showSavedOnly)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Inspiration")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text("Temukan ide dan inspirasi untuk hari\nspesialmu.")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    private func circleButton(_ icon: String, isActive: Bool = false) -> some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(isActive ? AppTheme.sageDark : AppTheme.ink.opacity(0.72))
            .frame(width: 42, height: 42)
            .background((isActive ? AppTheme.lightSage : .white).opacity(0.86), in: Circle())
            .overlay {
                Circle()
                    .stroke(AppTheme.sage.opacity(isActive ? 0.35 : 0), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
    }

    private var searchResultsHeader: some View {
        HStack {
            Text("\(filteredPopularItems.count) inspirasi ditemukan")
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            Spacer()

            if isSearching {
                Button("Hapus") {
                    searchText = ""
                    isSearchFocused = false
                }
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
            }
        }
    }

    private var activeFilterLabels: [String] {
        var labels: [String] = []
        if !filter.categories.isEmpty {
            labels.append(filter.categories.map(\.label).sorted().joined(separator: ", "))
        }
        if let minimumLikes = filter.minimumLikes {
            labels.append("Suka \(minimumLikes)+")
        }
        if filter.savedOnly {
            labels.append("Tersimpan")
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

                Button("Reset Filter") {
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

    // MARK: - Search

    private var searchRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Button(action: activateSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isSearchFocused ? AppTheme.sageDark : AppTheme.ink.opacity(0.35))
                }
                .buttonStyle(.plain)

                TextField("Cari inspirasi (dekorasi, tema, warna, dll)", text: $searchText)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit { isSearchFocused = false }

                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.ink.opacity(0.28))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppTheme.surface, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        isSearchFocused ? AppTheme.sageDark.opacity(0.35) : AppTheme.sage.opacity(0.10),
                        lineWidth: isSearchFocused ? 1.5 : 1
                    )
            }

            Button(action: openFilterSheet) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .medium))
                    Text("Filter")
                        .font(AppFont.medium(12))
                }
                .foregroundStyle(filter.isActive ? AppTheme.sageDark : AppTheme.ink.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background((filter.isActive ? AppTheme.lightSage : AppTheme.surface).opacity(0.95), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            filter.isActive ? AppTheme.sageDark.opacity(0.35) : AppTheme.sage.opacity(0.10),
                            lineWidth: filter.isActive ? 1.5 : 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Categories

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(InspirationCategory.allCases) { category in
                    InspirationCategoryChip(
                        category: category,
                        isSelected: category == .all
                            ? filter.categories.isEmpty
                            : filter.categories == [category]
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if category == .all {
                                filter.categories = []
                            } else {
                                filter.categories = [category]
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Featured

    private var featuredCarousel: some View {
        VStack(spacing: 10) {
            TabView(selection: $featuredIndex) {
                ForEach(InspirationFeatured.samples.indices, id: \.self) { index in
                    InspirationFeaturedCard(featured: InspirationFeatured.samples[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 168)

            HStack(spacing: 6) {
                ForEach(InspirationFeatured.samples.indices, id: \.self) { index in
                    Circle()
                        .fill(AppTheme.sageDark.opacity(index == featuredIndex ? 1 : 0.25))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onReceive(featuredTimer) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                featuredIndex = (featuredIndex + 1) % InspirationFeatured.samples.count
            }
        }
    }

    // MARK: - Popular

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Inspirasi Populer")

            if filteredPopularItems.isEmpty {
                emptyStateCard
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filteredPopularItems) { item in
                            InspirationPopularCard(
                                item: item,
                                isSaved: savedItemIDs.contains(item.id)
                            ) {
                                toggleSaved(item.id)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Category Grid

    private var categoryGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Berdasarkan Kategori")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(filteredCategoryGroups) { group in
                    InspirationCategoryCard(group: group)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.semibold(18))
                .foregroundStyle(AppTheme.sageDark)

            Spacer()

            Button {} label: {
                Label("Lihat Semua", systemImage: "chevron.right")
                    .font(AppFont.regular(12))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(AppTheme.ink.opacity(0.25))
            Text("Inspirasi tidak ditemukan")
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
            Text("Coba kata kunci lain atau ubah filter.")
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func toggleSaved(_ id: Int) {
        if savedItemIDs.contains(id) {
            savedItemIDs.remove(id)
        } else {
            savedItemIDs.insert(id)
        }
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
            .navigationTitle("Filter Inspirasi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button(action: onReset) {
                        Text("Reset")
                            .font(AppFont.medium(15))
                            .foregroundStyle(AppTheme.ink.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.mist, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button { onApply(filter) } label: {
                        Text("Terapkan")
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
        filterSection("Kategori") {
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
        filterSection("Jumlah Suka") {
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
                Text("Hanya Inspirasi Tersimpan")
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text("Tampilkan ide yang sudah Anda simpan")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer()

            Toggle("", isOn: $filter.savedOnly)
                .labelsHidden()
                .tint(AppTheme.sageDark)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func filterSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.semibold(15))
                .foregroundStyle(AppTheme.sageDark)

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                }
        }
    }
}

// MARK: - Category Chip

private struct InspirationCategoryChip: View {
    let category: InspirationCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.55))
                    .frame(width: 54, height: 54)
                    .background(isSelected ? AppTheme.mist : AppTheme.surface, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(AppTheme.sage.opacity(isSelected ? 0 : 0.10), lineWidth: 1)
                    }

                Text(category.label)
                    .font(AppFont.regular(11))
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.55))
            }
            .frame(width: 64)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Featured Card

private struct InspirationFeaturedCard: View {
    let featured: InspirationFeatured

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(featured.eyebrow)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(AppTheme.gold)

                HStack(spacing: 6) {
                    Text(featured.title)
                        .font(AppFont.semibold(20))
                        .foregroundStyle(AppTheme.sageDark)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.sage)
                }

                Text(featured.subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Button {} label: {
                    HStack(spacing: 4) {
                        Text(featured.buttonTitle)
                            .font(AppFont.medium(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.sageDark, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: featured.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            ZStack {
                if let imageName = featured.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    LinearGradient(
                        colors: [AppTheme.sage.opacity(0.35), AppTheme.lightSage],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(AppTheme.sageDark.opacity(0.35))
                }
            }
            .frame(width: 148)
            .clipped()
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.10), radius: 16, y: 8)
    }
}

// MARK: - Popular Card

private struct InspirationPopularCard: View {
    let item: InspirationItem
    let isSaved: Bool
    let onToggleSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                inspirationImage(
                    imageName: item.imageName,
                    symbol: item.thumbnailSymbol,
                    tint: item.thumbnailTint
                )
                .frame(width: 156, height: 196)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isSaved ? AppTheme.sageDark : AppTheme.ink.opacity(0.55))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.92), in: Circle())
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
                .frame(width: 156, height: 196)
            }

            Text(item.title)
                .font(AppFont.semibold(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.peachDark)
                Text(formattedLikes(item.likes))
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }
        }
        .frame(width: 156)
    }

    private func formattedLikes(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Category Card

private struct InspirationCategoryCard: View {
    let group: InspirationCategoryGroup

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: group.id.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 42, height: 42)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(group.id.label)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.ink)
                HStack(spacing: 4) {
                    Text("\(group.count) Ide")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.35))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 12, y: 6)
    }
}

// MARK: - Shared Image

private func inspirationImage(imageName: String?, symbol: String, tint: Color) -> some View {
    Group {
        if let imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            ZStack {
                LinearGradient(
                    colors: [tint.opacity(0.35), tint.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: symbol)
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(tint.opacity(0.75))
            }
        }
    }
}
