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
    @ObservedObject private var savedStore = SavedVendorsStore.shared
    @State private var selectedVendorRoute: VendorRoute?
    @State private var showVendorRequestSheet = false
    @State private var showPartnerNotice = false
    @AppStorage("vendor_partner_notice_seen") private var hasSeenPartnerNotice = false
    @FocusState private var isSearchFocused: Bool

    private let searchBarID = "vendor-search-bar"
    private let partnerSiteURL = URL(string: "https://apps.apple.com/id/app/paket-pernikahan/id6777688676")

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
                let matchSaved = !filter.savedOnly || savedStore.contains(vendor.id)
                return matchCategory && matchSearch && matchSaved
            }
            .sorted { lhs, rhs in
                switch sortOption {
                case .popular:
                    if lhs.isFeatured != rhs.isFeatured {
                        return lhs.isFeatured && !rhs.isFeatured
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
                        vendorListSection
                        requestCTA
                        partnerFootnote
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

            if !hasSeenPartnerNotice {
                try? await Task.sleep(for: .milliseconds(450))
                showPartnerNotice = true
            }
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
        .sheet(isPresented: $showVendorRequestSheet) {
            VendorRequestSheet()
        }
        .sheet(isPresented: $showPartnerNotice, onDismiss: {
            hasSeenPartnerNotice = true
        }) {
            VendorPartnerNoticeSheet {
                hasSeenPartnerNotice = true
                showPartnerNotice = false
            }
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
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
        if filter.verifiedOnly {
            labels.append(L10n.Vendor.filterVerifiedChip)
        }
        if filter.savedOnly {
            labels.append(L10n.Vendor.filterSavedChip)
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
                    circleButton("arrow.left")
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
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(L10n.Vendor.subtitle)
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    private func circleButton(_ icon: String, isActive: Bool = false) -> some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(isActive ? AppTheme.labelOnLightSurface : AppTheme.iconOnChip)
            .frame(width: 42, height: 42)
            .background {
                Circle()
                    .fill(isActive ? AppTheme.selectedChipFill : AppTheme.iconChipFill)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .overlay {
                Circle()
                    .stroke(
                        isActive ? AppTheme.sage.opacity(0.35) : AppTheme.iconChipStroke,
                        lineWidth: 1
                    )
            }
            .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
    }

    private var searchResultsHeader: some View {
        HStack {
            Text(L10n.Vendor.found(filteredVendors.count))
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            Spacer()

            Button(L10n.Common.delete) {
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
                        .foregroundStyle(isSearchFocused ? AppTheme.iconOnChip : AppTheme.inkMuted(0.45))
                }
                .buttonStyle(.plain)

                TextField(L10n.Vendor.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.titleOnGlass)
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
                            .foregroundStyle(AppTheme.inkMuted(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .premiumGlassCard(cornerRadius: 24)
            .overlay {
                Capsule()
                    .stroke(
                        isSearchFocused ? AppTheme.sageDark.opacity(0.35) : Color.clear,
                        lineWidth: isSearchFocused ? 1.5 : 0
                    )
            }

            Button(action: openFilterSheet) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                    Text(L10n.Common.filter)
                        .font(AppFont.medium(12))
                }
                .foregroundStyle(filter.isActive ? AppTheme.labelOnLightSurface : AppTheme.inkMuted(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(filter.isActive ? AppTheme.selectedChipFill : AppTheme.chipIdleFill)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .overlay {
                    Capsule()
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

    private var categoryRow: some View {
        Group {
            if categoriesStore.isLoading && categoriesStore.categories.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(L10n.Vendor.loadingCategories)
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
                    Button(L10n.Common.tryAgain) {
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
                            label: L10n.Common.all,
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

    // MARK: - Vendor List

    private var vendorListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(isSearching || filter.isActive ? L10n.Vendor.resultsFiltered : L10n.Vendor.allVendors)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                HStack(spacing: 6) {
                    Text(L10n.Common.sort)
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
                        .premiumGlassCard(cornerRadius: 20)
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
                        Button(L10n.Common.tryAgain) {
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
                    .premiumGlassCard(cornerRadius: 22)
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
                    .premiumGlassCard(cornerRadius: 22)
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
                .background {
                    Circle()
                        .fill(Color.white.opacity(0.78))
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle().stroke(Color.white.opacity(0.65), lineWidth: 1)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Vendor.requestCtaTitle)
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
                Text(L10n.Vendor.requestCtaSub)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            Button {
                showVendorRequestSheet = true
            } label: {
                Text(L10n.Vendor.sendRequest)
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
        .premiumGlassCard(cornerRadius: 22)
    }

    private var partnerFootnote: some View {
        Group {
            if let partnerSiteURL {
                Link(destination: partnerSiteURL) {
                    partnerFootnoteLabel
                }
                .buttonStyle(.plain)
            } else {
                partnerFootnoteLabel
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private var partnerFootnoteLabel: some View {
        Text(L10n.Vendor.partnerFootnote)
            .font(AppFont.regular(11))
            .foregroundStyle(AppTheme.ink.opacity(0.42))
            .multilineTextAlignment(.center)
    }
}

// MARK: - Partner Notice Sheet

private struct VendorPartnerNoticeSheet: View {
    var onAcknowledge: () -> Void

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            VStack(alignment: .leading, spacing: 18) {
                Text(L10n.Vendor.partnerNoticeTitle)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Vendor.partnerNoticeBody)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink.opacity(0.62))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                Button(action: onAcknowledge) {
                    Text(L10n.Vendor.partnerNoticeCTA)
                        .font(AppFont.semibold(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Vendor Request Sheet

private struct VendorRequestSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var category = ""
    @State private var city = ""
    @State private var budget = ""
    @State private var notes = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    private var canSend: Bool {
        let hasNeed = !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasNeed && !isSending
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.Vendor.requestFormHint)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                        }

                        fieldCard(title: L10n.Vendor.requestCategoryTitle, placeholder: L10n.Vendor.requestCategoryPlaceholder, text: $category)
                        fieldCard(title: L10n.Vendor.requestCityTitle, placeholder: L10n.Vendor.requestCityPlaceholder, text: $city)
                        fieldCard(title: L10n.Vendor.requestBudgetTitle, placeholder: L10n.Vendor.requestBudgetPlaceholder, text: $budget)
                        notesCard
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(L10n.Vendor.sendRequestShort)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await sendRequest() }
                } label: {
                    HStack(spacing: 8) {
                        if isSending {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(L10n.Vendor.sendRequestShort)
                            .font(AppFont.medium(15))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        canSend ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
            .alert(L10n.Vendor.requestSentTitle, isPresented: $showSuccess) {
                Button(L10n.Common.done) { dismiss() }
            } message: {
                Text(L10n.Vendor.requestSentMessage)
            }
        }
    }

    private func fieldCard(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            TextField(placeholder, text: text)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .premiumGlassCard(cornerRadius: 14)
        }
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Vendor.requestNotesTitle)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.sageDark)

            TextField(L10n.Vendor.requestNotesPlaceholder, text: $notes, axis: .vertical)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(4 ... 8)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .premiumGlassCard(cornerRadius: 14)
        }
    }

    private func composedMessage() -> String {
        var lines = [L10n.Vendor.requestMsgHeader]

        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBudget = budget.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedCategory.isEmpty {
            lines.append(L10n.Vendor.requestMsgCategory(trimmedCategory))
        }
        if !trimmedCity.isEmpty {
            lines.append(L10n.Vendor.requestMsgLocation(trimmedCity))
        }
        if !trimmedBudget.isEmpty {
            lines.append(L10n.Vendor.requestMsgBudget(trimmedBudget))
        }
        if !trimmedNotes.isEmpty {
            lines.append(L10n.Vendor.requestMsgDetail(trimmedNotes))
        }

        return lines.joined(separator: "\n")
    }

    private func sendRequest() async {
        guard canSend else { return }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        do {
            let threadEnvelope: Envelope<MessageThread> = try await APIClient.shared.request(
                "messages/threads/support"
            )
            let thread = threadEnvelope.data

            let _: Envelope<ChatMessageItem> = try await APIClient.shared.request(
                "messages/threads/\(thread.id)/send",
                method: "POST",
                json: [
                    "body": composedMessage(),
                    "topic": SupportMessageTopic.other.rawValue,
                ]
            )
            showSuccess = true
        } catch {
            errorMessage = error.userFacingMessage
        }
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
                        toggleSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Vendor.filterTitle)
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

                    Button {
                        onApply(filter)
                    } label: {
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
        filterSection(L10n.Common.category) {
            if let categoriesError, categories.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoriesError)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                    Button(L10n.Vendor.reloadCategories, action: onReloadCategories)
                        .font(AppFont.medium(12))
                        .foregroundStyle(AppTheme.sageDark)
                }
            } else if displayCategories.isEmpty {
                Text(L10n.Vendor.noCategories)
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
        filterSection(L10n.Vendor.province) {
            if catalog.provinces.isEmpty {
                Text(L10n.Vendor.noProvinces)
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
        filterSection(L10n.Vendor.citySection) {
            if cityOptions.count <= 1 {
                Text(L10n.Vendor.noCities)
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

    private var toggleSection: some View {
        VStack(spacing: 12) {
            toggleRow(
                title: L10n.Vendor.filterVerifiedTitle,
                subtitle: L10n.Vendor.filterVerifiedSub,
                isOn: $filter.verifiedOnly
            )
            toggleRow(
                title: L10n.Vendor.filterSavedTitle,
                subtitle: L10n.Vendor.filterSavedSub,
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : AppTheme.iconOnChip)
                    .frame(width: 54, height: 54)
                    .background {
                        Circle()
                            .fill(isSelected ? AppTheme.brandGradientEnd : AppTheme.iconChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                isSelected ? Color.white.opacity(0.22) : AppTheme.iconChipStroke,
                                lineWidth: 1
                            )
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 8, y: 3)

                Text(label)
                    .font(AppFont.regular(11))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? AppTheme.titleOnGlass : AppTheme.inkMuted(0.55))
            }
            .frame(width: 72)
        }
        .buttonStyle(.plain)
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
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .lineLimit(1)

                    if vendor.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.sageMuted(0.95))
                    }
                }

                Text(vendor.categoryLabel)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.5))

                Label(vendor.city, systemImage: "mappin")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.inkMuted(0.5))
                    .labelStyle(.titleAndIcon)

                if let rating = vendor.rating, let reviewCount = vendor.reviewCount {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.gold)
                        Text(String(format: "%.1f", rating))
                            .font(AppFont.medium(11))
                            .foregroundStyle(AppTheme.titleOnGlass)
                        Text(L10n.Vendor.reviewCount(reviewCount))
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.inkMuted(0.45))
                    }
                } else if vendor.packagesCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.iconOnChip)
                        Text(L10n.Vendor.packageCount(vendor.packagesCount))
                            .font(AppFont.medium(11))
                            .foregroundStyle(AppTheme.titleOnGlass)
                        if let startingPrice = vendor.startingPrice {
                            Text(L10n.Vendor.fromPrice(CurrencyFormatter.rupiahShort(startingPrice)))
                                .font(AppFont.regular(11))
                                .foregroundStyle(AppTheme.inkMuted(0.45))
                        }
                    }
                }

                FlowTagRow(tags: vendor.tags)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .topTrailing) {
                vendorThumbnail

                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSaved ? AppTheme.labelOnLightSurface : AppTheme.iconOnChip)
                        .frame(width: 26, height: 26)
                        .background {
                            Circle()
                                .fill(isSaved ? AppTheme.selectedChipFill : AppTheme.iconChipFill)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .overlay {
                            Circle().stroke(AppTheme.iconChipStroke, lineWidth: 1)
                        }
                }
                .buttonStyle(.borderless)
                .offset(x: 4, y: -4)
            }
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 22)
    }

    private var vendorLogo: some View {
        ZStack {
            Circle()
                .fill(vendor.logoTint)

            if let url = remoteImageURL(vendor.logoUrl ?? vendor.coverImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        logoPlaceholderIcon
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                logoPlaceholderIcon
            }
        }
        .frame(width: 48, height: 48)
    }

    private var logoPlaceholderIcon: some View {
        Image(systemName: vendor.logoSymbol)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
    }

    private var vendorThumbnail: some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

        return ZStack {
            shape
                .fill(
                    LinearGradient(
                        colors: [vendor.thumbnailTint.opacity(0.35), vendor.thumbnailTint.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let url = remoteImageURL(vendor.coverImageUrl ?? vendor.logoUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        thumbnailPlaceholderIcon
                    case .empty:
                        thumbnailPlaceholderIcon
                            .overlay { ProgressView().tint(vendor.thumbnailTint) }
                    @unknown default:
                        thumbnailPlaceholderIcon
                    }
                }
                .frame(width: 88, height: 88)
                .clipped()
            } else {
                thumbnailPlaceholderIcon
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(shape)
    }

    private var thumbnailPlaceholderIcon: some View {
        Image(systemName: vendor.thumbnailSymbol)
            .font(.system(size: 28, weight: .light))
            .foregroundStyle(AppTheme.inkMuted(0.55))
    }

    private func remoteImageURL(_ raw: String?) -> URL? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        return URL(string: raw)
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
                    .foregroundStyle(AppTheme.inkMuted(0.65))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.chipIdleFill, in: Capsule())
                    .lineLimit(1)
            }
        }
    }
}
