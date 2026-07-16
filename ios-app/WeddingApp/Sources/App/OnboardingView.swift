import SwiftUI

private enum OnboardingEventKind: String, CaseIterable, Identifiable {
    case lamaran
    case pengajian
    case akad
    case resepsi

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lamaran: return L10n.Onboarding.eventLamaran
        case .pengajian: return L10n.Onboarding.eventPengajian
        case .akad: return L10n.Onboarding.eventAkad
        case .resepsi: return L10n.Onboarding.eventResepsi
        }
    }

    var iconName: String {
        switch self {
        case .lamaran: return "gift"
        case .pengajian: return "book.closed"
        case .akad: return "hands.sparkles"
        case .resepsi: return "party.popper"
        }
    }

    var sortOrder: Int {
        switch self {
        case .lamaran: return 1
        case .pengajian: return 2
        case .akad: return 3
        case .resepsi: return 4
        }
    }
}

struct OnboardingView: View {
    var onFinished: () -> Void

    private enum Field: Hashable {
        case bride
        case groom
        case budget
        case location(OnboardingEventKind)
        case guests(OnboardingEventKind)
    }

    @State private var step = 0
    @State private var brideName = ""
    @State private var groomName = ""
    @State private var selectedEvents: Set<OnboardingEventKind> = [.akad, .resepsi]
    @State private var eventDates: [OnboardingEventKind: Date] = [:]
    @State private var eventLocations: [OnboardingEventKind: String] = [:]
    @State private var eventGuests: [OnboardingEventKind: String] = [:]
    @State private var culture = ""
    @State private var estimatedBudget = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var appear = false
    @FocusState private var focusedField: Field?

    private var cultures: [String] { L10n.Onboarding.cultureOptions }
    private let totalSteps = 5

    private var canContinue: Bool {
        switch step {
        case 0:
            return !brideName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !groomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return !selectedEvents.isEmpty
        case 2:
            return orderedSelectedEvents.allSatisfy { kind in
                !(eventLocations[kind] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        case 3:
            return !culture.isEmpty
        default:
            return true
        }
    }

    private var primaryTitle: String {
        step >= totalSteps - 1 ? L10n.Onboarding.finish : L10n.Onboarding.next
    }

    private var orderedSelectedEvents: [OnboardingEventKind] {
        OnboardingEventKind.allCases.filter { selectedEvents.contains($0) }
    }

    /// Anchor all default dates to the akad day so events stay in a sensible timeline.
    private var akadAnchorDate: Date {
        if let akad = eventDates[.akad] {
            return Calendar.current.startOfDay(for: akad)
        }
        let base = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        return Calendar.current.startOfDay(for: base)
    }

    private func defaultDate(for kind: OnboardingEventKind) -> Date {
        let calendar = Calendar.current
        let akad = akadAnchorDate

        switch kind {
        case .akad, .resepsi:
            return akad
        case .pengajian:
            return calendar.date(byAdding: .day, value: -30, to: akad) ?? akad
        case .lamaran:
            return calendar.date(byAdding: .day, value: -60, to: akad) ?? akad
        }
    }

    private func dateBinding(for kind: OnboardingEventKind) -> Binding<Date> {
        Binding(
            get: { eventDates[kind] ?? defaultDate(for: kind) },
            set: { eventDates[kind] = Calendar.current.startOfDay(for: $0) }
        )
    }

    private func ensureEventDates() {
        for kind in selectedEvents where eventDates[kind] == nil {
            eventDates[kind] = defaultDate(for: kind)
        }
    }

    private func locationBinding(for kind: OnboardingEventKind) -> Binding<String> {
        Binding(
            get: { eventLocations[kind] ?? "" },
            set: { eventLocations[kind] = $0 }
        )
    }

    private func ensureEventLocations() {
        for kind in selectedEvents where eventLocations[kind] == nil {
            eventLocations[kind] = ""
        }
    }

    private func guestsBinding(for kind: OnboardingEventKind) -> Binding<String> {
        Binding(
            get: { eventGuests[kind] ?? "" },
            set: { eventGuests[kind] = $0 }
        )
    }

    private func ensureEventGuests() {
        for kind in selectedEvents where eventGuests[kind] == nil {
            eventGuests[kind] = ""
        }
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()
                .onTapGesture { dismissKeyboard() }

            VStack(spacing: 0) {
                progressHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                // Only mount the active step so off-screen TextFields can't keep the keyboard open.
                Group {
                    switch step {
                    case 0: namesStep
                    case 1: eventsStep
                    case 2: scheduleStep
                    case 3: cultureStep
                    default: extrasStep
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(step)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.22), value: step)

                if let errorMessage {
                    Text(errorMessage)
                        .font(AppFont.medium(13))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                bottomBar
            }
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { appear = true }
            ensureEventDates()
            ensureEventLocations()
            ensureEventGuests()
            dismissKeyboard()
        }
        .task {
            await loadExistingData()
        }
        .onChange(of: step) { _, newStep in
            if newStep == 2 || newStep == 4 {
                ensureEventDates()
                ensureEventLocations()
                ensureEventGuests()
            }
            dismissKeyboard()
        }
        .onChange(of: selectedEvents) { _, _ in
            ensureEventDates()
            ensureEventLocations()
            ensureEventGuests()
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L10n.Onboarding.stepLabel(step + 1, totalSteps))
                    .font(AppFont.semibold(12))
                    .foregroundStyle(AppTheme.gold)

                Spacer()

                if step > 0 {
                    Button(L10n.Onboarding.back) {
                        dismissKeyboard()
                        withAnimation { step -= 1 }
                    }
                    .font(AppFont.semibold(13))
                    .foregroundStyle(AppTheme.sageMuted(0.85))
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.progressTrack)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.sage, AppTheme.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * (CGFloat(step + 1) / CGFloat(totalSteps)))
                }
            }
            .frame(height: 6)
        }
        .opacity(appear ? 1 : 0)
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Button {
                Task { await handlePrimary() }
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(primaryTitle)
                        if step < totalSteps - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                }
                .font(AppFont.semibold(16))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: canContinue && !isSaving
                            ? [AppTheme.sage, AppTheme.brandGradientEnd]
                            : [AppTheme.sage.opacity(0.45), AppTheme.brandGradientEnd.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .shadow(color: AppTheme.sageDark.opacity(canContinue ? 0.18 : 0.06), radius: 14, y: 6)
            }
            .disabled(!canContinue || isSaving)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(
            LinearGradient(
                colors: [AppTheme.background.opacity(0), AppTheme.background.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var namesStep: some View {
        stepScaffold(
            eyebrow: L10n.Onboarding.namesEyebrow,
            title: L10n.Onboarding.namesTitle,
            subtitle: L10n.Onboarding.namesSubtitle,
            titleUsesSerif: false
        ) {
            VStack(spacing: 14) {
                onboardingField(
                    icon: "person.fill",
                    title: L10n.Onboarding.brideLabel,
                    placeholder: L10n.Onboarding.bridePlaceholder,
                    text: $brideName,
                    field: .bride
                )
                onboardingField(
                    icon: "person.fill",
                    title: L10n.Onboarding.groomLabel,
                    placeholder: L10n.Onboarding.groomPlaceholder,
                    text: $groomName,
                    field: .groom
                )
            }
        }
    }

    private var eventsStep: some View {
        stepScaffold(
            eyebrow: L10n.Onboarding.eventsEyebrow,
            title: L10n.Onboarding.eventsTitle,
            subtitle: L10n.Onboarding.eventsSubtitle,
            titleUsesSerif: false
        ) {
            VStack(spacing: 14) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(OnboardingEventKind.allCases) { event in
                        eventCard(event)
                    }
                }

                Text(L10n.Onboarding.eventsHint)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func eventCard(_ event: OnboardingEventKind) -> some View {
        let selected = selectedEvents.contains(event)

        return Button {
            dismissKeyboard()
            withAnimation(.easeInOut(duration: 0.2)) {
                if selected {
                    selectedEvents.remove(event)
                } else {
                    selectedEvents.insert(event)
                }
            }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(selected ? Color.white.opacity(0.22) : AppTheme.iconChipFill)
                        .frame(width: 52, height: 52)

                    Image(systemName: event.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(selected ? Color.white : AppTheme.iconOnChip)
                }

                Text(event.title)
                    .font(AppFont.semibold(15))
                    .foregroundStyle(selected ? Color.white : AppTheme.titleOnGlass)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .padding(.horizontal, 10)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.sage, AppTheme.brandGradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        selected ? Color.white.opacity(0.28) : AppTheme.iconChipStroke,
                        lineWidth: 1
                    )
            }
            .shadow(color: AppTheme.sageDark.opacity(selected ? 0.16 : 0.05), radius: selected ? 12 : 6, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var scheduleStep: some View {
        stepScaffold(
            eyebrow: L10n.Onboarding.dateEyebrow,
            title: L10n.Onboarding.dateTitle,
            subtitle: L10n.Onboarding.dateSubtitle,
            titleUsesSerif: false
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(orderedSelectedEvents) { kind in
                    eventScheduleCard(for: kind)
                }
            }
        }
    }

    private func eventScheduleCard(for kind: OnboardingEventKind) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                        .frame(width: 42, height: 42)

                    Image(systemName: kind.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.iconOnChip)
                }

                Text(kind.title)
                    .font(AppFont.semibold(16))
                    .foregroundStyle(AppTheme.titleOnGlass)

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Onboarding.dateForEvent)
                    .font(AppFont.semibold(12))
                    .foregroundStyle(AppTheme.sageMuted(0.85))

                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.gold)

                    DatePicker(
                        "",
                        selection: dateBinding(for: kind),
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(AppTheme.sage)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Onboarding.locationForEvent)
                    .font(AppFont.semibold(12))
                    .foregroundStyle(AppTheme.sageMuted(0.85))

                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.gold)
                        .frame(width: 22)

                    TextField(L10n.Onboarding.locationPlaceholder, text: locationBinding(for: kind))
                        .font(AppFont.medium(15))
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .location(kind))
                        .submitLabel(.done)
                        .onSubmit { dismissKeyboard() }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.nestedGlassFill)
                )
                .contentShape(Rectangle())
                .onTapGesture { focusedField = .location(kind) }
            }
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 22)
    }

    private var cultureStep: some View {
        stepScaffold(
            eyebrow: L10n.Onboarding.cultureEyebrow,
            title: L10n.Onboarding.cultureTitle,
            subtitle: L10n.Onboarding.cultureSubtitle,
            titleUsesSerif: false
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(cultures, id: \.self) { item in
                    let selected = culture == item
                    Button {
                        dismissKeyboard()
                        culture = item
                    } label: {
                        Text(item)
                            .font(AppFont.semibold(15))
                            .foregroundStyle(selected ? Color.white : AppTheme.titleOnGlass)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                if selected {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.sage, AppTheme.brandGradientEnd],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.nestedGlassFill)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selected ? Color.white.opacity(0.2) : AppTheme.iconChipStroke, lineWidth: 1)
                            }
                            .shadow(color: AppTheme.sageDark.opacity(selected ? 0.14 : 0.05), radius: selected ? 10 : 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var extrasStep: some View {
        stepScaffold(
            eyebrow: L10n.Onboarding.extrasEyebrow,
            title: L10n.Onboarding.extrasTitle,
            subtitle: L10n.Onboarding.extrasSubtitle,
            titleUsesSerif: true
        ) {
            VStack(spacing: 14) {
                ForEach(orderedSelectedEvents) { kind in
                    eventGuestsCard(for: kind)
                }

                onboardingField(
                    icon: "creditcard.fill",
                    title: L10n.Onboarding.budgetLabel,
                    placeholder: L10n.Onboarding.budgetPlaceholder,
                    text: $estimatedBudget,
                    keyboard: .numberPad,
                    field: .budget
                )
                .onChange(of: estimatedBudget) { _, newValue in
                    let formatted = CurrencyFormatter.formatAmountInput(newValue)
                    if formatted != newValue {
                        estimatedBudget = formatted
                    }
                }

                Text(L10n.Onboarding.extrasHint)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func eventGuestsCard(for kind: OnboardingEventKind) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppTheme.iconChipFill)
                        .frame(width: 36, height: 36)

                    Image(systemName: kind.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.iconOnChip)
                }

                Text(L10n.Onboarding.guestsForEvent(kind.title))
                    .font(AppFont.semibold(14))
                    .foregroundStyle(AppTheme.titleOnGlass)

                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 22)

                TextField(L10n.Onboarding.guestsPlaceholder, text: guestsBinding(for: kind))
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.titleOnGlass)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .guests(kind))
                    .onChange(of: eventGuests[kind] ?? "") { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue {
                            eventGuests[kind] = digits
                        }
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.nestedGlassFill)
            )
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .guests(kind) }
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 20)
    }

    private func stepScaffold<Content: View>(
        eyebrow: String,
        title: String,
        subtitle: String,
        titleUsesSerif: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow)
                        .font(AppFont.semibold(12))
                        .foregroundStyle(AppTheme.gold)
                        .tracking(0.4)

                    Text(title)
                        .font(titleUsesSerif
                              ? .system(size: 28, weight: .bold, design: .serif)
                              : AppFont.bold(28))
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(AppFont.regular(14))
                        .foregroundStyle(AppTheme.inkMuted(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }

                content()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 28)
            .environment(\.font, AppFont.regular(14))
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func onboardingField(
        icon: String,
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.semibold(13))
                .foregroundStyle(AppTheme.sageMuted(0.9))

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 22)

                TextField(placeholder, text: text)
                    .font(AppFont.medium(16))
                    .foregroundStyle(AppTheme.titleOnGlass)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(keyboard == .numberPad ? .never : .words)
                    .focused($focusedField, equals: field)
                    .submitLabel(.done)
                    .onSubmit { dismissKeyboard() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .premiumGlassCard(cornerRadius: 18)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = field
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    @MainActor
    private func loadExistingData() async {
        do {
            async let infoEnvelope: Envelope<WeddingInfo> = APIClient.shared.request("wedding-info")
            async let eventEnvelope: Envelope<[WeddingEvent]> = APIClient.shared.request("wedding-events")

            let info = try await infoEnvelope.data
            let loadedEvents = try await eventEnvelope.data

            if let bride = info.brideName?.trimmingCharacters(in: .whitespacesAndNewlines), !bride.isEmpty {
                brideName = bride
            }
            if let groom = info.groomName?.trimmingCharacters(in: .whitespacesAndNewlines), !groom.isEmpty {
                groomName = groom
            }
            if let budaya = info.budaya?.trimmingCharacters(in: .whitespacesAndNewlines), !budaya.isEmpty {
                culture = budaya
            }

            var loadedKinds: Set<OnboardingEventKind> = []
            for event in loadedEvents {
                guard let kind = OnboardingEventKind(rawValue: event.jenisAcara.lowercased()) else { continue }
                loadedKinds.insert(kind)

                if let raw = event.tglAcara, let date = DateFormatter.calendarDate(from: raw) {
                    eventDates[kind] = date
                }
                if let loc = event.lokasiAcara?.trimmingCharacters(in: .whitespacesAndNewlines), !loc.isEmpty {
                    eventLocations[kind] = loc
                }
                if let guests = event.estimasiTamu, guests > 0 {
                    eventGuests[kind] = String(guests)
                }
            }

            if !loadedKinds.isEmpty {
                selectedEvents = loadedKinds
            }
        } catch {
            // New user — keep local defaults.
        }
    }

    @MainActor
    private func handlePrimary() async {
        dismissKeyboard()

        if step < totalSteps - 1 {
            withAnimation { step += 1 }
            return
        }

        await saveAndFinish()
    }

    @MainActor
    private func saveAndFinish() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let bride = brideName.trimmingCharacters(in: .whitespacesAndNewlines)
        let groom = groomName.trimmingCharacters(in: .whitespacesAndNewlines)
        let kinds = orderedSelectedEvents

        do {
            let _: Envelope<WeddingInfo> = try await APIClient.shared.request(
                "wedding-info",
                method: "PUT",
                json: [
                    "bride_name": bride,
                    "groom_name": groom,
                    "budaya": culture,
                ]
            )

            let existing: Envelope<[WeddingEvent]> = try await APIClient.shared.request("wedding-events")
            let events = existing.data

            for kind in kinds {
                let jenis = kind.rawValue
                let date = eventDates[kind] ?? defaultDate(for: kind)
                let dateString = DateFormatter.apiDateString(from: date)
                let loc = (eventLocations[kind] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let guestDigits = (eventGuests[kind] ?? "").filter(\.isNumber)
                let guestCount = Int(guestDigits)

                var payload: [String: Any] = [
                    "jenis_acara": jenis,
                    "tgl_acara": dateString,
                    "lokasi_acara": loc,
                    "sort_order": kind.sortOrder,
                ]
                if let guestCount, guestCount > 0 {
                    payload["estimasi_tamu"] = guestCount
                }

                if let event = events.first(where: { $0.jenisAcara.lowercased() == jenis }) {
                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events/\(event.id)",
                        method: "PUT",
                        json: payload
                    )
                } else {
                    let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                        "wedding-events",
                        method: "POST",
                        json: payload
                    )
                }
            }

            // Remove default events the user did not choose during onboarding.
            let selectedJenis = Set(kinds.map(\.rawValue))
            for event in events where !selectedJenis.contains(event.jenisAcara.lowercased()) {
                try await APIClient.shared.requestNoContent("wedding-events/\(event.id)", method: "DELETE")
            }

            let budgetDigits = estimatedBudget.filter(\.isNumber)
            if let budgetValue = Double(budgetDigits), budgetValue > 0 {
                let _: Envelope<WeddingBudget> = try await APIClient.shared.request(
                    "wedding-budget",
                    method: "PUT",
                    json: [
                        "total_budget": budgetValue,
                        "currency": "IDR",
                        "notes": "Dari onboarding",
                    ]
                )
            }

            onFinished()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}

enum OnboardingGate {
    static func needsOnboarding(info: WeddingInfo?) -> Bool {
        let bride = info?.brideName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let groom = info?.groomName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return bride.isEmpty || groom.isEmpty
    }
}
