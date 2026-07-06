import SwiftUI

struct EventListView: View {
    @State private var events: [WeddingEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.jenisLabel ?? event.jenisAcara)
                            .font(AppFont.semibold(17))
                        if let tglAcara = event.tglAcara {
                            Text(tglAcara)
                                .font(AppFont.regular(15))
                                .foregroundStyle(.secondary)
                        }
                        if let lokasiAcara = event.lokasiAcara, !lokasiAcara.isEmpty {
                            Text(lokasiAcara)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    Task { await delete(at: indexSet) }
                }
            }
            .overlay {
                if isLoading && events.isEmpty {
                    ProgressView()
                } else if events.isEmpty {
                    ContentUnavailableView("Belum ada acara", systemImage: "calendar")
                }
            }
            .navigationTitle("Acara Pernikahan")
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
                AddEventView { await load() }
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let envelope: Envelope<[WeddingEvent]> = try await APIClient.shared.request("wedding-events")
            events = envelope.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete(at offsets: IndexSet) async {
        for index in offsets {
            let event = events[index]
            try? await APIClient.shared.requestNoContent("wedding-events/\(event.id)")
        }
        await load()
    }
}

private struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    let onSaved: () async -> Void

    @State private var jenisAcara = WeddingEvent.jenisOptions.first!
    @State private var tglAcara = Date()
    @State private var lokasiAcara = ""
    @State private var catatan = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }

                Picker("Jenis Acara", selection: $jenisAcara) {
                    ForEach(WeddingEvent.jenisOptions, id: \.self) { jenis in
                        Text(jenis.capitalized).tag(jenis)
                    }
                }

                DatePicker("Tanggal", selection: $tglAcara, displayedComponents: .date)
                TextField("Lokasi", text: $lokasiAcara)
                TextField("Catatan", text: $catatan)
            }
            .navigationTitle("Tambah Acara")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task { await save() }
                    }
                    .disabled(isLoading)
                }
            }
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        do {
            let _: Envelope<WeddingEvent> = try await APIClient.shared.request(
                "wedding-events",
                method: "POST",
                json: [
                    "jenis_acara": jenisAcara,
                    "tgl_acara": formatter.string(from: tglAcara),
                    "lokasi_acara": lokasiAcara,
                    "catatan": catatan,
                ]
            )
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
