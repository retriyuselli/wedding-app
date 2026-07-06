import SwiftUI

private struct WeddingScheduleItem: Identifiable {
    let id: Int
    let title: String
    let timeRange: String
    let location: String
    let iconName: String
}

struct WeddingDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var events: [WeddingEvent] = []
    @State private var guests: [Guest] = []
    @State private var selectedTab: WeddingDetailTab = .ringkasan
    @State private var showEdit = false
    @State private var isLoading = false

    private var coupleName: String {
        let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if bride.isEmpty && groom.isEmpty {
            return "Eliane & Jaeden"
        }
        if bride.isEmpty { return groom }
        if groom.isEmpty { return bride }
        return "\(bride) & \(groom)"
    }

    private var weddingDate: Date? {
        events.compactMap { $0.tglAcara.flatMap { DateFormatter.detailInput.date(from: $0) } }
            .sorted()
            .last
    }

    private var primaryLocation: String {
        events.compactMap(\.lokasiAcara).first { !$0.isEmpty } ?? "Lake Maceyhaven, Indonesia"
    }

    private var weddingConcept: String {
        let budaya = info.budaya?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return budaya.isEmpty ? "Garden Romantic" : budaya
    }

    private var weddingNote: String {
        let note = events.compactMap(\.catatan).first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return note ?? "Mohon konfirmasi ke semua vendor 1 minggu sebelum acara."
    }

    private var scheduleItems: [WeddingScheduleItem] {
        if events.isEmpty {
            return WeddingScheduleItem.fallback
        }

        return events.enumerated().map { index, event in
            WeddingScheduleItem(
                id: event.id,
                title: event.jenisLabel ?? event.jenisAcara.capitalized,
                timeRange: Self.timeRange(for: event),
                location: event.lokasiAcara ?? primaryLocation,
                iconName: Self.icon(for: event.jenisAcara)
            )
        }
    }

    private var confirmedGuests: Int {
        guests.filter { $0.rsvpStatus == "hadir" }.count
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    summaryCard
                    informasiSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await load() }
        .refreshable { await load() }
        .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
            Task { await load() }
        }
        .navigationDestination(isPresented: $showEdit) {
            WeddingDetailEditView {
                Task { await load() }
            }
        }
        .overlay {
            if isLoading && events.isEmpty && guests.isEmpty {
                ProgressView()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.8))
                }
                .buttonStyle(.plain)

                Spacer()

                Button { showEdit = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .medium))
                        Text("Edit")
                            .font(AppFont.medium(13))
                    }
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.86), in: Capsule())
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
            }

            Text("Detail Pernikahan")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text("Informasi lengkap rencana\npernikahan Anda.")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)
        }
        .padding(.top, 4)
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 14) {
                Image("CouplePortrait")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .overlay { Circle().stroke(AppTheme.gold.opacity(0.45), lineWidth: 1.2) }

                VStack(alignment: .leading, spacing: 6) {
                    Text(coupleName)
                        .font(AppFont.semibold(20))
                        .foregroundStyle(AppTheme.sageDark)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    Label(
                        weddingDate.map { DateFormatter.detailDisplay.string(from: $0) } ?? "23 Juni 2027",
                        systemImage: "calendar"
                    )
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))

                    Label(primaryLocation, systemImage: "mappin")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.5))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            Image("FloralHeader")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .clipped()
                .opacity(0.35)
                .mask {
                    LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .allowsHitTesting(false)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 16, y: 8)
    }

    // MARK: - Informasi Acara

    private var informasiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informasi Acara")
                .font(AppFont.semibold(18))
                .foregroundStyle(AppTheme.sageDark)

            tabSelector

            switch selectedTab {
            case .ringkasan:
                ringkasanContent
            case .jadwal:
                jadwalContent
            case .tamu:
                tamuContent
            }
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(WeddingDetailTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(AppFont.medium(12))
                        .foregroundStyle(selectedTab == tab ? .white : AppTheme.ink.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedTab == tab ? AppTheme.sageDark : AppTheme.surface,
                            in: Capsule()
                        )
                        .overlay {
                            if selectedTab != tab {
                                Capsule()
                                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Ringkasan Tab

    private var ringkasanContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            ringkasanGrid

            conceptCard

            sectionBlock(title: "Rangkaian Acara") {
                VStack(spacing: 0) {
                    ForEach(scheduleItems) { item in
                        scheduleRow(item)
                        if item.id != scheduleItems.last?.id {
                            Divider().padding(.leading, 54)
                        }
                    }
                }
                .padding(.vertical, 4)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                }
            }

            sectionBlock(title: "Catatan") {
                noteRow
            }
        }
    }

    private var ringkasanGrid: some View {
        HStack(alignment: .top, spacing: 0) {
            summaryCell(
                icon: "calendar",
                label: "Tanggal",
                value: weddingDate.map { "\(DateFormatter.detailDisplay.string(from: $0)) (\(DateFormatter.detailWeekday.string(from: $0)))" } ?? "23 Juni 2027 (Rabu)"
            )
            summaryCell(
                icon: "clock",
                label: "Waktu",
                value: "10.00 WIB\ns/d Selesai"
            )
            summaryCell(
                icon: "mappin",
                label: "Lokasi",
                value: primaryLocation
            )
        }
        .padding(.vertical, 16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func summaryCell(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.lightSage, in: Circle())

            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))

            Text(value)
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 6)
    }

    private var conceptCard: some View {
        Button {} label: {
            HStack(spacing: 12) {
                Image(systemName: "heart")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.lightSage, in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Konsep Pernikahan")
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                    Text(weddingConcept)
                        .font(AppFont.semibold(15))
                        .foregroundStyle(AppTheme.sageDark)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.28))
            }
            .padding(16)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func scheduleRow(_ item: WeddingScheduleItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 38, height: 38)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.ink)
                Text(item.timeRange)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                Text(item.location)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var noteRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 38, height: 38)
                .background(AppTheme.lightSage, in: Circle())

            Text(weddingNote)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.ink.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.ink.opacity(0.28))
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    // MARK: - Jadwal Tab

    private var jadwalContent: some View {
        VStack(spacing: 12) {
            ForEach(scheduleItems) { item in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: item.iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.sageDark, in: Circle())

                        Text(item.title)
                            .font(AppFont.semibold(16))
                            .foregroundStyle(AppTheme.sageDark)

                        Spacer()
                    }

                    infoLine(icon: "clock", text: item.timeRange)
                    infoLine(icon: "mappin", text: item.location)
                }
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                }
            }
        }
    }

    // MARK: - Tamu Tab

    private var tamuContent: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                guestStat(value: "\(guests.count)", label: "Total Tamu")
                guestStat(value: "\(confirmedGuests)", label: "Konfirmasi")
                guestStat(value: "\(max(guests.count - confirmedGuests, 0))", label: "Pending")
            }
            .padding(.vertical, 16)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }

            if guests.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.2")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(AppTheme.ink.opacity(0.25))
                    Text("Belum ada data tamu")
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                    Text("Kelola tamu dari tab Guest.")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(guests.prefix(8)) { guest in
                        HStack {
                            Text(guest.name)
                                .font(AppFont.medium(14))
                                .foregroundStyle(AppTheme.ink)
                            Spacer()
                            Text(guest.rsvpStatus == "hadir" ? "Hadir" : guest.rsvpStatus == "tidak_hadir" ? "Tidak Hadir" : "Pending")
                                .font(AppFont.medium(11))
                                .foregroundStyle(guest.rsvpStatus == "hadir" ? AppTheme.sageDark : AppTheme.ink.opacity(0.45))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.lightSage, in: Capsule())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)

                        if guest.id != guests.prefix(8).last?.id {
                            Divider().padding(.leading, 14)
                        }
                    }
                }
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                }
            }
        }
    }

    private func guestStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.semibold(18))
                .foregroundStyle(AppTheme.sageDark)
            Text(label)
                .font(AppFont.regular(11))
                .foregroundStyle(AppTheme.ink.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func sectionBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.semibold(16))
                .foregroundStyle(AppTheme.sageDark)
            content()
        }
    }

    private func infoLine(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(AppFont.regular(12))
            .foregroundStyle(AppTheme.ink.opacity(0.55))
            .labelStyle(.titleAndIcon)
    }

    static func timeRange(for event: WeddingEvent) -> String {
        switch event.jenisAcara.lowercased() {
        case "akad": return "10.00 – 11.00 WIB"
        case "resepsi": return "11.30 – 15.00 WIB"
        case "lamaran": return "14.00 – 16.00 WIB"
        case "pengajian": return "09.00 – 11.00 WIB"
        default: return "Waktu belum diatur"
        }
    }

    static func icon(for jenis: String) -> String {
        switch jenis.lowercased() {
        case "akad": return "heart.circle"
        case "resepsi": return "fork.knife"
        case "lamaran": return "gift"
        case "pengajian": return "book.closed"
        default: return "music.note.list"
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")
            async let guestEnvelope: Envelope<[Guest]> = APIClient.shared.request("guests")

            info = try await infoEnvelope.data
            events = try await eventEnvelope.data
            guests = try await guestEnvelope.data
        } catch {
            // fallback sample data from mockup
        }
    }
}

private extension WeddingScheduleItem {
    static let fallback: [WeddingScheduleItem] = [
        WeddingScheduleItem(id: 1, title: "Akad Nikah", timeRange: "10.00 – 11.00 WIB", location: "Aula Utama", iconName: "heart.circle"),
        WeddingScheduleItem(id: 2, title: "Resepsi", timeRange: "11.30 – 15.00 WIB", location: "Ballroom", iconName: "fork.knife"),
        WeddingScheduleItem(id: 3, title: "Hiburan", timeRange: "15.30 – 17.30 WIB", location: "Area Outdoor", iconName: "music.note.list"),
    ]
}

private extension DateFormatter {
    static let detailInput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let detailDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    static let detailWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
}
