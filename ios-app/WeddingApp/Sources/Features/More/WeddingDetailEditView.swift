import SwiftUI

struct EditableScheduleEvent: Identifiable, Equatable {
    var id: Int
    var title: String
    var tglAcara: Date
    var waktuMulai: Date
    var jamSelesai: Date
    var location: String
    var iconName: String
    var jenisAcara: String?

    var timeRangeDisplay: String {
        WeddingEventTime.timeRange(
            waktuMulai: WeddingEventTime.apiString(from: waktuMulai),
            jamSelesai: WeddingEventTime.apiString(from: jamSelesai),
            jenisAcara: jenisAcara ?? "akad"
        )
    }

    static func from(event: WeddingEvent, weddingDay: Date, fallbackLocation: String) -> EditableScheduleEvent {
        let jenis = event.jenisAcara
        let start = WeddingEventTime.date(from: event.waktuMulai) ?? WeddingEventTime.defaultStart(for: jenis)
        let end = WeddingEventTime.date(from: event.jamSelesai) ?? WeddingEventTime.defaultEnd(for: jenis)
        let eventDate = event.tglAcara.flatMap { DateFormatter.apiInput.date(from: $0) }
            ?? WeddingEventTime.defaultEventDate(for: jenis, weddingDay: weddingDay)

        return EditableScheduleEvent(
            id: event.id,
            title: event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara),
            tglAcara: eventDate,
            waktuMulai: start,
            jamSelesai: end,
            location: event.lokasiAcara ?? fallbackLocation,
            iconName: WeddingDetailView.icon(for: event.jenisAcara),
            jenisAcara: event.jenisAcara
        )
    }
}

struct WeddingDetailEditView: View {
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var events: [WeddingEvent] = []
    @State private var brideName = ""
    @State private var groomName = ""
    @State private var weddingDate = Calendar.current.date(from: DateComponents(year: 2027, month: 6, day: 23)) ?? Date()
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 10, minute: 0)) ?? Date()
    @State private var location = ""
    @State private var concept = "Garden Romantic"
    @State private var note = ""
    @State private var scheduleEvents: [EditableScheduleEvent] = []
    @State private var deletedEventIds: Set<Int> = []
    @State private var eventPendingDelete: EditableScheduleEvent?
    @State private var showDeleteEventConfirmation = false
    @State private var isSaving = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let conceptOptions = ["Garden Romantic", "Classic White", "Rustic Charm", "Modern Minimal"]
    private let noteLimit = 200

    init(onSaved: @escaping () -> Void = {}) {
        self.onSaved = onSaved
    }

    var body: some View {
        Form {
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(AppFont.regular(14))
                        .foregroundStyle(AppTheme.peachDark)
                }
            }

            Section {
                TextField("Nama Mempelai Wanita", text: $brideName)
                    .textContentType(.name)
                TextField("Nama Mempelai Pria", text: $groomName)
                    .textContentType(.name)
            } header: {
                Text("Pasangan")
            }

            Section {
                DatePicker(
                    "Tanggal Pernikahan (Akad)",
                    selection: $weddingDate,
                    displayedComponents: .date
                )
                .environment(\.locale, Locale(identifier: "id_ID"))
                .onChange(of: weddingDate) { _, newValue in
                    syncMainEventDates(to: newValue)
                }

                DatePicker(
                    "Waktu Mulai Utama",
                    selection: $startTime,
                    displayedComponents: .hourAndMinute
                )

                TextField("Lokasi Utama", text: $location, axis: .vertical)
                    .lineLimit(1 ... 3)
            } header: {
                Text("Tanggal & Lokasi")
            }

            Section {
                Picker("Konsep Pernikahan", selection: $concept) {
                    ForEach(conceptOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
            } header: {
                Text("Konsep")
            }

            Section {
                if scheduleEvents.isEmpty {
                    Text("Belum ada acara. Tambahkan acara pernikahan Anda.")
                        .font(AppFont.regular(14))
                        .foregroundStyle(AppTheme.ink.opacity(0.55))
                }
            } header: {
                Text("Rangkaian Acara")
            }

            ForEach(scheduleEvents.indices, id: \.self) { index in
                Section {
                    scheduleEventFields($scheduleEvents[index])

                    Button(role: .destructive) {
                        eventPendingDelete = scheduleEvents[index]
                        showDeleteEventConfirmation = true
                    } label: {
                        Label("Hapus Acara", systemImage: "trash")
                    }
                } header: {
                    Text(scheduleEvents[index].title)
                }
            }

            Section {
                Button {
                    addScheduleEvent()
                } label: {
                    Label("Tambah Acara", systemImage: "plus.circle.fill")
                }
            } footer: {
                Text("Acara default bisa dihapus. Ketuk Hapus Acara lalu Simpan perubahan.")
            }

            Section {
                TextField("Catatan penting untuk hari pernikahan...", text: $note, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .onChange(of: note) { _, newValue in
                        if newValue.count > noteLimit {
                            note = String(newValue.prefix(noteLimit))
                        }
                    }

                Text("\(note.count)/\(noteLimit)")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } header: {
                Text("Catatan")
            }

            Section {
                Button {
                    save()
                } label: {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Simpan Perubahan")
                                .font(AppFont.semibold(16))
                        }
                        Spacer()
                    }
                }
                .disabled(isSaving || isLoading)
            }
        }
        .navigationTitle("Edit Detail Pernikahan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.Common.save) {
                    save()
                }
                .disabled(isSaving || isLoading)
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task { await load() }
        .confirmationDialog(
            "Hapus acara ini?",
            isPresented: $showDeleteEventConfirmation,
            titleVisibility: .visible
        ) {
            Button("Hapus", role: .destructive) {
                if let eventPendingDelete {
                    deleteScheduleEvent(eventPendingDelete.id)
                }
                eventPendingDelete = nil
            }
            Button("Batal", role: .cancel) {
                eventPendingDelete = nil
            }
        } message: {
            if let eventPendingDelete {
                Text("\(eventPendingDelete.title) akan dihapus dari rangkaian acara setelah Anda menyimpan perubahan.")
            }
        }
    }

    @ViewBuilder
    private func scheduleEventFields(_ event: Binding<EditableScheduleEvent>) -> some View {
        Picker(
            "Jenis Acara",
            selection: Binding(
                get: { event.wrappedValue.jenisAcara ?? "akad" },
                set: { applyJenis($0, to: event) }
            )
        ) {
            ForEach(WeddingEvent.jenisOptions, id: \.self) { jenis in
                Text(WeddingEvent.label(for: jenis)).tag(jenis)
            }
        }

        DatePicker("Tanggal Acara", selection: event.tglAcara, displayedComponents: .date)
            .environment(\.locale, Locale(identifier: "id_ID"))

        DatePicker("Waktu Mulai", selection: event.waktuMulai, displayedComponents: .hourAndMinute)
        DatePicker("Waktu Selesai", selection: event.jamSelesai, displayedComponents: .hourAndMinute)

        TextField("Lokasi Acara", text: event.location, axis: .vertical)
            .lineLimit(1 ... 2)
    }

    private func applyJenis(_ jenis: String, to event: Binding<EditableScheduleEvent>) {
        event.wrappedValue.jenisAcara = jenis
        event.wrappedValue.title = WeddingEvent.label(for: jenis)
        event.wrappedValue.iconName = WeddingDetailView.icon(for: jenis)
        event.wrappedValue.tglAcara = WeddingEventTime.defaultEventDate(for: jenis, weddingDay: weddingDate)
        event.wrappedValue.waktuMulai = WeddingEventTime.defaultStart(for: jenis)
        event.wrappedValue.jamSelesai = WeddingEventTime.defaultEnd(for: jenis)
    }

    private func syncMainEventDates(to weddingDay: Date) {
        for index in scheduleEvents.indices {
            let jenis = scheduleEvents[index].jenisAcara ?? "akad"
            if jenis == "akad" || jenis == "resepsi" {
                scheduleEvents[index].tglAcara = weddingDay
            }
        }
    }

    private func addScheduleEvent() {
        let nextId = (scheduleEvents.map(\.id).min() ?? 0) - 1
        let usedJenis = Set(scheduleEvents.compactMap(\.jenisAcara))
        let nextJenis = WeddingEvent.jenisOptions.first { !usedJenis.contains($0) } ?? "resepsi"

        scheduleEvents.append(
            EditableScheduleEvent(
                id: nextId,
                title: WeddingEvent.label(for: nextJenis),
                tglAcara: WeddingEventTime.defaultEventDate(for: nextJenis, weddingDay: weddingDate),
                waktuMulai: WeddingEventTime.defaultStart(for: nextJenis),
                jamSelesai: WeddingEventTime.defaultEnd(for: nextJenis),
                location: location,
                iconName: WeddingDetailView.icon(for: nextJenis),
                jenisAcara: nextJenis
            )
        )
    }

    private func deleteScheduleEvent(_ id: Int) {
        if id > 0 {
            deletedEventIds.insert(id)
        }
        scheduleEvents.removeAll { $0.id == id }
    }

    private func eventsForSave() -> [EditableScheduleEvent] {
        var items = scheduleEvents

        if let index = items.firstIndex(where: { resolvedJenisAcara(for: $0) == "akad" }) {
            items[index].waktuMulai = startTime
            items[index].tglAcara = weddingDate
        } else if !items.isEmpty {
            items[0].waktuMulai = startTime
        }

        for index in items.indices where items[index].jenisAcara == "resepsi" {
            items[index].tglAcara = weddingDate
        }

        return items
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")

            let loadedInfo = try await infoEnvelope.data
            let loadedEvents = try await eventEnvelope.data
                .sorted { ($0.sortOrder ?? Int.max) < ($1.sortOrder ?? Int.max) }

            events = loadedEvents
            deletedEventIds = []
            brideName = loadedInfo.brideName ?? ""
            groomName = loadedInfo.groomName ?? ""
            concept = loadedInfo.budaya?.isEmpty == false ? (loadedInfo.budaya ?? "Garden Romantic") : "Garden Romantic"

            if let akad = loadedEvents.first(where: { $0.jenisAcara == "akad" }),
               let date = akad.tglAcara.flatMap({ DateFormatter.apiInput.date(from: $0) }) {
                weddingDate = date
            } else if let date = loadedEvents.compactMap({ $0.tglAcara.flatMap { DateFormatter.apiInput.date(from: $0) } }).sorted().last {
                weddingDate = date
            }

            if let loc = loadedEvents.compactMap(\.lokasiAcara).first(where: { !$0.isEmpty }) {
                location = loc
            }

            if let catatan = loadedEvents.compactMap(\.catatan).first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                note = catatan
            }

            if let akad = loadedEvents.first(where: { $0.jenisAcara == "akad" }),
               let waktu = WeddingEventTime.date(from: akad.waktuMulai) {
                startTime = waktu
            } else if let first = loadedEvents.first,
                      let waktu = WeddingEventTime.date(from: first.waktuMulai) {
                startTime = waktu
            }

            scheduleEvents = loadedEvents.isEmpty
                ? []
                : loadedEvents.map { EditableScheduleEvent.from(event: $0, weddingDay: weddingDate, fallbackLocation: location) }
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    private func resolvedJenisAcara(for event: EditableScheduleEvent) -> String {
        if let jenis = event.jenisAcara, WeddingEvent.jenisOptions.contains(jenis) {
            return jenis
        }

        let title = event.title.lowercased()
        if title.contains("lamaran") { return "lamaran" }
        if title.contains("pengajian") { return "pengajian" }
        if title.contains("akad") { return "akad" }
        if title.contains("resepsi") { return "resepsi" }

        return "akad"
    }

    private func eventPayload(for event: EditableScheduleEvent, sortOrder: Int) -> [String: Any] {
        [
            "jenis_acara": resolvedJenisAcara(for: event),
            "sort_order": sortOrder,
            "tgl_acara": DateFormatter.apiInput.string(from: event.tglAcara),
            "waktu_mulai": WeddingEventTime.apiString(from: event.waktuMulai),
            "jam_selesai": WeddingEventTime.apiString(from: event.jamSelesai),
            "lokasi_acara": event.location.isEmpty ? location : event.location,
            "catatan": note,
        ]
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

                let knownEventIds = Set(events.map(\.id))
                let itemsToSave = eventsForSave()

                for id in deletedEventIds where id > 0 {
                    try await APIClient.shared.requestNoContent("wedding-events/\(id)", method: "DELETE")
                }

                for (index, event) in itemsToSave.enumerated() where event.id > 0 && knownEventIds.contains(event.id) {
                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events/\(event.id)",
                        method: "PUT",
                        json: eventPayload(for: event, sortOrder: index + 1)
                    )
                }

                for (index, event) in itemsToSave.enumerated() where event.id <= 0 {
                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events",
                        method: "POST",
                        json: eventPayload(for: event, sortOrder: index + 1)
                    )
                }

                onSaved()
                dismiss()
            } catch {
                errorMessage = error.userFacingMessage
                isSaving = false
            }
        }
    }
}

enum WeddingDetailTab: CaseIterable, Identifiable {
    case ringkasan
    case jadwal
    case tamu

    var id: String { title }

    var title: String {
        switch self {
        case .ringkasan: return L10n.WeddingDetail.tabSummary
        case .jadwal: return L10n.WeddingDetail.tabSchedule
        case .tamu: return L10n.WeddingDetail.tabGuests
        }
    }
}
