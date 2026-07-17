import SwiftUI
import UniformTypeIdentifiers

private struct ExcelTemplateShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

enum GuestListSegment: String, CaseIterable, Identifiable {
    case guests
    case vip
    case family

    var id: String { rawValue }

    var title: String {
        switch self {
        case .guests: return L10n.Guest.tabGuests
        case .vip: return L10n.Guest.tabVip
        case .family: return L10n.Guest.tabFamily
        }
    }

    var emptyTitle: String {
        switch self {
        case .guests: return L10n.Guest.emptyTitle
        case .vip: return L10n.Guest.emptyVipTitle
        case .family: return L10n.Guest.emptyFamilyTitle
        }
    }

    var emptySub: String {
        switch self {
        case .guests: return L10n.Guest.emptySub
        case .vip: return L10n.Guest.emptyVipSub
        case .family: return L10n.Guest.emptyFamilySub
        }
    }

    var addTitle: String {
        switch self {
        case .guests: return L10n.Guest.addGuest
        case .vip: return L10n.Guest.addVip
        case .family: return L10n.Guest.addFamily
        }
    }

    var listIcon: String {
        switch self {
        case .guests: return "person.2.fill"
        case .vip: return "star.fill"
        case .family: return "house.fill"
        }
    }

    var excelTemplatePath: String {
        switch self {
        case .guests: return "guests-excel-template"
        case .vip: return "vip-guests-excel-template"
        case .family: return "family-members-excel-template"
        }
    }

    var excelImportPath: String {
        switch self {
        case .guests: return "guests-import-excel"
        case .vip: return "vip-guests-import-excel"
        case .family: return "family-members-import-excel"
        }
    }

    var excelTemplateFileName: String {
        switch self {
        case .guests: return "template-daftar-tamu.xlsx"
        case .vip: return "template-tamu-vip.xlsx"
        case .family: return "template-anggota-keluarga.xlsx"
        }
    }

    var deleteAllPath: String {
        switch self {
        case .guests: return "guests-all"
        case .vip: return "vip-guests-all"
        case .family: return "family-members-all"
        }
    }
}

struct GuestView: View {
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared

    @State private var segment: GuestListSegment = .guests
    @State private var guests: [Guest] = []
    @State private var vipGuests: [VipGuest] = []
    @State private var familyMembers: [FamilyMember] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false
    @State private var showExportSheet = false
    @State private var showExcelImporter = false
    @State private var showPaywall = false
    @State private var isExcelBusy = false
    @State private var isDeletingAll = false
    @State private var showDeleteAllConfirm = false
    @State private var excelStatusTitle = ""
    @State private var excelStatusMessage: String?
    @State private var showExcelStatus = false
    @State private var templateShareItem: ExcelTemplateShareItem?
    @State private var selectedDetail: GuestDetailTarget?
    @State private var selectedFilter: RsvpKind? = nil
    @State private var sortOrder: GuestSortOrder = .numberAsc
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var currentPage = 1

    private let pageSize = 5

    private var isPremium: Bool {
        premium.isPremium(user: session.currentUser)
    }

    private var currentSegmentCount: Int {
        switch segment {
        case .guests: return guests.count
        case .vip: return vipGuests.count
        case .family: return familyMembers.count
        }
    }

    private var allTargets: [GuestDetailTarget] {
        switch segment {
        case .guests:
            return guests.map(GuestDetailTarget.guest)
        case .vip:
            return vipGuests.map(GuestDetailTarget.vip)
        case .family:
            return familyMembers.map(GuestDetailTarget.family)
        }
    }

    private var allRows: [GuestRowItem] {
        allTargets.map(GuestRowItem.init(target:))
    }

    private var rows: [GuestRowItem] {
        allRows
            .filter { row in
                let matchFilter = selectedFilter == nil || row.kind == selectedFilter
                let matchSearch = searchText.isEmpty
                    || row.name.localizedCaseInsensitiveContains(searchText)
                    || (row.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false)
                return matchFilter && matchSearch
            }
            .sorted { lhs, rhs in
                switch sortOrder {
                case .numberAsc:
                    let left = lhs.no ?? Int.max
                    let right = rhs.no ?? Int.max
                    if left != right {
                        return left < right
                    }
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                case .nameAsc:
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                case .nameDesc:
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
                }
            }
    }

    private var totalPages: Int {
        max(1, Int(ceil(Double(rows.count) / Double(pageSize))))
    }

    private var displayedRows: [GuestRowItem] {
        let page = min(max(currentPage, 1), totalPages)
        let start = (page - 1) * pageSize
        guard !rows.isEmpty, start < rows.count else { return [] }
        let end = min(start + pageSize, rows.count)
        return Array(rows[start..<end])
    }

    private var pageRangeLabel: String {
        guard !rows.isEmpty else { return "" }
        let page = min(max(currentPage, 1), totalPages)
        let start = (page - 1) * pageSize + 1
        let end = min(page * pageSize, rows.count)
        return "\(start)–\(end) / \(rows.count)"
    }

    private var totalGuests: Int { allRows.count }
    private var confirmedGuests: Int { allRows.filter { $0.kind == .confirmed }.count }
    private var pendingGuests: Int { allRows.filter { $0.kind == .pending }.count }
    private var absentGuests: Int { allRows.filter { $0.kind == .absent }.count }

    private var guestCount: Int { guests.count }
    private var vipCount: Int { vipGuests.count }
    private var familyCount: Int { familyMembers.count }

    private var nextSequenceNumber: Int {
        switch segment {
        case .guests:
            return (guests.compactMap(\.no).max() ?? 0) + 1
        case .vip:
            return (vipGuests.compactMap(\.no).max() ?? 0) + 1
        case .family:
            return (familyMembers.compactMap(\.no).max() ?? 0) + 1
        }
    }

    private func percent(_ value: Int) -> Int {
        totalGuests == 0 ? 0 : Int((Double(value) / Double(totalGuests) * 100).rounded())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        segmentTabs
                        statsCard
                        rsvpOverviewCard
                        filterChips
                        searchRow
                        listHeader
                        guestListContent
                        actionBar
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        dismissSearchKeyboard()
                    }
                )
                .blur(radius: isPremium ? 0 : 2.5)
                .opacity(isPremium ? 1 : 0.82)

                if !isPremium {
                    VStack(spacing: 14) {
                        ForEach(premium.sharedGuestAccess) { access in
                            NavigationLink {
                                SharedUserDetailView(userId: access.userId)
                            } label: {
                                sharedPartnerAccessCard(
                                    title: L10n.Premium.partnerGuestsCta,
                                    subtitle: L10n.Premium.partnerAccessSub(access.name)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        PremiumLockedOverlay {
                            showPaywall = true
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await PremiumStore.shared.refreshServerEntitlement()
                if isPremium {
                    await load()
                } else {
                    loadPreview()
                }
            }
            .refreshable {
                if isPremium {
                    await load()
                } else {
                    loadPreview()
                }
            }
            .onChange(of: segment) { _, _ in
                selectedFilter = nil
                searchText = ""
                resetPagination()
                dismissSearchKeyboard()
            }
            .onChange(of: selectedFilter) { _, _ in
                resetPagination()
            }
            .onChange(of: searchText) { _, _ in
                resetPagination()
            }
            .onChange(of: sortOrder) { _, _ in
                resetPagination()
            }
            .onChange(of: rows.count) { _, _ in
                if currentPage > totalPages {
                    currentPage = totalPages
                }
            }
            .onChange(of: isPremium) { _, premium in
                Task {
                    if premium {
                        await load()
                    } else {
                        loadPreview()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                guard isPremium else { return }
                Task { await load() }
            }
            .sheet(isPresented: $showAddSheet) {
                AddGuestEntrySheet(
                    segment: segment,
                    nextSequenceNumber: nextSequenceNumber
                ) {
                    await load()
                }
            }
            .sheet(item: $selectedDetail) { detail in
                GuestDetailSheet(target: detail) {
                    await load()
                }
            }
            .sheet(isPresented: $showExportSheet) {
                GuestExportShareView(
                    guests: guests,
                    vipGuests: vipGuests,
                    familyMembers: familyMembers
                )
            }
            .sheet(item: $templateShareItem) { item in
                NavigationStack {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.sageDark)
                        Text(L10n.Guest.templateReady)
                            .font(AppFont.medium(16))
                            .foregroundStyle(AppTheme.ink)
                        Text(item.url.lastPathComponent)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.ink.opacity(0.5))
                        ShareLink(item: item.url) {
                            Label(L10n.Guest.shareTemplate, systemImage: "square.and.arrow.up")
                                .font(AppFont.medium(15))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding(24)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.Common.close) { templateShareItem = nil }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .fileImporter(
                isPresented: $showExcelImporter,
                allowedContentTypes: [
                    UTType(filenameExtension: "xlsx") ?? .data,
                    .spreadsheet,
                ],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    Task { await importExcel(from: url) }
                case .failure(let error):
                    excelStatusTitle = L10n.Common.warning
                    excelStatusMessage = error.localizedDescription
                    showExcelStatus = true
                }
            }
            .alert(excelStatusTitle, isPresented: $showExcelStatus) {
                Button(L10n.Common.ok, role: .cancel) {}
            } message: {
                Text(excelStatusMessage ?? "")
            }
            .confirmationDialog(
                L10n.Guest.deleteAllConfirmTitle(segment.title),
                isPresented: $showDeleteAllConfirm,
                titleVisibility: .visible
            ) {
                Button(L10n.Guest.deleteAllAction, role: .destructive) {
                    Task { await deleteAllInSegment() }
                }
                Button(L10n.Common.cancel, role: .cancel) {}
            } message: {
                Text(L10n.Guest.deleteAllConfirmMessage(segment.title, currentSegmentCount))
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onUnlocked: {
                    Task { await load() }
                })
                .environmentObject(session)
            }
        }
    }

    private func runPremiumOrPaywall(_ action: @escaping () -> Void) {
        PremiumGate.presentOrRun(session: session, showPaywall: $showPaywall, action: action)
    }

    private func sharedPartnerAccessCard(title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 42, height: 42)
                .background(AppTheme.iconChipFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Text(subtitle)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.65))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.inkMuted(0.45))
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 18)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Guest.title)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.titleOnGlass)

                Text(L10n.Guest.subtitle)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.gold)
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)
        }
        .frame(height: 88, alignment: .top)
        .padding(.top, 8)
    }

    private var segmentTabs: some View {
        HStack(spacing: 6) {
            ForEach(GuestListSegment.allCases) { item in
                let count: Int = {
                    switch item {
                    case .guests: return guestCount
                    case .vip: return vipCount
                    case .family: return familyCount
                    }
                }()
                let isSelected = segment == item

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        segment = item
                    }
                    dismissSearchKeyboard()
                } label: {
                    VStack(spacing: 4) {
                        Text(item.title)
                            .font(AppFont.semibold(13))
                            .foregroundStyle(isSelected ? AppTheme.labelOnLightSurface : AppTheme.inkMuted(0.55))
                        Text("\(count)")
                            .font(AppFont.medium(11))
                            .foregroundStyle(isSelected ? AppTheme.accentOnLightSurface : AppTheme.inkMuted(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppTheme.selectedChipFill)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? AppTheme.iconChipStroke : Color.clear, lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(isSelected ? 0.06 : 0), radius: 8, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.chipIdleFill)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.iconChipStroke, lineWidth: 1)
        }
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(icon: "person.2", tint: AppTheme.iconOnChip, label: L10n.Guest.totalGuests, value: totalGuests, sub: L10n.Guest.people, subTint: AppTheme.inkMuted(0.4))
            statItem(icon: "checkmark.circle", tint: AppTheme.iconOnChip, label: L10n.Common.confirmed, value: confirmedGuests, sub: "\(percent(confirmedGuests))%", subTint: AppTheme.inkMuted(0.4))
            statItem(icon: "hourglass", tint: AppTheme.gold, label: L10n.Common.pending, value: pendingGuests, sub: "\(percent(pendingGuests))%", subTint: AppTheme.gold)
            statItem(icon: "xmark.circle", tint: AppTheme.statusMuted, label: L10n.Common.notAttending, value: absentGuests, sub: "\(percent(absentGuests))%", subTint: AppTheme.statusMuted)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
        .premiumGlassCard(cornerRadius: 28)
    }

    private func statItem(icon: String, tint: Color, label: String, value: Int, sub: String, subTint: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                }

            Text(label)
                .font(AppFont.medium(11))
                .foregroundStyle(AppTheme.inkMuted(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("\(value)")
                .font(AppFont.semibold(21))
                .monospacedDigit()
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(sub)
                .font(AppFont.regular(10))
                .foregroundStyle(subTint)
        }
        .frame(maxWidth: .infinity)
    }

    private var rsvpOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L10n.Guest.rsvpOverview)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.titleOnGlass)
                Spacer()
                Text(segment.title)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.45))
            }

            HStack(spacing: 18) {
                DonutChart(
                    segments: [
                        (Double(confirmedGuests), AppTheme.sageDark),
                        (Double(pendingGuests), AppTheme.gold),
                        (Double(absentGuests), AppTheme.statusMuted),
                    ]
                )
                .frame(width: 92, height: 92)

                VStack(spacing: 12) {
                    legendRow(color: AppTheme.sageDark, title: L10n.Common.confirmed, value: confirmedGuests, percent: percent(confirmedGuests))
                    legendRow(color: AppTheme.gold, title: L10n.Common.pending, value: pendingGuests, percent: percent(pendingGuests))
                    legendRow(color: AppTheme.statusMuted, title: L10n.Common.notAttending, value: absentGuests, percent: percent(absentGuests))
                }
            }
        }
        .padding(18)
        .premiumGlassCard(cornerRadius: 28)
    }

    private func legendRow(color: Color, title: String, value: Int, percent: Int) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 8) {
                Circle().fill(color).frame(width: 9, height: 9)
                Text(title)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.inkMuted(0.7))
                Spacer()
                Text("\(value) (\(percent)%)")
                    .font(AppFont.semibold(13))
                    .foregroundStyle(AppTheme.inkMuted(0.7))
            }
            ProgressBarLine(progress: totalGuests == 0 ? 0 : Double(value) / Double(totalGuests), color: color)
                .frame(height: 4)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: L10n.Common.all, kind: nil)
                chip(title: L10n.Common.confirmed, kind: .confirmed)
                chip(title: L10n.Common.pending, kind: .pending)
                chip(title: L10n.Common.notAttending, kind: .absent)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }

    private func chip(title: String, kind: RsvpKind?) -> some View {
        let isSelected = selectedFilter == kind
        return Button {
            dismissSearchKeyboard()
            withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = kind }
        } label: {
            Text(title)
                .font(AppFont.semibold(13))
                .foregroundStyle(isSelected ? .white : AppTheme.sageMuted(0.72))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.sage, AppTheme.brandGradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
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
                .shadow(color: AppTheme.sageDark.opacity(isSelected ? 0.14 : 0.05), radius: isSelected ? 10 : 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.inkMuted(0.4))
                TextField(L10n.Guest.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        dismissSearchKeyboard()
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .premiumGlassCard(cornerRadius: 16)

            Menu {
                Button {
                    runPremiumOrPaywall {
                        Task { await downloadExcelTemplate() }
                    }
                } label: {
                    Label(L10n.Guest.downloadTemplate, systemImage: "arrow.down.doc")
                }
                .disabled(isExcelBusy || isDeletingAll)

                Button {
                    runPremiumOrPaywall {
                        Task { @MainActor in
                            // Menu dismiss races the importer presentation on device/Release builds.
                            try? await Task.sleep(for: .milliseconds(350))
                            showExcelImporter = true
                        }
                    }
                } label: {
                    Label(L10n.Guest.uploadExcel, systemImage: "arrow.up.doc")
                }
                .disabled(isExcelBusy || isDeletingAll)

                Divider()

                Button(role: .destructive) {
                    showDeleteAllConfirm = true
                } label: {
                    Label(L10n.Guest.deleteAll(segment.title), systemImage: "trash")
                }
                .disabled(isExcelBusy || isDeletingAll || currentSegmentCount == 0)
            } label: {
                Group {
                    if isExcelBusy || isDeletingAll {
                        ProgressView()
                            .tint(AppTheme.iconOnChip)
                    } else {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppTheme.iconOnChip)
                    }
                }
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                }
                .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
            }
            .disabled(isExcelBusy || isDeletingAll)

            Button {
                dismissSearchKeyboard()
                runPremiumOrPaywall {
                    showAddSheet = true
                }
            } label: {
                Label(segment.addTitle, systemImage: "plus")
                    .font(AppFont.semibold(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.sage, AppTheme.brandGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: AppTheme.sageDark.opacity(0.16), radius: 10, y: 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(.plain)
        }
    }

    private var listHeader: some View {
        HStack {
            Text(L10n.Guest.listCount(segment.title, rows.count))
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.titleOnGlass)
            Spacer()
            Menu {
                ForEach(GuestSortOrder.allCases) { order in
                    Button {
                        sortOrder = order
                    } label: {
                        if sortOrder == order {
                            Label(order.label, systemImage: "checkmark")
                        } else {
                            Text(order.label)
                        }
                    }
                }
            } label: {
                Label(sortOrder.label, systemImage: "chevron.down")
                    .font(AppFont.medium(12))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(AppTheme.gold)
            }
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var guestListContent: some View {
        let sourceEmpty: Bool = {
            switch segment {
            case .guests: return guests.isEmpty
            case .vip: return vipGuests.isEmpty
            case .family: return familyMembers.isEmpty
            }
        }()

        if isLoading && sourceEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        } else if let errorMessage, sourceEmpty {
            MoreEmptyState(
                icon: "exclamationmark.triangle",
                title: L10n.Common.warning,
                message: errorMessage
            )
        } else if sourceEmpty {
            MoreEmptyState(
                icon: segment.listIcon,
                title: segment.emptyTitle,
                message: segment.emptySub
            )
        } else if rows.isEmpty {
            MoreEmptyState(
                icon: "magnifyingglass",
                title: L10n.Guest.noResults,
                message: L10n.Guest.searchPlaceholder
            )
        } else {
            LazyVStack(spacing: 10) {
                ForEach(displayedRows) { row in
                    GuestRow(
                        item: row,
                        iconName: segment.listIcon,
                        onOpenDetail: {
                            dismissSearchKeyboard()
                            runPremiumOrPaywall {
                                selectedDetail = row.target
                            }
                        },
                        onCall: {
                            dismissSearchKeyboard()
                            GuestContactLinker.open(GuestContactLinker.telURL(phone: row.phone ?? ""))
                        },
                        onEmail: {
                            dismissSearchKeyboard()
                            GuestContactLinker.open(GuestContactLinker.mailtoURL(email: row.email ?? ""))
                        }
                    )
                }

                if totalPages > 1 {
                    guestPaginationControls
                        .padding(.top, 8)
                }
            }
        }
    }

    private var guestPaginationControls: some View {
        VStack(spacing: 10) {
            Text(pageRangeLabel)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.5))

            HStack(spacing: 8) {
                pageNavButton(systemName: "chevron.left", disabled: currentPage <= 1) {
                    goToPage(currentPage - 1)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(1...totalPages, id: \.self) { page in
                            Button {
                                goToPage(page)
                            } label: {
                                Text("\(page)")
                                    .font(AppFont.semibold(13))
                                    .foregroundStyle(page == currentPage ? .white : AppTheme.iconOnChip)
                                    .frame(minWidth: 36, minHeight: 36)
                                    .background {
                                        if page == currentPage {
                                            Circle().fill(AppTheme.brandGradientEnd)
                                        } else {
                                            Circle()
                                                .fill(AppTheme.chipIdleFill)
                                                .background(.ultraThinMaterial, in: Circle())
                                        }
                                    }
                                    .overlay {
                                        Circle().stroke(
                                            page == currentPage ? Color.white.opacity(0.2) : AppTheme.iconChipStroke,
                                            lineWidth: 1
                                        )
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                }

                pageNavButton(systemName: "chevron.right", disabled: currentPage >= totalPages) {
                    goToPage(currentPage + 1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .premiumGlassCard(cornerRadius: 18)
        }
    }

    private func pageNavButton(systemName: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(disabled ? AppTheme.inkMuted(0.28) : AppTheme.iconOnChip)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                }
                .overlay {
                    Circle().stroke(AppTheme.iconChipStroke, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private var actionBar: some View {
        Button {
            dismissSearchKeyboard()
            runPremiumOrPaywall {
                showExportSheet = true
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.iconOnChip)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(AppTheme.iconChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle()
                            .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.Guest.exportData)
                        .font(AppFont.semibold(14))
                        .foregroundStyle(AppTheme.titleOnGlass)
                    Text(L10n.Guest.exportDataSub)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.inkMuted(0.55))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.inkMuted(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .premiumGlassCard(cornerRadius: 22)
        .padding(.top, 4)
    }

    private func dismissSearchKeyboard() {
        isSearchFocused = false
    }

    private func resetPagination() {
        currentPage = 1
    }

    private func goToPage(_ page: Int) {
        dismissSearchKeyboard()
        withAnimation(.easeInOut(duration: 0.2)) {
            currentPage = min(max(1, page), totalPages)
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let guestsEnvelope: Envelope<[Guest]> = APIClient.shared.request("guests")
            async let vipEnvelope: Envelope<[VipGuest]> = APIClient.shared.request("vip-guests")
            async let familyEnvelope: Envelope<[FamilyMember]> = APIClient.shared.request("family-members")

            guests = try await guestsEnvelope.data
            vipGuests = try await vipEnvelope.data
            familyMembers = try await familyEnvelope.data
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    private func loadPreview() {
        errorMessage = nil
        guests = [
            Guest(id: -1, no: 1, name: "Andi Pratama", phone: "081234567890", email: nil, tableNumber: "A1", rsvpStatus: "hadir", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
            Guest(id: -2, no: 2, name: "Siti Rahma", phone: "081298765432", email: nil, tableNumber: "A2", rsvpStatus: "menunggu", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
            Guest(id: -3, no: 3, name: "Budi Santoso", phone: nil, email: nil, tableNumber: "B1", rsvpStatus: "tidak_hadir", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
            Guest(id: -4, no: 4, name: "Dewi Lestari", phone: "081211122233", email: nil, tableNumber: "B2", rsvpStatus: "menunggu", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
            Guest(id: -5, no: 5, name: "Rizky Maulana", phone: nil, email: nil, tableNumber: "C1", rsvpStatus: "hadir", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
        ]
        vipGuests = [
            VipGuest(id: -11, no: 1, name: "Bapak Hendra Wijaya", jabatan: "Direktur", instansi: "PT Nusantara", phone: nil, kategori: "vip", rsvpStatus: "hadir", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
            VipGuest(id: -12, no: 2, name: "Ibu Ratna Sari", jabatan: "Kepala Dinas", instansi: nil, phone: nil, kategori: "pejabat", rsvpStatus: "menunggu", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil, catatan: nil),
        ]
        familyMembers = [
            FamilyMember(id: -21, no: 1, name: "Ayah Mempelai Wanita", role: "Orang tua", phone: nil, rsvpStatus: "hadir", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil),
            FamilyMember(id: -22, no: 2, name: "Ibu Mempelai Pria", role: "Orang tua", phone: nil, rsvpStatus: "hadir", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil),
            FamilyMember(id: -23, no: 3, name: "Kakak Mempelai", role: "Saudara", phone: nil, rsvpStatus: "menunggu", rsvpUpdatedByName: nil, rsvpUpdatedAt: nil),
        ]
        resetPagination()
    }

    private func downloadExcelTemplate() async {
        isExcelBusy = true
        defer { isExcelBusy = false }

        do {
            let downloaded = try await APIClient.shared.downloadFile(
                segment.excelTemplatePath,
                fallbackFileName: segment.excelTemplateFileName
            )
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(downloaded.fileName)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try downloaded.data.write(to: url, options: .atomic)
            templateShareItem = ExcelTemplateShareItem(url: url)
        } catch {
            guard !error.isRequestCancelled else { return }
            excelStatusTitle = L10n.Common.warning
            excelStatusMessage = error.userFacingMessage
            showExcelStatus = true
        }
    }

    private func importExcel(from url: URL) async {
        isExcelBusy = true
        defer { isExcelBusy = false }

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let maxBytes = 5 * 1024 * 1024
            if data.count > maxBytes {
                excelStatusTitle = L10n.Common.warning
                excelStatusMessage = L10n.Guest.excelFileTooLarge
                showExcelStatus = true
                return
            }

            let fileName = url.lastPathComponent.isEmpty ? "import.xlsx" : url.lastPathComponent
            let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
                ?? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

            let envelope: Envelope<GuestExcelImportResult> = try await APIClient.shared.uploadMultipart(
                segment.excelImportPath,
                fields: [:],
                fileFieldName: "spreadsheet",
                fileName: fileName,
                mimeType: mimeType,
                fileData: data
            )

            await load()

            excelStatusTitle = L10n.Guest.importDoneTitle
            var message = L10n.Guest.importDoneMessage(envelope.data.imported, envelope.data.skipped)
            if !envelope.data.errors.isEmpty {
                let preview = envelope.data.errors.prefix(3).joined(separator: "\n")
                message += "\n\(preview)"
            }
            excelStatusMessage = message
            showExcelStatus = true
        } catch {
            guard !error.isRequestCancelled else { return }
            excelStatusTitle = L10n.Common.warning
            excelStatusMessage = error.userFacingMessage
            showExcelStatus = true
        }
    }

    private func deleteAllInSegment() async {
        isDeletingAll = true
        defer { isDeletingAll = false }

        do {
            struct DeleteAllResult: Decodable {
                let deleted: Int
            }

            let envelope: Envelope<DeleteAllResult> = try await APIClient.shared.request(
                segment.deleteAllPath,
                method: "DELETE"
            )

            switch segment {
            case .guests:
                guests = []
            case .vip:
                vipGuests = []
            case .family:
                familyMembers = []
            }

            excelStatusTitle = L10n.Guest.deleteAllDoneTitle
            excelStatusMessage = L10n.Guest.deleteAllDoneMessage(segment.title, envelope.data.deleted)
            showExcelStatus = true
        } catch {
            guard !error.isRequestCancelled else { return }
            excelStatusTitle = L10n.Common.warning
            excelStatusMessage = error.userFacingMessage
            showExcelStatus = true
            await load()
        }
    }
}

enum GuestSortOrder: String, CaseIterable, Identifiable {
    case numberAsc
    case nameAsc
    case nameDesc

    var id: String { rawValue }

    var label: String {
        switch self {
        case .numberAsc: return L10n.Guest.sortNumberAsc
        case .nameAsc: return L10n.Guest.sortNameAsc
        case .nameDesc: return L10n.Guest.sortNameDesc
        }
    }
}

enum RsvpKind: CaseIterable, Hashable {
    case confirmed
    case pending
    case absent

    var label: String {
        switch self {
        case .confirmed: return L10n.Common.confirmed
        case .pending: return L10n.Common.pending
        case .absent: return L10n.Common.notAttending
        }
    }

    var apiValue: String {
        switch self {
        case .confirmed: return "hadir"
        case .pending: return "menunggu"
        case .absent: return "tidak_hadir"
        }
    }

    var color: Color {
        switch self {
        case .confirmed: return AppTheme.sageDark
        case .pending: return AppTheme.gold
        case .absent: return AppTheme.statusMuted
        }
    }

    var badgeBackground: Color {
        switch self {
        case .confirmed: return AppTheme.sage.opacity(0.16)
        case .pending: return AppTheme.gold.opacity(0.16)
        case .absent: return AppTheme.statusMuted.opacity(0.18)
        }
    }

    static func from(rsvp: String) -> RsvpKind {
        switch rsvp {
        case "hadir": return .confirmed
        case "tidak_hadir": return .absent
        default: return .pending
        }
    }
}

private struct GuestRowItem: Identifiable {
    let id: String
    let target: GuestDetailTarget
    let name: String
    let no: Int?
    let subtitle: String?
    let phone: String?
    let email: String?
    let hasPhone: Bool
    let hasEmail: Bool
    let kind: RsvpKind
    let badge: String?

    init(target: GuestDetailTarget) {
        self.target = target
        id = target.id
        name = target.name
        no = target.no
        kind = RsvpKind.from(rsvp: target.rsvpStatus)

        switch target {
        case .guest(let guest):
            phone = guest.phone
            email = guest.email
            if let table = guest.tableNumber, !table.isEmpty {
                subtitle = L10n.Guest.tableNumber(table)
            } else if let phone = guest.phone, !phone.isEmpty {
                subtitle = phone
            } else {
                subtitle = L10n.Guest.tabGuests
            }
            hasPhone = guest.phone?.isEmpty == false
            hasEmail = guest.email?.isEmpty == false
            badge = nil
        case .vip(let vip):
            phone = vip.phone
            email = nil
            let detail = vip.subtitleLine
            subtitle = detail.isEmpty ? vip.kategoriLabel : "\(vip.kategoriLabel) · \(detail)"
            hasPhone = vip.phone?.isEmpty == false
            hasEmail = false
            badge = vip.kategoriLabel
        case .family(let member):
            phone = member.phone
            email = nil
            subtitle = member.subtitleLine
            hasPhone = member.phone?.isEmpty == false
            hasEmail = false
            badge = member.role
        }
    }
}

private struct GuestRow: View {
    let item: GuestRowItem
    var iconName: String = "person.2.fill"
    let onOpenDetail: () -> Void
    let onCall: () -> Void
    let onEmail: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpenDetail) {
                HStack(spacing: 12) {
                    ZStack {
                        if let no = item.no {
                            Text("\(no)")
                                .font(AppFont.semibold(13))
                                .foregroundStyle(AppTheme.iconOnChip)
                        } else {
                            Image(systemName: iconName)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(AppTheme.iconOnChip)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(AppTheme.iconChipFill)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle()
                            .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(AppFont.semibold(14))
                            .foregroundStyle(AppTheme.titleOnGlass)
                            .lineLimit(1)

                        if let subtitle = item.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(AppFont.regular(11))
                                .foregroundStyle(AppTheme.inkMuted(0.45))
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 6)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 6) {
                if item.hasPhone {
                    contactButton(systemName: "phone", action: onCall)
                }
                if item.hasEmail {
                    contactButton(systemName: "envelope", action: onEmail)
                }
            }

            Button(action: onOpenDetail) {
                HStack(spacing: 6) {
                    Text(item.kind.label)
                        .font(AppFont.semibold(11))
                        .foregroundStyle(item.kind.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(item.kind.badgeBackground, in: Capsule())

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.inkMuted(0.28))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .premiumGlassCard(cornerRadius: 20)
    }

    private func contactButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 30, height: 30)
                .background {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(AppTheme.iconChipStroke, lineWidth: 1)
                }
        }
        .buttonStyle(.borderless)
    }
}

private struct DonutChart: View {
    let segments: [(value: Double, color: Color)]

    private var total: Double { segments.reduce(0) { $0 + $1.value } }
    private var hasData: Bool { total > 0 }

    var body: some View {
        ZStack {
            // Visible empty track so the ring never disappears on cream or dark glass.
            Circle()
                .stroke(AppTheme.donutTrack, lineWidth: 14)

            if hasData {
                ForEach(Array(cumulative.enumerated()), id: \.offset) { _, seg in
                    Circle()
                        .trim(from: seg.start, to: seg.end)
                        .stroke(seg.color, style: StrokeStyle(lineWidth: 14, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }

    private var cumulative: [(start: Double, end: Double, color: Color)] {
        let divisor = max(total, 0.0001)
        var running = 0.0
        var result: [(Double, Double, Color)] = []
        for seg in segments where seg.value > 0 {
            let start = running / divisor
            running += seg.value
            let end = running / divisor
            result.append((start, end, seg.color))
        }
        return result
    }
}

private struct ProgressBarLine: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(AppTheme.progressTrack)
                Capsule().fill(color)
                    .frame(width: max(0, min(1, progress)) * proxy.size.width)
            }
        }
    }
}

private struct AddGuestEntrySheet: View {
    @Environment(\.dismiss) private var dismiss

    let segment: GuestListSegment
    let nextSequenceNumber: Int
    let onSaved: () async -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var tableNumber = ""
    @State private var jabatan = ""
    @State private var instansi = ""
    @State private var kategori = "vip"
    @State private var role = ""
    @State private var catatan = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case phone
        case email
        case table
        case jabatan
        case instansi
        case role
        case catatan
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(segment.addTitle)
                                    .font(.system(size: 24, weight: .semibold, design: .serif))
                                    .foregroundStyle(AppTheme.sageDark)
                                Text(segment.title)
                                    .font(AppFont.regular(13))
                                    .foregroundStyle(AppTheme.ink.opacity(0.5))
                            }

                            sequenceRow

                            fieldGroup(L10n.Guest.name) {
                                TextField(L10n.Guest.name, text: $name)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.ink)
                                    .tint(AppTheme.sageDark)
                                    .textFieldStyle(.plain)
                                    .textContentType(.name)
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .phone }
                            }
                            .id(Field.name)

                            fieldGroup(L10n.Guest.phone) {
                                TextField(L10n.Guest.phone, text: $phone)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.ink)
                                    .tint(AppTheme.sageDark)
                                    .textFieldStyle(.plain)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .focused($focusedField, equals: .phone)
                            }
                            .id(Field.phone)

                            segmentFields

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(AppFont.regular(12))
                                    .foregroundStyle(AppTheme.peachDark)
                            }

                            Button {
                                Task { await save() }
                            } label: {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text(L10n.Common.save)
                                            .font(AppFont.semibold(16))
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    canSave ? AppTheme.sageDark : AppTheme.sageDark.opacity(0.4),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(!canSave)
                            .id("saveButton")
                        }
                        .padding(20)
                        .padding(.bottom, 36)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: focusedField) { _, field in
                        guard let field else { return }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            proxy.scrollTo(field, anchor: .center)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.ink.opacity(0.7))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.Common.done) {
                        focusedField = nil
                    }
                    .font(AppFont.semibold(15))
                    .foregroundStyle(AppTheme.sageDark)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var sequenceRow: some View {
        HStack {
            Text(L10n.Guest.sequenceNumber)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.6))
            Spacer()
            Text("\(nextSequenceNumber)")
                .font(AppFont.semibold(15))
                .foregroundStyle(AppTheme.sageDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.lightSage.opacity(0.55), in: Capsule())
        }
        .padding(16)
        .background(inputFieldBackground(cornerRadius: 16))
    }

    @ViewBuilder
    private var segmentFields: some View {
        switch segment {
        case .guests:
            fieldGroup(L10n.Guest.email) {
                TextField(L10n.Guest.email, text: $email)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .table }
            }
            .id(Field.email)

            fieldGroup(L10n.Guest.tableNumberField) {
                TextField(L10n.Guest.tableNumberField, text: $tableNumber)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .table)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .catatan }
            }
            .id(Field.table)

            fieldGroup(L10n.Guest.notes) {
                TextField(L10n.Guest.notes, text: $catatan, axis: .vertical)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .catatan)
            }
            .id(Field.catatan)

        case .vip:
            fieldGroup(L10n.Guest.position) {
                TextField(L10n.Guest.position, text: $jabatan)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .jabatan)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .instansi }
            }
            .id(Field.jabatan)

            fieldGroup(L10n.Guest.institution) {
                TextField(L10n.Guest.institution, text: $instansi)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .instansi)
            }
            .id(Field.instansi)

            fieldGroup(L10n.Guest.category) {
                Picker(L10n.Guest.category, selection: $kategori) {
                    ForEach(VipGuest.kategoriOptions, id: \.key) { option in
                        Text(option.labelKey.localized).tag(option.key)
                    }
                }
                .labelsHidden()
                .tint(AppTheme.sageDark)
            }

            fieldGroup(L10n.Guest.notes) {
                TextField(L10n.Guest.notes, text: $catatan, axis: .vertical)
                    .font(AppFont.regular(14))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .lineLimit(3 ... 6)
                    .focused($focusedField, equals: .catatan)
            }
            .id(Field.catatan)

        case .family:
            fieldGroup(L10n.Guest.familyRole) {
                TextField(L10n.Guest.familyRole, text: $role)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                    .tint(AppTheme.sageDark)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .role)
            }
            .id(Field.role)
        }
    }

    private func fieldGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.ink.opacity(0.6))

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(inputFieldBackground(cornerRadius: 16))
        }
    }

    private func inputFieldBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.surface.opacity(0.96))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
            }
            .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 8, y: 3)
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        do {
            switch segment {
            case .guests:
                var payload: [String: Any] = [
                    "name": trimmedName,
                    "no": nextSequenceNumber,
                ]
                if !phone.isEmpty { payload["phone"] = phone }
                if !email.isEmpty { payload["email"] = email }
                if !tableNumber.isEmpty { payload["table_number"] = tableNumber }
                if !catatan.isEmpty { payload["catatan"] = catatan }
                let _: Envelope<Guest> = try await APIClient.shared.request("guests", method: "POST", json: payload)

            case .vip:
                var payload: [String: Any] = [
                    "name": trimmedName,
                    "kategori": kategori,
                    "no": nextSequenceNumber,
                ]
                if !phone.isEmpty { payload["phone"] = phone }
                if !jabatan.isEmpty { payload["jabatan"] = jabatan }
                if !instansi.isEmpty { payload["instansi"] = instansi }
                if !catatan.isEmpty { payload["catatan"] = catatan }
                let _: Envelope<VipGuest> = try await APIClient.shared.request("vip-guests", method: "POST", json: payload)

            case .family:
                var payload: [String: Any] = [
                    "name": trimmedName,
                    "no": nextSequenceNumber,
                ]
                if !phone.isEmpty { payload["phone"] = phone }
                if !role.isEmpty { payload["role"] = role }
                let _: Envelope<FamilyMember> = try await APIClient.shared.request("family-members", method: "POST", json: payload)
            }

            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
