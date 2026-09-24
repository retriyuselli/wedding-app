import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared

    var onUnlocked: (() -> Void)?

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertOffersPurchase = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        benefitsCard

                        if let errorMessage = premium.errorMessage,
                           errorMessage != L10n.Premium.restoreEmpty {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if premium.products.isEmpty {
                            reloadProductsButton
                        }

                        purchaseButtons
                        restoreButton
                        footnote
                        legalLinks
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                        .foregroundStyle(AppTheme.titleOnBackground)
                }
            }
            .task {
                await premium.refreshProducts()
            }
            .alert(alertTitle, isPresented: $showAlert) {
                if alertOffersPurchase {
                    Button(L10n.Premium.buyFallback) {
                        if let product = premium.proProduct ?? premium.products.first {
                            Task { await runPurchase(product) }
                        }
                    }
                    Button(L10n.Common.close, role: .cancel) {}
                } else {
                    Button(L10n.Common.ok, role: .cancel) {}
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Premium.title)
                .font(AppFont.serifBold(30))
                .foregroundStyle(AppTheme.titleOnBackground)

            Text(L10n.Premium.subtitle)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.mutedOnBackground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            benefit(icon: "checklist", text: L10n.Premium.benefitChecklist)
            benefit(icon: "person.3", text: L10n.Premium.benefitGuests)
            benefit(icon: "creditcard", text: L10n.Premium.benefitBudget)
            benefit(icon: "person.2", text: L10n.Premium.benefitPartner)
            benefit(icon: "lock.shield", text: L10n.Premium.benefitVisibility)
            benefit(icon: "calendar", text: L10n.Premium.benefitWeddingDetail)
            benefit(icon: "heart.text.square", text: L10n.Premium.benefitCouple)
            benefit(icon: "folder", text: L10n.Premium.benefitDocuments)
            benefit(icon: "sparkles", text: L10n.Premium.benefitInspiration)
            benefit(icon: "bell.badge", text: L10n.Premium.benefitReminders)
            benefit(icon: "tablecells", text: L10n.Premium.benefitExcel)
            benefit(icon: "camera", text: L10n.Premium.benefitCouplePhoto)
        }
        .padding(18)
        .premiumGlassCard(cornerRadius: 22)
    }

    private func benefit(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.iconOnChip)
                .frame(width: 36, height: 36)
                .background(AppTheme.iconChipFill, in: Circle())
            Text(text)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.titleOnGlass)
            Spacer(minLength: 0)
        }
    }

    private var reloadProductsButton: some View {
        Button {
            Task { await premium.refreshProducts() }
        } label: {
            HStack(spacing: 8) {
                if premium.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                    Text(L10n.Premium.reloadProducts)
                        .font(AppFont.medium(14))
                }
            }
            .foregroundStyle(AppTheme.titleOnBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .disabled(premium.isLoading || premium.purchaseInFlight)
    }

    private var purchaseButtons: some View {
        VStack(spacing: 10) {
            if premium.products.isEmpty {
                purchaseLabel(L10n.Premium.buyFallback, emphasized: false)
            } else {
                ForEach(premium.products, id: \.id) { product in
                    Button {
                        Task { await runPurchase(product) }
                    } label: {
                        purchaseLabel(
                            BillingProduct.planTitle(for: product.id, price: product.displayPrice),
                            emphasized: product.id == BillingProduct.monthly
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(premium.purchaseInFlight || premium.isLoading)
                }
            }
        }
    }

    private func purchaseLabel(_ title: String, emphasized: Bool) -> some View {
        HStack {
            if premium.purchaseInFlight && emphasized {
                ProgressView().tint(.white)
            } else {
                Text(title)
                    .font(AppFont.semibold(15))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
        .foregroundStyle(AppTheme.primaryActionForeground(enabled: emphasized || !premium.products.isEmpty))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background {
            Group {
                if emphasized {
                    LinearGradient(
                        colors: [AppTheme.brandGradientEnd, AppTheme.quoteGradientMid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    AppTheme.primaryActionFill(enabled: !premium.products.isEmpty)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await runRestore() }
        } label: {
            Text(L10n.Premium.restore)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.titleOnBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .disabled(premium.purchaseInFlight)
    }

    private var footnote: some View {
        Text(L10n.Premium.footnote)
            .font(AppFont.regular(11))
            .foregroundStyle(AppTheme.mutedOnBackground.opacity(0.85))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    private var legalLinks: some View {
        VStack(spacing: 10) {
            Link(destination: AboutContent.privacyPolicyURL) {
                Text(L10n.Premium.privacyLink)
                    .font(AppFont.medium(13))
                    .underline()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            Link(destination: AboutContent.termsURL) {
                Text(L10n.Premium.termsLink)
                    .font(AppFont.medium(13))
                    .underline()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(AppTheme.titleOnBackground)
    }

    private func runPurchase(_ product: Product) async {
        let ok = await premium.purchase(product, session: session)
        if ok {
            onUnlocked?()
            dismiss()
            return
        }
        presentActionAlertIfNeeded()
    }

    private func runRestore() async {
        let ok = await premium.restorePurchases(session: session)
        if ok {
            onUnlocked?()
            dismiss()
            return
        }
        presentActionAlertIfNeeded()
    }

    private func presentActionAlertIfNeeded() {
        guard let message = premium.errorMessage, !message.isEmpty else { return }

        if message == L10n.Premium.restoreEmpty {
            alertTitle = L10n.Premium.restoreEmptyTitle
            alertMessage = message
            alertOffersPurchase = true
            premium.errorMessage = nil
            showAlert = true
            return
        }

        alertTitle = L10n.Common.warning
        alertMessage = message
        alertOffersPurchase = false
        showAlert = true
    }
}

@MainActor
enum PremiumGate {
    static func allows(_ session: SessionStore, premium: PremiumStore) -> Bool {
        premium.isPremium(user: session.currentUser)
    }

    static func allows(_ session: SessionStore) -> Bool {
        allows(session, premium: PremiumStore.shared)
    }

    static func presentOrRun(
        isPremium: Bool,
        showPaywall: Binding<Bool>,
        action: () -> Void
    ) {
        if isPremium {
            action()
        } else {
            showPaywall.wrappedValue = true
        }
    }

    static func presentOrRun(
        session: SessionStore,
        showPaywall: Binding<Bool>,
        action: () -> Void
    ) {
        presentOrRun(isPremium: allows(session), showPaywall: showPaywall, action: action)
    }
}

/// Soft lock card used when an entire screen requires Pro.
struct PremiumLockedOverlay: View {
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(AppTheme.sageDark)
                .frame(width: 64, height: 64)
                .background(AppTheme.iconChipFill, in: Circle())

            Text(L10n.Premium.lockedTitle)
                .font(AppFont.semibold(18))
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(L10n.Premium.lockedMessage)
                .font(AppFont.regular(13))
                .foregroundStyle(AppTheme.inkMuted(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Button(action: onUnlock) {
                Text(L10n.Premium.unlockCta)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.sage, AppTheme.sageDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.surface)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
        .shadow(color: AppTheme.sageDark.opacity(0.12), radius: 16, y: 8)
        .padding(.horizontal, 28)
    }
}

extension View {
    /// Dims the page and shows the Pro lock card when `isPremium` is false.
    /// Avoids `.blur` on scroll trees (forces full offscreen rasterization every frame).
    @ViewBuilder
    func premiumContentLock(isPremium: Bool, showPaywall: Binding<Bool>) -> some View {
        ZStack {
            self
                .opacity(isPremium ? 1 : 0.55)
                .allowsHitTesting(isPremium)

            if !isPremium {
                Color.black.opacity(0.12)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                PremiumLockedOverlay {
                    showPaywall.wrappedValue = true
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

/// Presents paywall when needed; otherwise runs the action.
struct PremiumGatedModifier: ViewModifier {
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared
    @State private var showPaywall = false

    let featureName: String
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(TapGesture().onEnded {
                if PremiumGate.allows(session, premium: premium) {
                    action()
                } else {
                    showPaywall = true
                }
            })
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(session)
            }
            .accessibilityLabel(featureName)
    }
}
