import SwiftUI

struct EditableScheduleEvent: Identifiable, Equatable {
    var id: Int
    var title: String
    var tglAcara: Date
    var waktuMulai: Date
    var jamSelesai: Date
    var location: String
    var estimasiTamu: String
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
        let eventDate = event.tglAcara.flatMap { DateFormatter.calendarDate(from: $0) }
            ?? WeddingEventTime.defaultEventDate(for: jenis, weddingDay: weddingDay)
        let location = event.lokasiAcara?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let guestText = event.estimasiTamu.map(String.init) ?? ""

        return EditableScheduleEvent(
            id: event.id,
            title: event.jenisLabel ?? WeddingEvent.label(for: event.jenisAcara),
            tglAcara: eventDate,
            waktuMulai: start,
            jamSelesai: end,
            location: location.isEmpty ? fallbackLocation : location,
            estimasiTamu: guestText,
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
    @State private var concept = L10n.WeddingEdit.conceptGarden
    @State private var note = ""
    @State private var scheduleEvents: [EditableScheduleEvent] = []
    @State private var deletedEventIds: Set<Int> = []
    @State private var eventPendingDelete: EditableScheduleEvent?
    @State private var showDeleteEventConfirmation = false
    @State private var isSaving = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var conceptOptions: [String] {
        L10n.WeddingEdit.conceptOptions + L10n.Onboarding.cultureOptions
    }
    private let noteLimit = 200

    init(onSaved: @escaping () -> Void = {}) {
        self.onSaved = onSaved
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(AppTheme.peachDark)
                            .padding(.horizontal, 4)
                    }

                    formSection(title: L10n.WeddingEdit.coupleSection, icon: "heart.fill") {
                        VStack(spacing: 10) {
                            fieldRow(icon: "person.fill", title: L10n.WeddingEdit.brideName) {
                                TextField(L10n.Couple.bridePlaceholder, text: $brideName)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.sageDark)
                                    .textContentType(.name)
                            }

                            fieldRow(icon: "person.fill", title: L10n.WeddingEdit.groomName) {
                                TextField(L10n.Couple.groomPlaceholder, text: $groomName)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.sageDark)
                                    .textContentType(.name)
                            }
                        }
                    }

                    formSection(title: L10n.WeddingEdit.happyDay, icon: "calendar") {
                        VStack(spacing: 10) {
                            fieldRow(icon: "calendar", title: L10n.WeddingEdit.weddingDate) {
                                DatePicker(
                                    "",
                                    selection: $weddingDate,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .tint(AppTheme.sageDark)
                                .environment(\.locale, Locale(identifier: "id_ID"))
                                .onChange(of: weddingDate) { _, newValue in
                                    syncMainEventDates(to: newValue)
                                }
                            }

                            fieldRow(icon: "clock", title: L10n.WeddingEdit.eventStart) {
                                DatePicker(
                                    "",
                                    selection: $startTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .tint(AppTheme.sageDark)
                            }

                            fieldRow(icon: "mappin.and.ellipse", title: L10n.WeddingEdit.eventLocation) {
                                TextField(L10n.WeddingEdit.eventLocationPlaceholder, text: $location, axis: .vertical)
                                    .font(AppFont.medium(15))
                                    .foregroundStyle(AppTheme.sageDark)
                                    .lineLimit(1 ... 3)
                            }
                        }
                    }

                    formSection(title: L10n.WeddingEdit.conceptSection, icon: "sparkles") {
                        fieldRow(icon: "leaf.fill", title: L10n.WeddingEdit.conceptPlaceholder) {
                            Picker("", selection: $concept) {
                                ForEach(conceptOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .labelsHidden()
                            .tint(AppTheme.sageDark)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label(L10n.WeddingEdit.scheduleSection, systemImage: "list.bullet.rectangle")
                                .font(AppFont.semibold(15))
                                .foregroundStyle(AppTheme.sageDark)

                            Spacer()

                            Text(L10n.WeddingEdit.eventCount(scheduleEvents.count))
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.ink.opacity(0.45))
                        }

                        if scheduleEvents.isEmpty {
                            Text(L10n.WeddingEdit.noEventsHint)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.ink.opacity(0.5))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .premiumGlassCard(cornerRadius: 20)
                        }

                        ForEach($scheduleEvents) { $event in
                            scheduleEventCard(event: $event) {
                                eventPendingDelete = event
                                showDeleteEventConfirmation = true
                            }
                        }

                        if canAddScheduleEvent {
                            Button {
                                addScheduleEvent()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(L10n.WeddingEdit.addEvent)
                                        .font(AppFont.semibold(14))
                                    Spacer()
                                }
                                .foregroundStyle(AppTheme.sageDark)
                                .padding(16)
                                .premiumGlassCard(cornerRadius: 18)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text(L10n.WeddingEdit.allTypesAdded)
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.ink.opacity(0.45))
                                .padding(.horizontal, 4)
                        }

                        Text(L10n.WeddingEdit.defaultDeleteHint)
                            .font(AppFont.regular(11))
                            .foregroundStyle(AppTheme.ink.opacity(0.42))
                            .padding(.horizontal, 4)
                    }

                    formSection(title: L10n.Common.notes, icon: "note.text") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField(L10n.WeddingEdit.notesPlaceholder, text: $note, axis: .vertical)
                                .font(AppFont.regular(14))
                                .foregroundStyle(AppTheme.sageDark)
                                .lineLimit(3 ... 6)
                                .onChange(of: note) { _, newValue in
                                    if newValue.count > noteLimit {
                                        note = String(newValue.prefix(noteLimit))
                                    }
                                }

                            Text("\(note.count)/\(noteLimit)")
                                .font(AppFont.regular(11))
                                .foregroundStyle(AppTheme.ink.opacity(0.4))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(14)
                        .background(fieldBackground)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { saveBar }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task { await load() }
        .confirmationDialog(
            L10n.WeddingEdit.deleteEventTitle,
            isPresented: $showDeleteEventConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.Common.delete, role: .destructive) {
                if let eventPendingDelete {
                    deleteScheduleEvent(eventPendingDelete.id)
                }
                eventPendingDelete = nil
            }
            Button(L10n.Common.cancel, role: .cancel) {
                eventPendingDelete = nil
            }
        } message: {
            if let eventPendingDelete {
                Text(L10n.WeddingEdit.deleteEventMessage(eventPendingDelete.title))
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.ink.opacity(0.72))
                    .frame(width: 42, height: 42)
                    .background {
                        Circle()
                            .fill(Color.white.opacity(0.78))
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.65), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 12, y: 6)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.WeddingEdit.title)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(L10n.WeddingEdit.subtitle)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)

            Button {
                save()
            } label: {
                Text(L10n.Common.save)
                    .font(AppFont.semibold(13))
                    .foregroundStyle(AppTheme.sageDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(Color.white.opacity(0.78))
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.65), lineWidth: 1)
                    }
                    .shadow(color: AppTheme.sageDark.opacity(0.08), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(isSaving || isLoading)
        }
    }

    private var saveBar: some View {
        Button {
            save()
        } label: {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(L10n.WeddingEdit.saveChanges)
                        .font(AppFont.semibold(16))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                (isSaving || isLoading ? AppTheme.sageDark.opacity(0.45) : AppTheme.sageDark),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSaving || isLoading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Sections

    private func formSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(AppFont.semibold(15))
                .foregroundStyle(AppTheme.sageDark)

            content()
                .padding(14)
                .premiumGlassCard(cornerRadius: 20)
        }
    }

    private func fieldRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.gold)
                Text(title)
                    .font(AppFont.medium(12))
                    .foregroundStyle(AppTheme.sageDark.opacity(0.75))
            }

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(fieldBackground)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.white.opacity(0.55))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            }
    }

    private func scheduleEventCard(
        event: Binding<EditableScheduleEvent>,
        onDelete: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: event.wrappedValue.iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 36, height: 36)
                    .background {
                        Circle()
                            .fill(Color.white.opacity(0.72))
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.55), lineWidth: 1)
                    }

                Text(event.wrappedValue.title)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.sageDark)

                Spacer(minLength: 0)
            }

            scheduleEventFields(event)

            Button(role: .destructive, action: onDelete) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                    Text(L10n.WeddingEdit.deleteEvent)
                        .font(AppFont.medium(13))
                }
                .foregroundStyle(AppTheme.peachDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.peachDark.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 22)
    }

    @ViewBuilder
    private func scheduleEventFields(_ event: Binding<EditableScheduleEvent>) -> some View {
        fieldRow(icon: "tag.fill", title: L10n.Events.jenis) {
            Picker(
                "",
                selection: Binding(
                    get: { event.wrappedValue.jenisAcara ?? "akad" },
                    set: { applyJenis($0, to: event) }
                )
            ) {
                ForEach(WeddingEvent.jenisOptions, id: \.self) { jenis in
                    Text(WeddingEvent.label(for: jenis)).tag(jenis)
                }
            }
            .labelsHidden()
            .tint(AppTheme.sageDark)
        }

        fieldRow(icon: "calendar", title: L10n.Common.date) {
            DatePicker("", selection: event.tglAcara, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(AppTheme.sageDark)
                .environment(\.locale, Locale(identifier: "id_ID"))
        }

        HStack(spacing: 10) {
            fieldRow(icon: "clock", title: L10n.WeddingEdit.eventStart) {
                DatePicker("", selection: event.waktuMulai, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(AppTheme.sageDark)
            }

            fieldRow(icon: "clock.fill", title: L10n.WeddingEdit.eventEnd) {
                DatePicker("", selection: event.jamSelesai, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(AppTheme.sageDark)
            }
        }

        fieldRow(icon: "mappin.and.ellipse", title: L10n.WeddingEdit.eventLocation) {
            TextField(L10n.WeddingEdit.eventLocationPlaceholder, text: event.location, axis: .vertical)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.sageDark)
                .lineLimit(1 ... 2)
        }

        fieldRow(icon: "person.3.fill", title: L10n.WeddingDetail.estimatedGuests) {
            TextField("0", text: event.estimasiTamu)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.sageDark)
                .keyboardType(.numberPad)
                .onChange(of: event.wrappedValue.estimasiTamu) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    if digits != newValue {
                        event.wrappedValue.estimasiTamu = digits
                    }
                }
        }
    }

    // MARK: - Logic

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

    private var canAddScheduleEvent: Bool {
        let used = Set(scheduleEvents.compactMap(\.jenisAcara))
        return WeddingEvent.jenisOptions.contains { !used.contains($0) }
    }

    private func addScheduleEvent() {
        let usedJenis = Set(scheduleEvents.compactMap(\.jenisAcara))
        guard let nextJenis = WeddingEvent.jenisOptions.first(where: { !usedJenis.contains($0) }) else {
            errorMessage = L10n.WeddingEdit.allTypesAdded
            return
        }

        let nextId = (scheduleEvents.map(\.id).min() ?? 0) - 1

        scheduleEvents.append(
            EditableScheduleEvent(
                id: nextId,
                title: WeddingEvent.label(for: nextJenis),
                tglAcara: WeddingEventTime.defaultEventDate(for: nextJenis, weddingDay: weddingDate),
                waktuMulai: WeddingEventTime.defaultStart(for: nextJenis),
                jamSelesai: WeddingEventTime.defaultEnd(for: nextJenis),
                location: location,
                estimasiTamu: "",
                iconName: WeddingDetailView.icon(for: nextJenis),
                jenisAcara: nextJenis
            )
        )
        errorMessage = nil
    }

    private func deleteScheduleEvent(_ id: Int) {
        if id > 0 {
            deletedEventIds.insert(id)
        }
        scheduleEvents.removeAll { $0.id == id }
    }

    private func eventsForSave() -> [EditableScheduleEvent] {
        // Keep each event's own date/time/location. "Hari Bahagia" fields are only
        // applied when the user explicitly changes that section (syncMainEventDates),
        // not overwritten again at save time.
        scheduleEvents
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

            let loadedBudaya = loadedInfo.budaya?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !loadedBudaya.isEmpty {
                concept = loadedBudaya
            }

            if let resepsi = loadedEvents.first(where: { $0.jenisAcara == "resepsi" }),
               let date = resepsi.tglAcara.flatMap({ DateFormatter.calendarDate(from: $0) }) {
                weddingDate = date
            } else if let akad = loadedEvents.first(where: { $0.jenisAcara == "akad" }),
                      let date = akad.tglAcara.flatMap({ DateFormatter.calendarDate(from: $0) }) {
                weddingDate = date
            } else if let date = loadedEvents.compactMap({ $0.tglAcara.flatMap { DateFormatter.calendarDate(from: $0) } }).sorted().last {
                weddingDate = date
            }

            if let loc = loadedEvents.compactMap(\.lokasiAcara).first(where: { !$0.isEmpty }) {
                location = loc
            }

            if let catatan = loadedEvents.compactMap(\.catatan).first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                note = catatan
            }

            if let resepsi = loadedEvents.first(where: { $0.jenisAcara == "resepsi" }),
               let waktu = WeddingEventTime.date(from: resepsi.waktuMulai) {
                startTime = waktu
            } else if let akad = loadedEvents.first(where: { $0.jenisAcara == "akad" }),
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
        var payload: [String: Any] = [
            "jenis_acara": resolvedJenisAcara(for: event),
            "sort_order": sortOrder,
            "tgl_acara": DateFormatter.apiDateString(from: event.tglAcara),
            "waktu_mulai": WeddingEventTime.apiString(from: event.waktuMulai),
            "jam_selesai": WeddingEventTime.apiString(from: event.jamSelesai),
            "lokasi_acara": event.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? location
                : event.location,
            "catatan": note,
        ]

        let guestDigits = event.estimasiTamu.filter(\.isNumber)
        if let guestCount = Int(guestDigits), guestCount > 0 {
            payload["estimasi_tamu"] = guestCount
        }

        return payload
    }

    @MainActor
    private func save() {
        isSaving = true
        errorMessage = nil

        Task { @MainActor in
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

                // Create new events first so a failure there is clearer and
                // updates to existing events still follow after.
                for (index, event) in itemsToSave.enumerated() where event.id <= 0 {
                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events",
                        method: "POST",
                        json: eventPayload(for: event, sortOrder: index + 1)
                    )
                }

                for (index, event) in itemsToSave.enumerated() where event.id > 0 && knownEventIds.contains(event.id) {
                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events/\(event.id)",
                        method: "PUT",
                        json: eventPayload(for: event, sortOrder: index + 1)
                    )
                }

                isSaving = false
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
