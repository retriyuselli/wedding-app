import SwiftUI

struct DataVisibilityView: View {
    @StateObject private var viewModel = DataVisibilityViewModel()
    @State private var showSuccess = false

    var body: some View {
        ZStack(alignment: .bottom) {
            LuxuryWeddingBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.dataVisibility,
                        subtitle: L10n.Privacy.dataVisibilitySub
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                        Button("Coba lagi") { Task { await viewModel.retry() } }
                    }

                    if viewModel.isLoading && viewModel.settings == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    } else if viewModel.settings != nil {
                        visibilityPicker("Profil", selection: Binding(
                            get: { viewModel.settings?.profileVisibility ?? "private" },
                            set: { viewModel.settings?.profileVisibility = $0 }
                        ), options: [("private", "Privat"), ("couple", "Pasangan"), ("public", "Publik")])

                        visibilityPicker("Detail pernikahan", selection: Binding(
                            get: { viewModel.settings?.weddingVisibility ?? "couple" },
                            set: { viewModel.settings?.weddingVisibility = $0 }
                        ), options: [("private", "Privat"), ("couple", "Pasangan"), ("vendors", "Vendor")])

                        visibilityPicker("Daftar tamu", selection: Binding(
                            get: { viewModel.settings?.guestListVisibility ?? "private" },
                            set: { viewModel.settings?.guestListVisibility = $0 }
                        ), options: [("private", "Privat"), ("couple", "Pasangan")])

                        visibilityPicker("Anggaran", selection: Binding(
                            get: { viewModel.settings?.budgetVisibility ?? "private" },
                            set: { viewModel.settings?.budgetVisibility = $0 }
                        ), options: [("private", "Privat"), ("couple", "Pasangan")])

                        Toggle("Tampilkan di direktori", isOn: Binding(
                            get: { viewModel.settings?.showInDirectory ?? false },
                            set: { viewModel.settings?.showInDirectory = $0 }
                        ))
                        .font(AppFont.medium(14))
                        .padding(14)
                        .premiumGlassCard(cornerRadius: 16)

                        Toggle("Izinkan vendor menghubungi", isOn: Binding(
                            get: { viewModel.settings?.allowVendorContact ?? true },
                            set: { viewModel.settings?.allowVendorContact = $0 }
                        ))
                        .font(AppFont.medium(14))
                        .padding(14)
                        .premiumGlassCard(cornerRadius: 16)

                        Color.clear.frame(height: 80)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }

            Button {
                Task {
                    await viewModel.save()
                    if viewModel.successMessage != nil { showSuccess = true }
                }
            } label: {
                Text(viewModel.isSaving ? "Menyimpan…" : L10n.Common.save)
                    .font(AppFont.medium(15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
            }
            .disabled(viewModel.isSaving || viewModel.settings == nil)
            .padding(20)
        }
        .statusBarBlur()
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .alert("Berhasil", isPresented: $showSuccess) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }

    private func visibilityPicker(
        _ title: String,
        selection: Binding<String>,
        options: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(AppFont.medium(13)).foregroundStyle(AppTheme.ink.opacity(0.6))
            Picker(title, selection: selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }
}
