import SwiftUI

struct TrustedDevicesView: View {
    @StateObject private var viewModel = TrustedDevicesViewModel()
    @State private var showSuccess = false
    @State private var deviceToDelete: TrustedDevice?

    var body: some View {
        ZStack {
            LuxuryWeddingBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MoreSubpageNavigationHeader(
                        title: L10n.Privacy.trustedDevices,
                        subtitle: L10n.Privacy.trustedDevicesSub
                    )

                    if let errorMessage = viewModel.errorMessage, viewModel.devices.isEmpty {
                        VStack(spacing: 10) {
                            Text(errorMessage).font(AppFont.regular(13)).foregroundStyle(.red)
                            Button(L10n.Common.tryAgain) { Task { await viewModel.retry() } }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if viewModel.isLoading && viewModel.devices.isEmpty {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    }

                    Button {
                        Task {
                            await viewModel.trustThisDevice()
                            if viewModel.successMessage != nil { showSuccess = true }
                        }
                    } label: {
                        Text(viewModel.isBusy ? "Menyimpan…" : "Percayai perangkat ini")
                            .font(AppFont.medium(15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.sageDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(.white)
                    }
                    .disabled(viewModel.isBusy)

                    ForEach(viewModel.devices) { device in
                        deviceRow(device)
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
        .refreshable { await viewModel.retry() }
        .alert("Berhasil", isPresented: $showSuccess) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .alert("Hapus perangkat?", isPresented: Binding(
            get: { deviceToDelete != nil },
            set: { if !$0 { deviceToDelete = nil } }
        )) {
            Button(L10n.Common.delete, role: .destructive) {
                if let deviceToDelete {
                    Task {
                        await viewModel.delete(deviceToDelete)
                        if viewModel.successMessage != nil { showSuccess = true }
                    }
                }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(deviceToDelete?.deviceName ?? "")
        }
    }

    private func deviceRow(_ device: TrustedDevice) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(device.deviceName).font(AppFont.medium(14)).foregroundStyle(AppTheme.ink)
                    Text(device.isTrusted ? "Tepercaya" : "Tidak dipercaya")
                        .font(AppFont.regular(12))
                        .foregroundStyle(AppTheme.ink.opacity(0.45))
                    if device.isCurrent == true {
                        Text(L10n.Sessions.thisDevice)
                            .font(AppFont.medium(11))
                            .foregroundStyle(AppTheme.sageDark)
                    }
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { device.isTrusted },
                    set: { _ in
                        Task {
                            await viewModel.toggleTrust(device)
                            if viewModel.successMessage != nil { showSuccess = true }
                        }
                    }
                ))
                .labelsHidden()
            }

            Button(role: .destructive) {
                deviceToDelete = device
            } label: {
                Text("Hapus").font(AppFont.medium(12))
            }
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }
}
