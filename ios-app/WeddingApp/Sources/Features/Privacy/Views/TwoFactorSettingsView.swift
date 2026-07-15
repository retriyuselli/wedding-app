import SwiftUI

struct TwoFactorSettingsView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = TwoFactorViewModel()
    @State private var showSuccess = false

    private var usesSocialLogin: Bool {
        session.currentUser?.hasSocialLogin ?? false
    }

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.twoFactor,
                        subtitle: L10n.Privacy.twoFactorSub
                    )

                    if viewModel.isLoading && viewModel.status == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                        Button("Coba lagi") { Task { await viewModel.retry() } }
                    }

                    statusCard

                    if viewModel.awaitingCode {
                        codeForm
                    } else if viewModel.isEnabled {
                        Button {
                            Task {
                                await viewModel.startDisable()
                                if viewModel.successMessage != nil { showSuccess = true }
                            }
                        } label: {
                            Text(viewModel.isBusy ? "Mengirim kode…" : "Nonaktifkan 2FA")
                                .font(AppFont.medium(15))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(.white)
                        }
                        .disabled(viewModel.isBusy)
                    } else {
                        Button {
                            Task {
                                await viewModel.startEnable()
                                if viewModel.successMessage != nil { showSuccess = true }
                            }
                        } label: {
                            Text(viewModel.isBusy ? "Mengirim kode…" : "Aktifkan 2FA via Email")
                                .font(AppFont.medium(15))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .foregroundStyle(.white)
                        }
                        .disabled(viewModel.isBusy)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
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

    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isEnabled ? L10n.Privacy.twoFactorActive : L10n.Privacy.twoFactorInactive)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.ink)
                Text(viewModel.status?.email ?? session.currentUser?.email ?? "")
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.ink.opacity(0.5))
            }
            Spacer()
            Image(systemName: viewModel.isEnabled ? "checkmark.shield.fill" : "shield")
                .foregroundStyle(AppTheme.sageDark)
        }
        .padding(16)
        .premiumGlassCard(cornerRadius: 18)
    }

    private var codeForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Kode 6 digit", text: $viewModel.code)
                .keyboardType(.numberPad)
                .font(AppFont.regular(16))
                .padding(14)
                .premiumGlassCard(cornerRadius: 16)

            if viewModel.disableMode && !usesSocialLogin {
                SecureField(L10n.DeleteAccount.passwordPlaceholder, text: $viewModel.password)
                    .font(AppFont.regular(14))
                    .padding(14)
                    .premiumGlassCard(cornerRadius: 16)
            }

            Button {
                Task {
                    if viewModel.disableMode {
                        await viewModel.confirmDisable()
                    } else {
                        await viewModel.confirmEnable()
                    }
                    if viewModel.successMessage != nil { showSuccess = true }
                }
            } label: {
                Text(viewModel.isBusy ? "Memverifikasi…" : "Konfirmasi kode")
                    .font(AppFont.medium(15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
            }
            .disabled(viewModel.code.count != 6 || viewModel.isBusy)
        }
    }
}
