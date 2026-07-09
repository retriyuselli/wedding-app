import SwiftUI

struct GuestView: View {
    @State private var guests: [Guest] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false
    @State private var selectedFilter: RsvpKind? = nil
    @State private var searchText = ""
    @State private var showComingSoon = false
    @State private var comingSoonTitle = ""

    private var rows: [GuestRowItem] {
        guests.map(GuestRowItem.init(guest:)).filter { row in
            let matchFilter = selectedFilter == nil || row.kind == selectedFilter
            let matchSearch = searchText.isEmpty
                || row.name.localizedCaseInsensitiveContains(searchText)
                || (row.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false)
            return matchFilter && matchSearch
        }
    }

    private var allRows: [GuestRowItem] {
        guests.map(GuestRowItem.init(guest:))
    }

    private var totalGuests: Int { allRows.reduce(0) { $0 + $1.count } }
    private var confirmedGuests: Int { allRows.filter { $0.kind == .confirmed }.reduce(0) { $0 + $1.count } }
    private var pendingGuests: Int { allRows.filter { $0.kind == .pending }.reduce(0) { $0 + $1.count } }
    private var absentGuests: Int { allRows.filter { $0.kind == .absent }.reduce(0) { $0 + $1.count } }

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
            }
            .statusBarBlur()
            .toolbar(.hidden, for: .navigationBar)
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
            .sheet(isPresented: $showAddSheet) {
                AddGuestSheet { await load() }
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
        .frame(height: 96, alignment: .top)
        .padding(.top, 8)
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
                Label(L10n.Common.seeDetail, systemImage: "chevron.right")
                    .font(AppFont.regular(12))
                    .labelStyle(.titleAndIcon)
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
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.white.opacity(0.9), in: Capsule())
            .overlay { Capsule().stroke(AppTheme.sage.opacity(0.12), lineWidth: 1) }

            Button {
                showAddSheet = true
            } label: {
                Label(L10n.Guest.addGuest, systemImage: "plus")
                    .font(AppFont.medium(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(AppTheme.sageDark, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var listHeader: some View {
        HStack {
            Text("guest.all_guests".localized(rows.reduce(0) { $0 + $1.count }))
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageDark)
            Spacer()
            Label(L10n.Guest.sortName, systemImage: "chevron.down")
                .font(AppFont.regular(12))
                .labelStyle(.titleAndIcon)
                .foregroundStyle(AppTheme.gold)
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var guestListContent: some View {
        if isLoading && guests.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        } else if let errorMessage, guests.isEmpty {
            MoreEmptyState(
                icon: "exclamationmark.triangle",
                title: L10n.Common.warning,
                message: errorMessage
            )
        } else if guests.isEmpty {
            MoreEmptyState(
                icon: "person.2",
                title: L10n.Guest.emptyTitle,
                message: L10n.Guest.emptySub
            )
        } else if rows.isEmpty {
            MoreEmptyState(
                icon: "magnifyingglass",
                title: L10n.Guest.noResults,
                message: L10n.Guest.searchPlaceholder
            )
        } else {
            LazyVStack(spacing: 10) {
                ForEach(rows) { row in
                    GuestRow(item: row)
                }
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionItem(icon: "square.and.arrow.up", title: "Bagikan Undangan", sub: "Kirim undangan digital")
            Divider().frame(height: 34)
            actionItem(icon: "qrcode.viewfinder", title: "QR Check-in", sub: "Scan saat datang")
            Divider().frame(height: 34)
            actionItem(icon: "arrow.down.doc", title: "Export Data", sub: "Unduh daftar tamu")
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

    private func actionItem(icon: String, title: String, sub: String) -> some View {
        Button {
            comingSoonTitle = title
            showComingSoon = true
        } label: {
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

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[Guest]> = try await APIClient.shared.request("guests")
            guests = envelope.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

enum RsvpKind {
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
    let id: Int
    let name: String
    let subtitle: String?
    let count: Int
    let hasPhone: Bool
    let hasEmail: Bool
    let kind: RsvpKind

    init(id: Int, name: String, subtitle: String?, count: Int, hasPhone: Bool, hasEmail: Bool, kind: RsvpKind) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.count = count
        self.hasPhone = hasPhone
        self.hasEmail = hasEmail
        self.kind = kind
    }

    init(guest: Guest) {
        self.id = guest.id
        self.name = guest.name
        self.subtitle = guest.phone?.isEmpty == false ? guest.phone : "Tamu"
        self.count = 1
        self.hasPhone = guest.phone?.isEmpty == false
        self.hasEmail = guest.email?.isEmpty == false
        self.kind = RsvpKind.from(rsvp: guest.rsvpStatus)
    }
}

private struct GuestRow: View {
    let item: GuestRowItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 44, height: 44)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(AppFont.medium(14))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }
                    if item.count > 1 {
                        HStack(spacing: 3) {
                            Image(systemName: "person.2")
                                .font(.system(size: 9))
                            Text("\(item.count)")
                                .font(AppFont.regular(11))
                        }
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }
                }
            }

            Spacer()

            HStack(spacing: 6) {
                if item.hasPhone {
                    contactIcon("phone")
                }
                if item.hasEmail {
                    contactIcon("envelope")
                }
            }

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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.05), radius: 10, y: 5)
    }

    private func contactIcon(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(AppTheme.sageDark.opacity(0.7))
            .frame(width: 30, height: 30)
            .background(AppTheme.sage.opacity(0.10), in: Circle())
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

private struct AddGuestSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSaved: () async -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
                TextField(L10n.Guest.name, text: $name)
                TextField(L10n.Guest.phone, text: $phone)
                    .keyboardType(.phonePad)
                TextField(L10n.Guest.email, text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            .navigationTitle(L10n.Guest.addGuest)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) { Task { await save() } }
                        .disabled(isLoading || name.isEmpty)
                }
            }
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let _: Envelope<Guest> = try await APIClient.shared.request(
                "guests",
                method: "POST",
                json: ["name": name, "phone": phone, "email": email]
            )
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
