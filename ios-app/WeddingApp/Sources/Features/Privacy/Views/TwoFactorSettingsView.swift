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
            AppTheme.background
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.twoFactor,
                        subtitle: L10n.Privacy.twoFactorSub
                    )

                    if viewModel.isLoading && viewModel.status == nil {
                        ProgressView()
                            .tint(AppTheme.titleOnBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                        Button(L10n.Common.tryAgain) { Task { await viewModel.retry() } }
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
                            Text(viewModel.isBusy ? L10n.Privacy.twoFactorSendingCode : L10n.Privacy.twoFactorDisable)
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
                            Text(viewModel.isBusy ? L10n.Privacy.twoFactorSendingCode : L10n.Privacy.twoFactorEnable)
                                .font(AppFont.medium(15))
                                .foregroundStyle(AppTheme.primaryActionForeground(enabled: !viewModel.isBusy))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    AppTheme.primaryActionFill(enabled: !viewModel.isBusy),
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                )
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
        .alert(L10n.Common.success, isPresented: $showSuccess) {
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
        .premiumListRow(cornerRadius: 18)
    }

    private var codeForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(L10n.Privacy.twoFactorCodePlaceholder, text: $viewModel.code)
                .keyboardType(.numberPad)
                .font(AppFont.regular(16))
                .padding(14)
                .premiumListRow(cornerRadius: 16)

            if viewModel.disableMode && !usesSocialLogin {
                SecureField(L10n.DeleteAccount.passwordPlaceholder, text: $viewModel.password)
                    .font(AppFont.regular(14))
                    .padding(14)
                    .premiumListRow(cornerRadius: 16)
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
                let canConfirm = viewModel.code.count == 6 && !viewModel.isBusy
                Text(viewModel.isBusy ? L10n.Privacy.twoFactorVerifying : L10n.Privacy.twoFactorConfirmCode)
                    .font(AppFont.medium(15))
                    .foregroundStyle(AppTheme.primaryActionForeground(enabled: canConfirm))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        AppTheme.primaryActionFill(enabled: canConfirm),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }
            .disabled(viewModel.code.count != 6 || viewModel.isBusy)
        }
    }
}
