import SwiftUI

enum GuestDetailTarget: Identifiable, Hashable {
    case guest(Guest)
    case vip(VipGuest)
    case family(FamilyMember)

    var id: String {
        switch self {
        case .guest(let guest): return "guest-\(guest.id)"
        case .vip(let vip): return "vip-\(vip.id)"
        case .family(let member): return "family-\(member.id)"
        }
    }

    var segment: GuestListSegment {
        switch self {
        case .guest: return .guests
        case .vip: return .vip
        case .family: return .family
        }
    }

    var resourceId: Int {
        switch self {
        case .guest(let guest): return guest.id
        case .vip(let vip): return vip.id
        case .family(let member): return member.id
        }
    }

    var name: String {
        switch self {
        case .guest(let guest): return guest.name
        case .vip(let vip): return vip.name
        case .family(let member): return member.name
        }
    }

    var no: Int? {
        switch self {
        case .guest(let guest): return guest.no
        case .vip(let vip): return vip.no
        case .family(let member): return member.no
        }
    }

    var phone: String? {
        switch self {
        case .guest(let guest): return guest.phone
        case .vip(let vip): return vip.phone
        case .family(let member): return member.phone
        }
    }

    var email: String? {
        switch self {
        case .guest(let guest): return guest.email
        case .vip, .family: return nil
        }
    }

    var rsvpStatus: String {
        switch self {
        case .guest(let guest): return guest.rsvpStatus
        case .vip(let vip): return vip.rsvpStatus
        case .family(let member): return member.rsvpStatus
        }
    }

    var rsvpUpdatedByName: String? {
        switch self {
        case .guest(let guest): return guest.rsvpUpdatedByName
        case .vip(let vip): return vip.rsvpUpdatedByName
        case .family(let member): return member.rsvpUpdatedByName
        }
    }

    var rsvpUpdatedAt: String? {
        switch self {
        case .guest(let guest): return guest.rsvpUpdatedAt
        case .vip(let vip): return vip.rsvpUpdatedAt
        case .family(let member): return member.rsvpUpdatedAt
        }
    }

    var apiBasePath: String {
        switch self {
        case .guest: return "guests"
        case .vip: return "vip-guests"
        case .family: return "family-members"
        }
    }
}

struct GuestDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let target: GuestDetailTarget
    let onChanged: () async -> Void

    @State private var current: GuestDetailTarget
    @State private var isUpdatingRsvp = false
    @State private var isDeleting = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    @State private var errorMessage: String?

    init(target: GuestDetailTarget, onChanged: @escaping () async -> Void) {
        self.target = target
        self.onChanged = onChanged
        _current = State(initialValue: target)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.regular(13))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                    }

                    profileCard
                    rsvpCard
                    detailsCard

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            if isDeleting {
                                ProgressView()
                            }
                            Text(L10n.Guest.deleteEntry)
                                .font(AppFont.medium(14))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isDeleting || isUpdatingRsvp)
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(L10n.Guest.detailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(L10n.Common.edit) { showEditSheet = true }
                        .disabled(isDeleting)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditGuestEntrySheet(target: current) { updated in
                    current = updated
                    await onChanged()
                }
            }
            .confirmationDialog(
                L10n.Guest.deleteConfirmTitle,
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(L10n.Common.delete, role: .destructive) {
                    Task { await deleteEntry() }
                }
                Button(L10n.Common.cancel, role: .cancel) {}
            } message: {
                Text(L10n.Guest.deleteConfirmMessage(current.name))
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 14) {
            Image(systemName: current.segment.listIcon)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 56, height: 56)
                .background(AppTheme.sage.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(current.name)
                    .font(AppFont.medium(18))
                    .foregroundStyle(AppTheme.ink)

                Text(current.segment.title)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
            }

            Spacer(minLength: 0)

            if current.phone?.isEmpty == false || current.email?.isEmpty == false {
                HStack(spacing: 8) {
                    if let phone = current.phone, !phone.isEmpty {
                        contactActionButton(systemName: "phone.fill") {
                            GuestContactLinker.open(GuestContactLinker.telURL(phone: phone))
                        }
                        contactActionButton(systemName: "message.fill") {
                            GuestContactLinker.open(GuestContactLinker.whatsAppURL(phone: phone))
                        }
                    }
                    if let email = current.email, !email.isEmpty {
                        contactActionButton(systemName: "envelope.fill") {
                            GuestContactLinker.open(GuestContactLinker.mailtoURL(email: email))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private func contactActionButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 40, height: 40)
                .background(AppTheme.sage.opacity(0.12), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var rsvpCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.Guest.rsvpStatus)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.sageDark)

            HStack(spacing: 8) {
                ForEach(RsvpKind.allCases, id: \.self) { kind in
                    let selected = RsvpKind.from(rsvp: current.rsvpStatus) == kind
                    Button {
                        Task { await updateRsvp(kind) }
                    } label: {
                        Text(kind.label)
                            .font(AppFont.medium(12))
                            .foregroundStyle(selected ? .white : kind.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selected ? AnyShapeStyle(kind.color) : AnyShapeStyle(kind.badgeBackground),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isUpdatingRsvp || isDeleting)
                }
            }

            if isUpdatingRsvp {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }

            if let meta = rsvpMetaText {
                Text(meta)
                    .font(AppFont.regular(11))
                    .foregroundStyle(AppTheme.ink.opacity(0.4))
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Guest.detailSection)
                .font(AppFont.medium(15))
                .foregroundStyle(AppTheme.sageDark)

            switch current {
            case .guest(let guest):
                detailRow(L10n.Guest.sequenceNumber, guest.no.map(String.init))
                tappableDetailRow(L10n.Guest.phone, guest.phone) {
                    GuestContactLinker.open(GuestContactLinker.telURL(phone: guest.phone ?? ""))
                }
                tappableDetailRow(L10n.Guest.email, guest.email) {
                    GuestContactLinker.open(GuestContactLinker.mailtoURL(email: guest.email ?? ""))
                }
                detailRow(L10n.Guest.tableNumberField, guest.tableNumber)
                detailRow(L10n.Guest.notes, guest.catatan)
            case .vip(let vip):
                detailRow(L10n.Guest.sequenceNumber, vip.no.map(String.init))
                tappableDetailRow(L10n.Guest.phone, vip.phone) {
                    GuestContactLinker.open(GuestContactLinker.telURL(phone: vip.phone ?? ""))
                }
                detailRow(L10n.Guest.position, vip.jabatan)
                detailRow(L10n.Guest.institution, vip.instansi)
                detailRow(L10n.Guest.category, vip.kategoriLabel)
                detailRow(L10n.Guest.notes, vip.catatan)
            case .family(let member):
                detailRow(L10n.Guest.sequenceNumber, member.no.map(String.init))
                tappableDetailRow(L10n.Guest.phone, member.phone) {
                    GuestContactLinker.open(GuestContactLinker.telURL(phone: member.phone ?? ""))
                }
                detailRow(L10n.Guest.familyRole, member.role)
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.sage.opacity(0.10), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func detailRow(_ label: String, _ value: String?) -> some View {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty {
            HStack(alignment: .top) {
                Text(label)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.45))
                    .frame(width: 100, alignment: .leading)
                Text(trimmed)
                    .font(AppFont.medium(13))
                    .foregroundStyle(AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func tappableDetailRow(_ label: String, _ value: String?, action: @escaping () -> Void) -> some View {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty {
            Button(action: action) {
                HStack(alignment: .top) {
                    Text(label)
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                        .frame(width: 100, alignment: .leading)
                    Text(trimmed)
                        .font(AppFont.medium(13))
                        .foregroundStyle(AppTheme.sageDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.sage.opacity(0.7))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var rsvpMetaText: String? {
        let by = current.rsvpUpdatedByName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let at = formattedRsvpDate(current.rsvpUpdatedAt)
        if let by, !by.isEmpty, let at {
            return L10n.Guest.rsvpUpdatedByAt(by, at)
        }
        if let by, !by.isEmpty {
            return L10n.Guest.rsvpUpdatedBy(by)
        }
        if let at {
            return L10n.Guest.rsvpUpdatedAt(at)
        }
        return nil
    }

    private func formattedRsvpDate(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }

        let fractional = DateFormatter()
        fractional.locale = Locale(identifier: "en_US_POSIX")
        fractional.timeZone = TimeZone(identifier: "UTC")
        fractional.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"

        let plain = DateFormatter()
        plain.locale = Locale(identifier: "en_US_POSIX")
        plain.timeZone = TimeZone(identifier: "UTC")
        plain.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        let date = fractional.date(from: raw)
            ?? plain.date(from: raw)
            ?? ISO8601DateFormatter().date(from: raw)

        guard let date else { return raw }

        let display = DateFormatter()
        display.locale = LocalizationManager.shared.locale
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }

    private func updateRsvp(_ kind: RsvpKind) async {
        guard RsvpKind.from(rsvp: current.rsvpStatus) != kind else { return }

        isUpdatingRsvp = true
        errorMessage = nil
        defer { isUpdatingRsvp = false }

        do {
            let path = "\(current.apiBasePath)/\(current.resourceId)/rsvp"
            let payload = ["rsvp_status": kind.apiValue]

            switch current {
            case .guest:
                let envelope: Envelope<Guest> = try await APIClient.shared.request(path, method: "PATCH", json: payload)
                current = .guest(envelope.data)
            case .vip:
                let envelope: Envelope<VipGuest> = try await APIClient.shared.request(path, method: "PATCH", json: payload)
                current = .vip(envelope.data)
            case .family:
                let envelope: Envelope<FamilyMember> = try await APIClient.shared.request(path, method: "PATCH", json: payload)
                current = .family(envelope.data)
            }

            await onChanged()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }

    private func deleteEntry() async {
        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }

        do {
            try await APIClient.shared.requestNoContent(
                "\(current.apiBasePath)/\(current.resourceId)",
                method: "DELETE"
            )
            await onChanged()
            dismiss()
        } catch {
            guard !error.isRequestCancelled else { return }
            errorMessage = error.userFacingMessage
        }
    }
}

private struct EditGuestEntrySheet: View {
    @Environment(\.dismiss) private var dismiss

    let target: GuestDetailTarget
    let onSaved: (GuestDetailTarget) async -> Void

    @State private var sequenceNumber: String
    @State private var name: String
    @State private var phone: String
    @State private var email: String
    @State private var tableNumber: String
    @State private var jabatan: String
    @State private var instansi: String
    @State private var kategori: String
    @State private var role: String
    @State private var catatan: String
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(target: GuestDetailTarget, onSaved: @escaping (GuestDetailTarget) async -> Void) {
        self.target = target
        self.onSaved = onSaved

        switch target {
        case .guest(let guest):
            _sequenceNumber = State(initialValue: guest.no.map(String.init) ?? "")
            _name = State(initialValue: guest.name)
            _phone = State(initialValue: guest.phone ?? "")
            _email = State(initialValue: guest.email ?? "")
            _tableNumber = State(initialValue: guest.tableNumber ?? "")
            _jabatan = State(initialValue: "")
            _instansi = State(initialValue: "")
            _kategori = State(initialValue: "vip")
            _role = State(initialValue: "")
            _catatan = State(initialValue: guest.catatan ?? "")
        case .vip(let vip):
            _sequenceNumber = State(initialValue: vip.no.map(String.init) ?? "")
            _name = State(initialValue: vip.name)
            _phone = State(initialValue: vip.phone ?? "")
            _email = State(initialValue: "")
            _tableNumber = State(initialValue: "")
            _jabatan = State(initialValue: vip.jabatan ?? "")
            _instansi = State(initialValue: vip.instansi ?? "")
            _kategori = State(initialValue: vip.kategori ?? "vip")
            _role = State(initialValue: "")
            _catatan = State(initialValue: vip.catatan ?? "")
        case .family(let member):
            _sequenceNumber = State(initialValue: member.no.map(String.init) ?? "")
            _name = State(initialValue: member.name)
            _phone = State(initialValue: member.phone ?? "")
            _email = State(initialValue: "")
            _tableNumber = State(initialValue: "")
            _jabatan = State(initialValue: "")
            _instansi = State(initialValue: "")
            _kategori = State(initialValue: "vip")
            _role = State(initialValue: member.role ?? "")
            _catatan = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                Section {
                    TextField(L10n.Guest.sequenceNumber, text: $sequenceNumber)
                        .keyboardType(.numberPad)
                    TextField(L10n.Guest.name, text: $name)
                    TextField(L10n.Guest.phone, text: $phone)
                        .keyboardType(.phonePad)

                    switch target.segment {
                    case .guests:
                        TextField(L10n.Guest.email, text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        TextField(L10n.Guest.tableNumberField, text: $tableNumber)
                        TextField(L10n.Guest.notes, text: $catatan, axis: .vertical)
                            .lineLimit(2...4)
                    case .vip:
                        TextField(L10n.Guest.position, text: $jabatan)
                        TextField(L10n.Guest.institution, text: $instansi)
                        Picker(L10n.Guest.category, selection: $kategori) {
                            ForEach(VipGuest.kategoriOptions, id: \.key) { option in
                                Text(option.labelKey.localized).tag(option.key)
                            }
                        }
                        TextField(L10n.Guest.notes, text: $catatan, axis: .vertical)
                            .lineLimit(2...4)
                    case .family:
                        TextField(L10n.Guest.familyRole, text: $role)
                    }
                }
            }
            .navigationTitle(L10n.Guest.editEntry)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.save) { Task { await save() } }
                        .disabled(isLoading || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let path = "\(target.apiBasePath)/\(target.resourceId)"
        let parsedNo = Int(sequenceNumber.trimmingCharacters(in: .whitespacesAndNewlines))

        do {
            let updated: GuestDetailTarget
            switch target.segment {
            case .guests:
                var payload: [String: Any] = [
                    "name": trimmedName,
                    "phone": phone.isEmpty ? NSNull() : phone,
                    "email": email.isEmpty ? NSNull() : email,
                    "table_number": tableNumber.isEmpty ? NSNull() : tableNumber,
                    "catatan": catatan.isEmpty ? NSNull() : catatan,
                ]
                payload["no"] = parsedNo.map { $0 as Any } ?? NSNull()
                let envelope: Envelope<Guest> = try await APIClient.shared.request(path, method: "PUT", json: payload)
                updated = .guest(envelope.data)

            case .vip:
                var payload: [String: Any] = [
                    "name": trimmedName,
                    "kategori": kategori,
                    "phone": phone.isEmpty ? NSNull() : phone,
                    "jabatan": jabatan.isEmpty ? NSNull() : jabatan,
                    "instansi": instansi.isEmpty ? NSNull() : instansi,
                    "catatan": catatan.isEmpty ? NSNull() : catatan,
                ]
                payload["no"] = parsedNo.map { $0 as Any } ?? NSNull()
                let envelope: Envelope<VipGuest> = try await APIClient.shared.request(path, method: "PUT", json: payload)
                updated = .vip(envelope.data)

            case .family:
                var payload: [String: Any] = [
                    "name": trimmedName,
                    "phone": phone.isEmpty ? NSNull() : phone,
                    "role": role.isEmpty ? NSNull() : role,
                ]
                payload["no"] = parsedNo.map { $0 as Any } ?? NSNull()
                let envelope: Envelope<FamilyMember> = try await APIClient.shared.request(path, method: "PUT", json: payload)
                updated = .family(envelope.data)
            }

            await onSaved(updated)
            dismiss()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
