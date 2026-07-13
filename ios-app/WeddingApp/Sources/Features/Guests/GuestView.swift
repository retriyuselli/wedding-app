import SwiftUI
import UniformTypeIdentifiers

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
    @State private var segment: GuestListSegment = .guests
    @State private var guests: [Guest] = []
    @State private var vipGuests: [VipGuest] = []
    @State private var familyMembers: [FamilyMember] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false
    @State private var showExportSheet = false
    @State private var showExcelImporter = false
    @State private var isExcelBusy = false
    @State private var isDeletingAll = false
    @State private var showDeleteAllConfirm = false
    @State private var excelStatusTitle = ""
    @State private var excelStatusMessage: String?
    @State private var showExcelStatus = false
    @State private var templateShareURL: URL?
    @State private var showTemplateShare = false
    @State private var selectedDetail: GuestDetailTarget?
    @State private var selectedFilter: RsvpKind? = nil
    @State private var sortOrder: GuestSortOrder = .numberAsc
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var visibleCount = 10
    @State private var showComingSoon = false
    @State private var comingSoonTitle = ""

    private let pageSize = 10

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

    private var displayedRows: [GuestRowItem] {
        Array(rows.prefix(visibleCount))
    }

    private var hasMoreRows: Bool {
        visibleCount < rows.count
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
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task { await load() }
            .refreshable { await load() }
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
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
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
            .sheet(isPresented: $showTemplateShare) {
                if let templateShareURL {
                    NavigationStack {
                        VStack(spacing: 20) {
                            Image(systemName: "doc.richtext")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.sageDark)
                            Text(L10n.Guest.templateReady)
                                .font(AppFont.medium(16))
                                .foregroundStyle(AppTheme.ink)
                            Text(templateShareURL.lastPathComponent)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.ink.opacity(0.5))
                            ShareLink(item: templateShareURL) {
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
                                Button(L10n.Common.close) { showTemplateShare = false }
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
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
            .alert(L10n.Common.comingSoon, isPresented: $showComingSoon) {
                Button(L10n.Common.ok, role: .cancel) {}
            } message: {
                Text(L10n.Common.comingSoonMessage)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Guest.title)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Text(L10n.Guest.subtitle)
                    .font(.system(size: 12, weight: .regular, design: .serif))
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
                            .font(AppFont.medium(13))
                            .foregroundStyle(isSelected ? AppTheme.sageDark : AppTheme.ink.opacity(0.45))
                        Text("\(count)")
                            .font(AppFont.regular(11))
                            .foregroundStyle(isSelected ? AppTheme.gold : AppTheme.ink.opacity(0.35))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        isSelected ? AppTheme.surface : Color.clear,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? AppTheme.sage.opacity(0.18) : Color.clear, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppTheme.lightSage.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(icon: "person.2", tint: AppTheme.sageDark, label: L10n.Guest.totalGuests, value: totalGuests, sub: L10n.Guest.people, subTint: AppTheme.ink.opacity(0.4))
            statItem(icon: "checkmark.circle", tint: AppTheme.sageDark, label: L10n.Common.confirmed, value: confirmedGuests, sub: "\(percent(confirmedGuests))%", subTint: AppTheme.ink.opacity(0.4))
            statItem(icon: "hourglass", tint: AppTheme.gold, label: L10n.Common.pending, value: pendingGuests, sub: "\(percent(pendingGuests))%", subTint: AppTheme.gold)
            statItem(icon: "xmark.circle", tint: AppTheme.ink.opacity(0.45), label: L10n.Common.notAttending, value: absentGuests, sub: "\(percent(absentGuests))%", subTint: AppTheme.ink.opacity(0.4))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    private func statItem(icon: String, tint: Color, label: String, value: Int, sub: String, subTint: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(AppTheme.sage.opacity(0.10), in: Circle())

            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("\(value)")
                .font(AppFont.medium(21))
                .foregroundStyle(AppTheme.sageDark)

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
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.sageDark)
                Spacer()
                Text(segment.title)
                    .font(AppFont.regular(12))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 18) {
                DonutChart(
                    segments: [
                        (Double(confirmedGuests), AppTheme.sageDark),
                        (Double(pendingGuests), AppTheme.gold),
                        (Double(absentGuests), AppTheme.mist),
                    ]
                )
                .frame(width: 92, height: 92)

                VStack(spacing: 12) {
                    legendRow(color: AppTheme.sageDark, title: L10n.Common.confirmed, value: confirmedGuests, percent: percent(confirmedGuests))
                    legendRow(color: AppTheme.gold, title: L10n.Common.pending, value: pendingGuests, percent: percent(pendingGuests))
                    legendRow(color: AppTheme.mist, title: L10n.Common.notAttending, value: absentGuests, percent: percent(absentGuests))
                }
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    private func legendRow(color: Color, title: String, value: Int, percent: Int) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 8) {
                Circle().fill(color).frame(width: 9, height: 9)
                Text(title)
                    .font(AppFont.regular(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.7))
                Spacer()
                Text("\(value) (\(percent)%)")
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink.opacity(0.7))
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
        }
    }

    private func chip(title: String, kind: RsvpKind?) -> some View {
        let isSelected = selectedFilter == kind
        return Button {
            dismissSearchKeyboard()
            withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = kind }
        } label: {
            Text(title)
                .font(AppFont.medium(13))
                .foregroundStyle(isSelected ? .white : AppTheme.ink.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    isSelected ? AnyShapeStyle(AppTheme.sageDark) : AnyShapeStyle(AppTheme.lightSage),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                TextField(L10n.Guest.searchPlaceholder, text: $searchText)
                    .font(AppFont.regular(13))
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        dismissSearchKeyboard()
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.white.opacity(0.9), in: Capsule())
            .overlay { Capsule().stroke(AppTheme.sage.opacity(0.12), lineWidth: 1) }

            Menu {
                Button {
                    Task { await downloadExcelTemplate() }
                } label: {
                    Label(L10n.Guest.downloadTemplate, systemImage: "arrow.down.doc")
                }
                .disabled(isExcelBusy || isDeletingAll)

                Button {
                    showExcelImporter = true
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
                            .tint(AppTheme.sageDark)
                    } else {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.sageDark)
                    }
                }
                .frame(width: 42, height: 42)
                .background(AppTheme.lightSage, in: Circle())
            }
            .disabled(isExcelBusy || isDeletingAll)

            Button {
                dismissSearchKeyboard()
                showAddSheet = true
            } label: {
                Label(segment.addTitle, systemImage: "plus")
                    .font(AppFont.medium(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(AppTheme.sageDark, in: Capsule())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(.plain)
        }
    }

    private var listHeader: some View {
        HStack {
            Text(L10n.Guest.listCount(segment.title, rows.count))
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)
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
                    .font(AppFont.regular(12))
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
                            selectedDetail = row.target
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

                if hasMoreRows {
                    Button {
                        dismissSearchKeyboard()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            visibleCount = min(visibleCount + pageSize, rows.count)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(L10n.Guest.loadMore)
                                .font(AppFont.semibold(14))
                            Text(L10n.Guest.showingCount(displayedRows.count, rows.count))
                                .font(AppFont.regular(12))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(AppTheme.sageDark)
                        .background(AppTheme.lightSage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionItem(
                icon: "square.and.arrow.up",
                title: L10n.Guest.shareInvite,
                sub: L10n.Guest.shareInviteSub
            ) {
                dismissSearchKeyboard()
                comingSoonTitle = L10n.Guest.shareInvite
                showComingSoon = true
            }
            Divider().frame(height: 34)
            actionItem(
                icon: "qrcode.viewfinder",
                title: L10n.Guest.qrCheckIn,
                sub: L10n.Guest.qrCheckInSub
            ) {
                dismissSearchKeyboard()
                comingSoonTitle = L10n.Guest.qrCheckIn
                showComingSoon = true
            }
            Divider().frame(height: 34)
            actionItem(
                icon: "arrow.down.doc",
                title: L10n.Guest.exportData,
                sub: L10n.Guest.exportDataSub
            ) {
                dismissSearchKeyboard()
                showExportSheet = true
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.06), radius: 12, y: 6)
        .padding(.top, 4)
    }

    private func actionItem(
        icon: String,
        title: String,
        sub: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(AppTheme.sageDark)
                Text(title)
                    .font(AppFont.medium(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(sub)
                    .font(AppFont.regular(9))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func dismissSearchKeyboard() {
        isSearchFocused = false
    }

    private func resetPagination() {
        visibleCount = pageSize
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
            templateShareURL = url
            showTemplateShare = true
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
        case .absent: return AppTheme.ink.opacity(0.5)
        }
    }

    var badgeBackground: Color {
        switch self {
        case .confirmed: return AppTheme.sage.opacity(0.16)
        case .pending: return AppTheme.gold.opacity(0.16)
        case .absent: return AppTheme.mist.opacity(0.7)
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
                        Circle()
                            .fill(AppTheme.sage.opacity(0.12))
                            .frame(width: 44, height: 44)

                        if let no = item.no {
                            Text("\(no)")
                                .font(AppFont.medium(13))
                                .foregroundStyle(AppTheme.sageDark)
                        } else {
                            Image(systemName: iconName)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(AppTheme.sageDark)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.ink)
                            .lineLimit(1)

                        if let subtitle = item.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(AppFont.regular(11))
                                .foregroundStyle(AppTheme.ink.opacity(0.45))
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
                        .font(AppFont.medium(11))
                        .foregroundStyle(item.kind.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(item.kind.badgeBackground, in: Capsule())

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.28))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 5)
    }

    private func contactButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppTheme.sageDark.opacity(0.7))
                .frame(width: 30, height: 30)
                .background(AppTheme.sage.opacity(0.10), in: Circle())
        }
        .buttonStyle(.borderless)
    }
}

private struct DonutChart: View {
    let segments: [(value: Double, color: Color)]

    private var total: Double { max(segments.reduce(0) { $0 + $1.value }, 0.0001) }

    var body: some View {
        ZStack {
            Circle().stroke(AppTheme.mist.opacity(0.5), lineWidth: 14)

            ForEach(Array(cumulative.enumerated()), id: \.offset) { _, seg in
                Circle()
                    .trim(from: seg.start, to: seg.end)
                    .stroke(seg.color, style: StrokeStyle(lineWidth: 14, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    private var cumulative: [(start: Double, end: Double, color: Color)] {
        var running = 0.0
        var result: [(Double, Double, Color)] = []
        for seg in segments {
            let start = running / total
            running += seg.value
            let end = running / total
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
                Capsule().fill(AppTheme.mist.opacity(0.7))
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

    private enum Field {
        case name
        case phone
        case email
        case table
        case jabatan
        case instansi
        case role
        case catatan
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                Section {
                    HStack {
                        Text(L10n.Guest.sequenceNumber)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(nextSequenceNumber)")
                            .foregroundStyle(.secondary)
                    }

                    TextField(L10n.Guest.name, text: $name)
                        .focused($focusedField, equals: .name)
                    TextField(L10n.Guest.phone, text: $phone)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)

                    switch segment {
                    case .guests:
                        TextField(L10n.Guest.email, text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .email)
                        TextField(L10n.Guest.tableNumberField, text: $tableNumber)
                            .focused($focusedField, equals: .table)
                        TextField(L10n.Guest.notes, text: $catatan, axis: .vertical)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .catatan)
                    case .vip:
                        TextField(L10n.Guest.position, text: $jabatan)
                            .focused($focusedField, equals: .jabatan)
                        TextField(L10n.Guest.institution, text: $instansi)
                            .focused($focusedField, equals: .instansi)
                        Picker(L10n.Guest.category, selection: $kategori) {
                            ForEach(VipGuest.kategoriOptions, id: \.key) { option in
                                Text(option.labelKey.localized).tag(option.key)
                            }
                        }
                        TextField(L10n.Guest.notes, text: $catatan, axis: .vertical)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .catatan)
                    case .family:
                        TextField(L10n.Guest.familyRole, text: $role)
                            .focused($focusedField, equals: .role)
                    }
                }
            }
            .navigationTitle(segment.addTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) { Task { await save() } }
                        .disabled(isLoading || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

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
