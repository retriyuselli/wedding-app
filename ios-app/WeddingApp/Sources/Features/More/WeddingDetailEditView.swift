import SwiftUI

struct EditableScheduleEvent: Identifiable, Equatable {
    var id: Int
    var title: String
    var timeRange: String
    var location: String
    var iconName: String
    var jenisAcara: String?

    static let fallback: [EditableScheduleEvent] = [
        EditableScheduleEvent(id: 1, title: "Akad Nikah", timeRange: "10.00 – 11.00 WIB", location: "Aula Utama", iconName: "heart.circle", jenisAcara: "akad"),
        EditableScheduleEvent(id: 2, title: "Resepsi", timeRange: "11.30 – 15.00 WIB", location: "Ballroom", iconName: "fork.knife", jenisAcara: "resepsi"),
        EditableScheduleEvent(id: 3, title: "Hiburan", timeRange: "15.30 – 17.30 WIB", location: "Area Outdoor", iconName: "music.note.list", jenisAcara: nil),
    ]
}

struct WeddingDetailEditView: View {
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var events: [WeddingEvent] = []
    @State private var brideName: String = ""
    @State private var groomName: String = ""
    @State private var weddingDate: Date = Calendar.current.date(from: DateComponents(year: 2027, month: 6, day: 23)) ?? Date()
    @State private var startTime: Date = Calendar.current.date(from: DateComponents(hour: 10, minute: 0)) ?? Date()
    @State private var location: String = "Lake Maceyhaven, Indonesia"
    @State private var concept: String = "Garden Romantic"
    @State private var note: String = "Mohon konfirmasi ke semua vendor 1 minggu sebelum acara."
    @State private var scheduleEvents: [EditableScheduleEvent] = EditableScheduleEvent.fallback
    @State private var selectedTab: WeddingDetailTab = .ringkasan
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let conceptOptions = ["Garden Romantic", "Classic White", "Rustic Charm", "Modern Minimal"]
    private let noteLimit = 200

    init(onSaved: @escaping () -> Void = {}) {
        self.onSaved = onSaved
    }

    private var coupleName: String {
        let bride = brideName.trimmingCharacters(in: .whitespacesAndNewlines)
        let groom = groomName.trimmingCharacters(in: .whitespacesAndNewlines)
        if bride.isEmpty && groom.isEmpty { return "Eliane & Jaeden" }
        if bride.isEmpty { return groom }
        if groom.isEmpty { return bride }
        return "\(bride) & \(groom)"
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    profileCard
                    informasiSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
        }
        .statusBarBlur()
        .safeAreaInset(edge: .bottom) { saveBar }
        .toolbar(.hidden, for: .navigationBar)
        .task { await load() }
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

                Button(action: save) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Simpan")
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.sageDark)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }

            Text("Edit Detail Pernikahan")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.sageDark)

            Text("Ubah informasi rencana\npernikahan Anda.")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .lineSpacing(2)

            if let errorMessage {
                Text(errorMessage)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.peachDark)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    Image("CouplePortrait")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                        .overlay { Circle().stroke(AppTheme.gold.opacity(0.45), lineWidth: 1.2) }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(coupleName)
                            .font(AppFont.semibold(20))
                            .foregroundStyle(AppTheme.sageDark)
                            .lineLimit(2)

                        TextField("Nama mempelai wanita", text: $brideName)
                            .font(AppFont.regular(12))
                        TextField("Nama mempelai pria", text: $groomName)
                            .font(AppFont.regular(12))
                    }
                }

                editFieldRow(icon: "calendar", title: "Tanggal Pernikahan") {
                    DatePicker("", selection: $weddingDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "id_ID"))
                }

                editFieldRow(icon: "mappin", title: "Lokasi") {
                    TextField("Lokasi acara", text: $location)
                        .font(AppFont.regular(13))
                }
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

    private func editFieldRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(AppFont.medium(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))

            content()
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppTheme.lightSage.opacity(0.45), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
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
                ringkasanForm
            case .jadwal:
                jadwalPreview
            case .tamu:
                tamuPreview
            }
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(WeddingDetailTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(AppFont.medium(12))
                        .foregroundStyle(selectedTab == tab ? .white : AppTheme.ink.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? AppTheme.sageDark : AppTheme.surface, in: Capsule())
                        .overlay {
                            if selectedTab != tab {
                                Capsule().stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var ringkasanForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 0) {
                editSummaryCell(icon: "calendar", label: "Tanggal", hint: "Pilih tanggal pernikahan Anda") {
                    DatePicker("", selection: $weddingDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "id_ID"))
                }
                editSummaryCell(icon: "clock", label: "Waktu Mulai", hint: "Pilih waktu mulai acara utama") {
                    HStack {
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        Text("WIB")
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.45))
                    }
                }
                editSummaryCell(icon: "mappin", label: "Lokasi", hint: "Pilih lokasi acara utama") {
                    TextField("Lokasi", text: $location)
                        .font(AppFont.regular(12))
                }
            }
            .padding(.vertical, 16)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }

            conceptPicker

            scheduleSection

            notesSection
        }
    }

    private func editSummaryCell<Content: View>(icon: String, label: String, hint: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.lightSage, in: Circle())

            Text(label)
                .font(AppFont.medium(11))
                .foregroundStyle(AppTheme.ink)

            Text(hint)
                .font(AppFont.regular(9))
                .foregroundStyle(AppTheme.ink.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(minHeight: 24)

            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }

    private var conceptPicker: some View {
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
                Text("Pilih tema atau konsep pernikahan Anda")
                    .font(AppFont.regular(10))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
            }

            Spacer()

            Menu {
                ForEach(conceptOptions, id: \.self) { option in
                    Button(option) { concept = option }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(concept)
                        .font(AppFont.medium(12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(AppTheme.sageDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.lightSage, in: Capsule())
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rangkaian Acara")
                        .font(AppFont.semibold(16))
                        .foregroundStyle(AppTheme.sageDark)
                    Text("Kelola urutan acara pada hari pernikahan Anda.")
                        .font(AppFont.regular(11))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                }

                Spacer()

                Button(action: addScheduleEvent) {
                    Label("Tambah Acara", systemImage: "plus")
                        .font(AppFont.medium(11))
                        .foregroundStyle(AppTheme.sageDark)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 0) {
                ForEach($scheduleEvents) { $event in
                    editableScheduleRow($event)
                    if event.id != scheduleEvents.last?.id {
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

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "hand.draw")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.sageDark)
                Text("Tips: Tekan dan tahan ikon titik di sebelah kiri untuk mengubah urutan acara.")
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
                    .lineSpacing(2)
            }
            .padding(14)
            .background(AppTheme.lightSage.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func editableScheduleRow(_ event: Binding<EditableScheduleEvent>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.ink.opacity(0.28))

            Image(systemName: event.wrappedValue.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 38, height: 38)
                .background(AppTheme.lightSage, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                TextField("Nama acara", text: event.title)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.ink)
                TextField("Waktu", text: event.timeRange)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                TextField("Lokasi", text: event.location)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Button {
                deleteScheduleEvent(event.wrappedValue.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.peachDark)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Catatan")
                .font(AppFont.semibold(16))
                .foregroundStyle(AppTheme.sageDark)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.sageDark)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.lightSage, in: Circle())

                VStack(alignment: .trailing, spacing: 6) {
                    TextField("Tulis catatan penting...", text: $note, axis: .vertical)
                        .font(AppFont.regular(13))
                        .lineLimit(3 ... 6)
                        .onChange(of: note) { _, newValue in
                            if newValue.count > noteLimit {
                                note = String(newValue.prefix(noteLimit))
                            }
                        }

                    Text("\(note.count)/\(noteLimit)")
                        .font(AppFont.regular(10))
                        .foregroundStyle(AppTheme.ink.opacity(0.35))
                }
            }
            .padding(14)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
            }
        }
    }

    private var jadwalPreview: some View {
        VStack(spacing: 12) {
            ForEach(scheduleEvents) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(AppFont.semibold(15))
                        .foregroundStyle(AppTheme.sageDark)
                    Label(item.timeRange, systemImage: "clock")
                    Label(item.location, systemImage: "mappin")
                }
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }

    private var tamuPreview: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(AppTheme.ink.opacity(0.25))
            Text("Kelola tamu dari tab Guest")
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.ink.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var saveBar: some View {
        Button(action: save) {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text("Simpan Perubahan")
                    .font(AppFont.medium(16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Actions

    private func addScheduleEvent() {
        let nextId = (scheduleEvents.map(\.id).min() ?? 0) - 1
        scheduleEvents.append(
            EditableScheduleEvent(
                id: nextId,
                title: "Acara Baru",
                timeRange: "Waktu belum diatur",
                location: location,
                iconName: "star",
                jenisAcara: nil
            )
        )
    }

    private func deleteScheduleEvent(_ id: Int) {
        scheduleEvents.removeAll { $0.id == id }
    }

    private func load() async {
        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")

            let loadedInfo = try await infoEnvelope.data
            let loadedEvents = try await eventEnvelope.data

            info = loadedInfo
            events = loadedEvents
            brideName = loadedInfo.brideName ?? ""
            groomName = loadedInfo.groomName ?? ""
            concept = loadedInfo.budaya?.isEmpty == false ? (loadedInfo.budaya ?? "Garden Romantic") : "Garden Romantic"

            if let date = loadedEvents.compactMap({ $0.tglAcara.flatMap { DateFormatter.detailInput.date(from: $0) } }).sorted().last {
                weddingDate = date
            }

            if let loc = loadedEvents.compactMap(\.lokasiAcara).first(where: { !$0.isEmpty }) {
                location = loc
            }

            if let catatan = loadedEvents.compactMap(\.catatan).first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                note = catatan
            }

            if !loadedEvents.isEmpty {
                scheduleEvents = loadedEvents.map { event in
                    EditableScheduleEvent(
                        id: event.id,
                        title: event.jenisLabel ?? event.jenisAcara.capitalized,
                        timeRange: WeddingDetailView.timeRange(for: event),
                        location: event.lokasiAcara ?? location,
                        iconName: WeddingDetailView.icon(for: event.jenisAcara),
                        jenisAcara: event.jenisAcara
                    )
                }
            }
        } catch {
            // keep defaults
        }
    }

    private func save() {
        isSaving = true
        errorMessage = nil

        Task {
            do {
                let _: Envelope<WeddingInfo> = try await APIClient.shared.request(
                    "wedding-info",
                    method: "PUT",
                    json: [
                        "groom_name": groomName,
                        "bride_name": brideName,
                        "budaya": concept,
                    ]
                )

                let dateString = DateFormatter.detailInput.string(from: weddingDate)

                for event in scheduleEvents where event.id > 0 {
                    var payload: [String: Any] = [
                        "tgl_acara": dateString,
                        "lokasi_acara": event.location.isEmpty ? location : event.location,
                        "catatan": note,
                    ]
                    if let jenis = event.jenisAcara {
                        payload["jenis_acara"] = jenis
                    }

                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events/\(event.id)",
                        method: "PUT",
                        json: payload
                    )
                }

                onSaved()
                dismiss()
            } catch {
                errorMessage = "Gagal menyimpan perubahan. Coba lagi."
                isSaving = false
            }
        }
    }
}

enum WeddingDetailTab: String, CaseIterable, Identifiable {
    case ringkasan = "Ringkasan"
    case jadwal = "Jadwal Acara"
    case tamu = "Tamu"

    var id: String { rawValue }
}

private extension DateFormatter {
    static let detailInput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
