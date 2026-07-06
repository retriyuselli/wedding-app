import SwiftUI

struct GuestListView: View {
    @State private var guests: [Guest] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                ForEach(guests) { guest in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(guest.name).font(AppFont.semibold(17))
                            Spacer()
                            Menu {
                                ForEach(Guest.rsvpOptions, id: \.self) { status in
                                    Button(statusLabel(status)) {
                                        Task { await updateRsvp(guest: guest, status: status) }
                                    }
                                }
                            } label: {
                                Text(statusLabel(guest.rsvpStatus))
                                    .font(AppFont.regular(12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(color(for: guest.rsvpStatus).opacity(0.15))
                                    .foregroundStyle(color(for: guest.rsvpStatus))
                                    .clipShape(Capsule())
                            }
                        }
                        if let phone = guest.phone, !phone.isEmpty {
                            Text(phone).font(AppFont.regular(13)).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    Task { await delete(at: indexSet) }
                }
            }
            .overlay {
                if isLoading && guests.isEmpty {
                    ProgressView()
                } else if guests.isEmpty {
                    ContentUnavailableView("Belum ada tamu", systemImage: "person.2")
                }
            }
            .navigationTitle("Tamu")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
            .sheet(isPresented: $showAddSheet) {
                AddGuestView { await load() }
            }
        }
    }

    private func statusLabel(_ status: String) -> String {
        switch status {
        case "hadir": return "Hadir"
        case "tidak_hadir": return "Tidak Hadir"
        default: return "Menunggu"
        }
    }

    private func color(for status: String) -> Color {
        switch status {
        case "hadir": return .green
        case "tidak_hadir": return .red
        default: return .orange
        }
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

    private func updateRsvp(guest: Guest, status: String) async {
        do {
            let _: Envelope<Guest> = try await APIClient.shared.request(
                "guests/\(guest.id)/rsvp",
                method: "PATCH",
                json: ["rsvp_status": status]
            )
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete(at offsets: IndexSet) async {
        for index in offsets {
            let guest = guests[index]
            try? await APIClient.shared.requestNoContent("guests/\(guest.id)")
        }
        await load()
    }
}

private struct AddGuestView: View {
    @Environment(\.dismiss) private var dismiss
    let onSaved: () async -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                TextField("Nama", text: $name)
                TextField("No. HP", text: $phone)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("Tambah Tamu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task { await save() }
                    }
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
                json: ["name": name, "phone": phone]
            )
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
