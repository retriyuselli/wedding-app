import SwiftUI

struct VendorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoriesStore = VendorCategoriesStore.shared

    @State private var vendors: [VendorItem] = []
    @State private var catalogVendors: [VendorItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var filter = VendorFilter()
    @State private var draftFilter = VendorFilter()
    @State private var showFilterSheet = false
    @State private var sortOption: VendorSortOption = .popular
    @State private var filterTask: Task<Void, Never>?
    @State private var promoIndex = 0
    @ObservedObject private var savedStore = SavedVendorsStore.shared
    @State private var selectedVendorRoute: VendorRoute?
    @FocusState private var isSearchFocused: Bool

    private let promoTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    private let searchBarID = "vendor-search-bar"

    private var filterCatalog: VendorFilterCatalog {
        VendorFilterCatalog(vendors: catalogVendors)
    }

    private var displayCategories: [VendorCategoryInfo] {
        let withVendors = categoriesStore.categoriesWithVendors(in: catalogVendors)
        return withVendors.isEmpty ? categoriesStore.categories : withVendors
    }

    private var filteredVendors: [VendorItem] {
        vendors
            .filter { vendor in
                let matchCategory = filter.categorySlugs.isEmpty || filter.categorySlugs.contains(vendor.categorySlug)
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                let matchSearch = query.isEmpty
                    || vendor.name.localizedCaseInsensitiveContains(query)
                    || vendor.categoryLabel.localizedCaseInsensitiveContains(query)
                    || vendor.tags.contains { $0.localizedCaseInsensitiveContains(query) }
                let matchRating = filter.minimumRating == nil
                    || (vendor.rating.map { $0 >= (filter.minimumRating ?? 0) } ?? true)
                let matchSaved = !filter.savedOnly || savedStore.contains(vendor.id)
                return matchCategory && matchSearch && matchRating && matchSaved
            }
            .sorted { lhs, rhs in
                switch sortOption {
                case .popular:
                    if lhs.isFeatured != rhs.isFeatured {
                        return lhs.isFeatured && !rhs.isFeatured
                    }
                    return lhs.packagesCount > rhs.packagesCount
                case .rating:
                    let lhsRating = lhs.rating ?? 0
                    let rhsRating = rhs.rating ?? 0
                    if lhsRating != rhsRating {
                        return lhsRating > rhsRating
                    }
                    return lhs.packagesCount > rhs.packagesCount
                case .newest:
                    return lhs.id > rhs.id
                }
            }
    }

    var body: some View {
        NavigationStack {
            vendorContent
                .navigationDestination(item: $selectedVendorRoute) { route in
                    VendorDetailView(slug: route.slug)
                }
        }
    }

    private var vendorContent: some View {
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
                        if isSearching {
                            searchResultsHeader
                        }
                        if !isSearching && !filter.isActive {
                            promoCarousel
                        }
                        vendorListSection
                        requestCTA
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
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
        .overlay {
            if isLoading && vendors.isEmpty {
                ProgressView()
            }
        }
        .task {
            async let categoriesTask: Void = categoriesStore.loadIfNeeded()
            async let catalogTask: Void = loadCatalog()
            _ = await (categoriesTask, catalogTask)
            await loadVendors()
        }
        .refreshable {
            async let categoriesTask: Void = categoriesStore.reload()
            async let catalogTask: Void = loadCatalog()
            _ = await (categoriesTask, catalogTask)
            await loadVendors()
        }
        .onChange(of: filter) { _, _ in
            filterTask?.cancel()
            filterTask = Task { await loadVendors() }
        }
        .sheet(isPresented: $showFilterSheet) {
            VendorFilterSheet(
                filter: $draftFilter,
                catalog: filterCatalog,
                categories: categoriesStore.categories,
                categoriesError: categoriesStore.loadError,
                onReloadCategories: {
                    Task { await categoriesStore.reload() }
                },
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

    private func openFilterSheet() {
        draftFilter = filter
        isSearchFocused = false
        showFilterSheet = true
    }

    private func loadCatalog() async {
        do {
            let envelope: Envelope<[Vendor]> = try await APIClient.shared.request("vendors")
            catalogVendors = envelope.data.map { VendorItem(api: $0, isSaved: savedStore.contains($0.id)) }
        } catch {
            if catalogVendors.isEmpty {
                errorMessage = error.userFacingMessage
            }
        }
    }

    private func loadVendors() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[Vendor]> = try await APIClient.shared.request(
                "vendors",
                queryItems: vendorQueryItems()
            )
            vendors = envelope.data.map { VendorItem(api: $0, isSaved: savedStore.contains($0.id)) }
        } catch {
            errorMessage = error.userFacingMessage
            vendors = []
        }
    }

    private func vendorQueryItems() -> [URLQueryItem]? {
        var items: [URLQueryItem] = []

        if let province = filter.province, province != VendorFilter.allProvincesLabel {
            items.append(URLQueryItem(name: "province", value: province))
        }

        if let city = filter.city, city != VendorFilter.allCitiesLabel {
            items.append(URLQueryItem(name: "city", value: city))
        }

        if filter.verifiedOnly {
            items.append(URLQueryItem(name: "verified", value: "1"))
        }

        if filter.categorySlugs.count == 1, let slug = filter.categorySlugs.first {
            items.append(URLQueryItem(name: "category", value: slug))
        }

        return items.isEmpty ? nil : items
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var activeFilterLabels: [String] {
        var labels: [String] = []
        if !filter.categorySlugs.isEmpty {
            let names = filter.categorySlugs
                .compactMap { categoriesStore.name(for: $0) ?? $0 }
                .sorted()
                .joined(separator: ", ")
            labels.append(names)
        }
        if let province = filter.province, province != VendorFilter.allProvincesLabel {
            labels.append(province)
        }
        if let city = filter.city, city != VendorFilter.allCitiesLabel {
            labels.append(city)
        }
        if let minimumRating = filter.minimumRating {
            labels.append("Rating \(String(format: "%.1f", minimumRating))+")
        }
        if filter.verifiedOnly {
            labels.append("Terverifikasi")
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

    private func activateSearch() {
        isSearchFocused = true
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

                Button(action: activateSearch) {
                    circleButton("magnifyingglass", isActive: isSearchFocused || isSearching)
                }
                .buttonStyle(.plain)
            }

            Text(L10n.Vendor.title)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text(L10n.Vendor.subtitle)
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
            Text(L10n.Vendor.found(filteredVendors.count))
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            Spacer()

            Button("Hapus") {
                searchText = ""
                isSearchFocused = false
            }
            .font(AppFont.medium(12))
            .foregroundStyle(AppTheme.ink.opacity(0.55))
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

                TextField(L10n.Vendor.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        isSearchFocused = false
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
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
                    Text(L10n.Common.filter)
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
        Group {
            if categoriesStore.isLoading && categoriesStore.categories.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Memuat kategori...")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            } else if let error = categoriesStore.loadError, categoriesStore.categories.isEmpty {
                HStack(spacing: 10) {
                    Text(error)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                    Button("Coba Lagi") {
                        Task { await categoriesStore.reload() }
                    }
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        VendorCategoryChip(
                            iconName: "square.grid.2x2",
                            label: "Semua",
                            isSelected: filter.categorySlugs.isEmpty
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                filter.categorySlugs = []
                            }
                        }

                        ForEach(displayCategories) { category in
                            VendorCategoryChip(
                                iconName: VendorCategoryAppearance.icon(for: category.icon, slug: category.slug),
                                label: category.name,
                                isSelected: filter.categorySlugs == [category.slug]
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if filter.categorySlugs == [category.slug] {
                                        filter.categorySlugs = []
                                    } else {
                                        filter.categorySlugs = [category.slug]
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Promo Carousel

    private var promoCarousel: some View {
        VStack(spacing: 10) {
            TabView(selection: $promoIndex) {
                ForEach(VendorPromo.samples.indices, id: \.self) { index in
                    VendorPromoCard(promo: VendorPromo.samples[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 148)

            HStack(spacing: 6) {
                ForEach(VendorPromo.samples.indices, id: \.self) { index in
                    Circle()
                        .fill(AppTheme.sageDark.opacity(index == promoIndex ? 1 : 0.25))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onReceive(promoTimer) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                promoIndex = (promoIndex + 1) % VendorPromo.samples.count
            }
        }
    }

    // MARK: - Vendor List

    private var vendorListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isSearching || filter.isActive ? "Hasil Filter" : "Semua Vendor")
                    .font(AppFont.semibold(18))
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                HStack(spacing: 6) {
                    Text("Urutkan")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))

                    Menu {
                        ForEach(VendorSortOption.allCases) { option in
                            Button(option.label) {
                                sortOption = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(sortOption.label)
                                .font(AppFont.medium(12))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(AppTheme.surface, in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(AppTheme.sage.opacity(0.12), lineWidth: 1)
                        }
                    }
                }
            }

            LazyVStack(spacing: 12) {
                if let errorMessage, vendors.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(AppTheme.ink.opacity(0.25))
                        Text(errorMessage)
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.ink.opacity(0.55))
                        Button("Coba Lagi") {
                            Task {
                                await loadCatalog()
                                await loadVendors()
                            }
                        }
                        .font(AppFont.medium(12))
                        .foregroundStyle(AppTheme.sageDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else if filteredVendors.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(AppTheme.ink.opacity(0.25))
                        Text(L10n.Vendor.notFound)
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.ink.opacity(0.55))
                        Text(L10n.Vendor.notFoundSub)
                            .font(AppFont.regular(12))
                            .foregroundStyle(AppTheme.ink.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    ForEach(filteredVendors) { vendor in
                        Button {
                            selectedVendorRoute = VendorRoute(slug: vendor.slug)
                        } label: {
                            VendorCard(
                                vendor: vendor,
                                isSaved: savedStore.contains(vendor.id)
                            ) {
                                savedStore.toggle(vendor.id)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - CTA

    private var requestCTA: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 44, height: 44)
                .background(.white, in: Circle())
                .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text("Belum menemukan yang cocok?")
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
                Text("Kirim kebutuhanmu, vendor akan\nmenghubungimu.")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            Button {} label: {
                Text("Kirim\nPermintaan")
                    .font(AppFont.medium(11))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 14, y: 7)
    }
}

// MARK: - Filter Sheet

private struct VendorFilterSheet: View {
    @Binding var filter: VendorFilter
    let catalog: VendorFilterCatalog
    let categories: [VendorCategoryInfo]
    let categoriesError: String?
    let onReloadCategories: () -> Void
    let onApply: (VendorFilter) -> Void
    let onReset: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var displayCategories: [VendorCategoryInfo] {
        let withVendors = categories.filter { catalog.categorySlugs.contains($0.slug) }
        return withVendors.isEmpty ? categories : withVendors
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        categorySection
                        provinceSection
                        if hasSelectedProvince {
                            citySection
                        }
                        ratingSection
                        toggleSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Filter Vendor")
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

                    Button {
                        onApply(filter)
                    } label: {
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
        .onChange(of: filter.province) { _, province in
            if let city = filter.city,
               city != VendorFilter.allCitiesLabel,
               !catalog.cities(for: province).contains(city) {
                filter.city = nil
            }
        }
    }

    private var hasSelectedProvince: Bool {
        guard let province = filter.province else {
            return false
        }

        return province != VendorFilter.allProvincesLabel
    }

    private var provinceOptions: [String] {
        [VendorFilter.allProvincesLabel] + catalog.provinces
    }

    private var cityOptions: [String] {
        [VendorFilter.allCitiesLabel] + catalog.cities(for: filter.province)
    }

    private var categorySection: some View {
        filterSection("Kategori") {
            if let categoriesError, categories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoriesError)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                    Button("Muat Ulang Kategori", action: onReloadCategories)
                        .font(AppFont.medium(12))
                        .foregroundStyle(AppTheme.sageDark)
                }
            } else if displayCategories.isEmpty {
                Text("Belum ada kategori vendor.")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                    ForEach(displayCategories) { category in
                        let isSelected = filter.categorySlugs.contains(category.slug)
                        Button {
                            if isSelected {
                                filter.categorySlugs.remove(category.slug)
                            } else {
                                filter.categorySlugs.insert(category.slug)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: VendorCategoryAppearance.icon(for: category.icon, slug: category.slug))
                                    .font(.system(size: 12, weight: .medium))
                                Text(category.name)
                                    .font(AppFont.medium(12))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .foregroundStyle(isSelected ? .white : AppTheme.sageDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                isSelected ? AppTheme.sageDark : AppTheme.lightSage,
                                in: Capsule()
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var provinceSection: some View {
        filterSection("Provinsi") {
            if catalog.provinces.isEmpty {
                Text("Belum ada data provinsi dari vendor.")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            } else {
                regionChipRow(
                    options: provinceOptions,
                    selected: filter.province ?? VendorFilter.allProvincesLabel,
                    allLabel: VendorFilter.allProvincesLabel
                ) { province in
                    filter.province = province == VendorFilter.allProvincesLabel ? nil : province
                    filter.city = nil
                }
            }
        }
    }

    private var citySection: some View {
        filterSection("Kota / Kabupaten") {
            if cityOptions.count <= 1 {
                Text("Tidak ada kota untuk provinsi ini.")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            } else {
                regionChipRow(
                    options: cityOptions,
                    selected: filter.city ?? VendorFilter.allCitiesLabel,
                    allLabel: VendorFilter.allCitiesLabel
                ) { city in
                    filter.city = city == VendorFilter.allCitiesLabel ? nil : city
                }
            }
        }
    }

    private func regionChipRow(
        options: [String],
        selected: String,
        allLabel: String,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selected == option
                    Button {
                        onSelect(option)
                    } label: {
                        Text(option)
                            .font(AppFont.medium(12))
                            .foregroundStyle(isSelected ? .white : AppTheme.ink.opacity(0.65))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? AppTheme.sageDark : AppTheme.mist,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var ratingSection: some View {
        filterSection("Rating Minimum") {
            HStack(spacing: 8) {
                ForEach(VendorFilter.ratingOptions, id: \.label) { option in
                    let isSelected = filter.minimumRating == option.value
                    Button {
                        filter.minimumRating = option.value
                    } label: {
                        Text(option.label)
                            .font(AppFont.medium(11))
                            .foregroundStyle(isSelected ? .white : AppTheme.ink.opacity(0.65))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? AppTheme.sageDark : AppTheme.mist,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var toggleSection: some View {
        VStack(spacing: 12) {
            toggleRow(
                title: "Hanya Vendor Terverifikasi",
                subtitle: "Tampilkan vendor dengan badge verifikasi",
                isOn: $filter.verifiedOnly
            )
            toggleRow(
                title: "Hanya Vendor Tersimpan",
                subtitle: "Tampilkan vendor yang sudah Anda simpan",
                isOn: $filter.savedOnly
            )
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                Text(subtitle)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer()

            Toggle("", isOn: isOn)
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

private struct VendorCategoryChip: View {
    let iconName: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.55))
                    .frame(width: 54, height: 54)
                    .background(
                        isSelected ? AppTheme.mist : AppTheme.surface,
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .stroke(AppTheme.sage.opacity(isSelected ? 0 : 0.10), lineWidth: 1)
                    }

                Text(label)
                    .font(AppFont.regular(11))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.55))
            }
            .frame(width: 72)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Promo Card

private struct VendorPromoCard: View {
    let promo: VendorPromo

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: promo.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let imageName = promo.imageName {
                HStack {
                    Spacer()
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150)
                        .clipped()
                        .mask {
                            LinearGradient(
                                colors: [.clear, .white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(promo.eyebrow)
                    .font(AppFont.regular(11))
                    .foregroundStyle(.white.opacity(0.85))

                Text(promo.title)
                    .font(AppFont.semibold(18))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Button {} label: {
                    HStack(spacing: 4) {
                        Text(promo.buttonTitle)
                            .font(AppFont.medium(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: AppTheme.sageDark.opacity(0.14), radius: 16, y: 8)
    }
}

// MARK: - Vendor Card

private struct VendorCard: View {
    let vendor: VendorItem
    let isSaved: Bool
    let onToggleSave: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            vendorLogo

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(vendor.name)
                        .font(AppFont.semibold(14))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    if vendor.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.sageDark)
                    }
                }

                Text(vendor.categoryLabel)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))

                Label(vendor.city, systemImage: "mappin")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .labelStyle(.titleAndIcon)

                if let rating = vendor.rating, let reviewCount = vendor.reviewCount {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.gold)
                        Text(String(format: "%.1f", rating))
                            .font(AppFont.medium(11))
                            .foregroundStyle(AppTheme.ink)
                        Text("(\(reviewCount) review)")
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }
                } else if vendor.packagesCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.sageDark)
                        Text("\(vendor.packagesCount) paket")
                            .font(AppFont.medium(11))
                            .foregroundStyle(AppTheme.ink)
                        if let startingPrice = vendor.startingPrice {
                            Text("· dari \(CurrencyFormatter.rupiahShort(startingPrice))")
                                .font(AppFont.regular(11))
                                .foregroundStyle(AppTheme.ink.opacity(0.45))
                        }
                    }
                }

                FlowTagRow(tags: vendor.tags)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [vendor.thumbnailTint.opacity(0.35), vendor.thumbnailTint.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay {
                        Image(systemName: vendor.thumbnailSymbol)
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(vendor.thumbnailTint.opacity(0.8))
                    }

                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isSaved ? AppTheme.sageDark : AppTheme.ink.opacity(0.45))
                        .frame(width: 26, height: 26)
                        .background(.white.opacity(0.92), in: Circle())
                }
                .buttonStyle(.borderless)
                .offset(x: 4, y: -4)
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.07), radius: 14, y: 7)
    }

    private var vendorLogo: some View {
        Image(systemName: vendor.logoSymbol)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(vendor.logoTint, in: Circle())
    }
}

// MARK: - Tag Row

private struct FlowTagRow: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                Text(tag)
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.mist, in: Capsule())
                    .lineLimit(1)
            }
        }
    }
}
