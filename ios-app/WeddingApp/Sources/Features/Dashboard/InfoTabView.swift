import SwiftUI

struct InfoTabView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var info = WeddingInfo(id: nil, groomName: "", brideName: "", budaya: "", songlist: [])
    @State private var budget = WeddingBudget(id: nil, totalBudget: 0, currency: "IDR", notes: "")
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var savedMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }

                Section("Mempelai") {
                    TextField("Nama Pengantin Pria", text: Binding($info.groomName, replacingNilWith: ""))
                    TextField("Nama Pengantin Wanita", text: Binding($info.brideName, replacingNilWith: ""))
                    TextField("Budaya", text: Binding($info.budaya, replacingNilWith: ""))
                }

                Section("Budget") {
                    TextField("Total Budget", value: $budget.totalBudget, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Mata Uang", text: Binding($budget.currency, replacingNilWith: "IDR"))
                    TextField("Catatan", text: Binding($budget.notes, replacingNilWith: ""))
                }

                Section {
                    Button {
                        Task { await save() }
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Simpan")
                        }
                    }
                    .disabled(isLoading)

                    if let savedMessage {
                        Text(savedMessage).foregroundStyle(.green)
                    }
                }

                Section {
                    Button("Keluar", role: .destructive) {
                        Task { await session.logout() }
                    }
                }
            }
            .navigationTitle("Wedding Info")
            .task { await load() }
            .refreshable { await load() }
            .onReceive(NotificationCenter.default.publisher(for: .appDidBecomeActive)) { _ in
                Task { await load() }
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let infoEnvelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
            info = infoEnvelope.data

            let budgetEnvelope: Envelope<WeddingBudget> = try await APIClient.shared.request("wedding-budget")
            budget = budgetEnvelope.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() async {
        isLoading = true
        errorMessage = nil
        savedMessage = nil
        defer { isLoading = false }

        do {
            let infoEnvelope: Envelope<WeddingInfo> = try await APIClient.shared.request(
                "wedding-info",
                method: "PUT",
                json: [
                    "groom_name": info.groomName ?? "",
                    "bride_name": info.brideName ?? "",
                    "budaya": info.budaya ?? "",
                ]
            )
            info = infoEnvelope.data

            let budgetEnvelope: Envelope<WeddingBudget> = try await APIClient.shared.request(
                "wedding-budget",
                method: "PUT",
                json: [
                    "total_budget": budget.totalBudget,
                    "currency": budget.currency ?? "IDR",
                    "notes": budget.notes ?? "",
                ]
            )
            budget = budgetEnvelope.data
            savedMessage = "Tersimpan."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension Binding {
    init(_ source: Binding<String?>, replacingNilWith fallback: String) where Value == String {
        self.init(
            get: { source.wrappedValue ?? fallback },
            set: { source.wrappedValue = $0 }
        )
    }
}
