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
                        Button(L10n.Common.tryAgain) { Task { await viewModel.retry() } }
                            .font(AppFont.medium(13))
                            .foregroundStyle(AppTheme.sageMuted(0.9))
                    }

                    if viewModel.isLoading && viewModel.settings == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
                    } else if viewModel.settings != nil {
                        visibilityPicker(L10n.Privacy.visibilityProfile, selection: Binding(
                            get: { viewModel.settings?.profileVisibility ?? "private" },
                            set: { viewModel.settings?.profileVisibility = $0 }
                        ), options: [
                            ("private", L10n.Privacy.visibilityPrivate),
                            ("couple", L10n.Privacy.visibilityCouple),
                            ("public", L10n.Privacy.visibilityPublic),
                        ])

                        visibilityPicker(L10n.Privacy.visibilityWedding, selection: Binding(
                            get: { viewModel.settings?.weddingVisibility ?? "couple" },
                            set: { viewModel.settings?.weddingVisibility = $0 }
                        ), options: [
                            ("private", L10n.Privacy.visibilityPrivate),
                            ("couple", L10n.Privacy.visibilityCouple),
                            ("vendors", L10n.Privacy.visibilityVendors),
                        ])

                        visibilityPicker(L10n.Privacy.visibilityGuests, selection: Binding(
                            get: { viewModel.settings?.guestListVisibility ?? "private" },
                            set: { viewModel.settings?.guestListVisibility = $0 }
                        ), options: [
                            ("private", L10n.Privacy.visibilityPrivate),
                            ("couple", L10n.Privacy.visibilityCouple),
                        ])

                        visibilityPicker(L10n.Privacy.visibilityBudget, selection: Binding(
                            get: { viewModel.settings?.budgetVisibility ?? "private" },
                            set: { viewModel.settings?.budgetVisibility = $0 }
                        ), options: [
                            ("private", L10n.Privacy.visibilityPrivate),
                            ("couple", L10n.Privacy.visibilityCouple),
                        ])

                        Toggle(L10n.Privacy.showInDirectory, isOn: Binding(
                            get: { viewModel.settings?.showInDirectory ?? false },
                            set: { viewModel.settings?.showInDirectory = $0 }
                        ))
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .tint(AppTheme.sageMuted(1))
                        .padding(14)
                        .premiumGlassCard(cornerRadius: 16)

                        Toggle(L10n.Privacy.allowVendorContact, isOn: Binding(
                            get: { viewModel.settings?.allowVendorContact ?? true },
                            set: { viewModel.settings?.allowVendorContact = $0 }
                        ))
                        .font(AppFont.medium(14))
                        .foregroundStyle(AppTheme.titleOnGlass)
                        .tint(AppTheme.sageMuted(1))
                        .padding(14)
                        .premiumGlassCard(cornerRadius: 16)

                        partnerSection

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
                Text(viewModel.isSaving ? L10n.Privacy.saving : L10n.Common.save)
                    .font(AppFont.medium(15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.quoteGradientMid, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(.white)
            }
            .disabled(viewModel.isSaving || viewModel.settings == nil)
            .padding(20)
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

    @ViewBuilder
    private var partnerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Privacy.partnerSection)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.inkMuted(0.72))

            Text(L10n.Privacy.partnerSectionHint)
                .font(AppFont.regular(12))
                .foregroundStyle(AppTheme.inkMuted(0.6))
                .fixedSize(horizontal: false, vertical: true)

            if viewModel.isPartnerLinked, let partnerId = viewModel.settings?.partnerUserId {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Privacy.partnerLinked)
                            .font(AppFont.medium(14))
                            .foregroundStyle(AppTheme.titleOnGlass)
                        if let name = viewModel.linkedPartnerName {
                            Text(name)
                                .font(AppFont.medium(13))
                                .foregroundStyle(AppTheme.titleOnGlass)
                        }
                        if let email = viewModel.linkedPartnerEmail {
                            Text(email)
                                .font(AppFont.regular(13))
                                .foregroundStyle(AppTheme.inkMuted(0.7))
                        } else {
                            Text(L10n.Privacy.partnerLinkedId(partnerId))
                                .font(AppFont.regular(12))
                                .foregroundStyle(AppTheme.inkMuted(0.55))
                        }
                    }
                    Spacer()
                    NavigationLink {
                        SharedUserDetailView(userId: partnerId)
                    } label: {
                        Text(L10n.Privacy.viewPartnerData)
                            .font(AppFont.medium(12))
                            .foregroundStyle(AppTheme.sageMuted(0.95))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.nestedGlassFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button(L10n.Privacy.unlinkPartner) {
                    Task {
                        await viewModel.unlinkPartner()
                        if viewModel.successMessage != nil { showSuccess = true }
                    }
                }
                .font(AppFont.medium(13))
                .foregroundStyle(Color.red.opacity(0.85))
                .disabled(viewModel.isSaving)
            }

            if viewModel.isPartnerLinked {
                Text(L10n.Privacy.partnerChangeHint)
                    .font(AppFont.regular(12))
                    .foregroundStyle(AppTheme.inkMuted(0.55))
            }

            TextField(L10n.Privacy.partnerEmailPlaceholder, text: $viewModel.partnerEmailDraft)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.titleOnGlass)
                .padding(12)
                .background(AppTheme.nestedGlassFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }

    private func visibilityPicker(
        _ title: String,
        selection: Binding<String>,
        options: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.medium(13))
                .foregroundStyle(AppTheme.inkMuted(0.72))

            HStack(spacing: 8) {
                ForEach(options, id: \.0) { option in
                    let isSelected = selection.wrappedValue == option.0
                    Button {
                        selection.wrappedValue = option.0
                    } label: {
                        Text(option.1)
                            .font(AppFont.medium(13))
                            .foregroundStyle(isSelected ? AppTheme.labelOnLightSurface : AppTheme.inkMuted(0.75))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                isSelected ? AppTheme.selectedChipFill : AppTheme.chipIdleFill,
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .premiumGlassCard(cornerRadius: 16)
    }
}
