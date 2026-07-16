import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @ObservedObject private var premium = PremiumStore.shared

    var onUnlocked: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                LuxuryWeddingBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        benefitsCard

                        if let errorMessage = premium.errorMessage {
                            Text(errorMessage)
                                .font(AppFont.regular(13))
                                .foregroundStyle(.red)
                        }

                        purchaseButton
                        restoreButton
                        footnote
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                }
            }
            .task {
                await premium.refreshProducts()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Premium.title)
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.titleOnGlass)

            Text(L10n.Premium.subtitle)
                .font(AppFont.regular(14))
                .foregroundStyle(AppTheme.inkMuted(0.75))
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

    private var purchaseButton: some View {
        Button {
            Task {
                let ok = await premium.purchasePro(session: session)
                if ok {
                    onUnlocked?()
                    dismiss()
                }
            }
        } label: {
            HStack {
                if premium.purchaseInFlight {
                    ProgressView().tint(.white)
                } else {
                    Text(purchaseTitle)
                        .font(AppFont.semibold(15))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [AppTheme.brandGradientEnd, AppTheme.quoteGradientMid],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(premium.purchaseInFlight)
    }

    private var restoreButton: some View {
        Button {
            Task {
                let ok = await premium.restorePurchases(session: session)
                if ok {
                    onUnlocked?()
                    dismiss()
                }
            }
        } label: {
            Text(L10n.Premium.restore)
                .font(AppFont.medium(14))
                .foregroundStyle(AppTheme.sageMuted(0.95))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .disabled(premium.purchaseInFlight)
    }

    private var footnote: some View {
        Text(L10n.Premium.footnote)
            .font(AppFont.regular(11))
            .foregroundStyle(AppTheme.inkMuted(0.55))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var purchaseTitle: String {
        if let product = premium.proProduct {
            return L10n.Premium.buy(product.displayPrice)
        }
        return L10n.Premium.buyFallback
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
        .premiumGlassCard(cornerRadius: 24)
        .padding(.horizontal, 28)
    }
}

extension View {
    /// Blurs the page content and shows the Pro lock card when `isPremium` is false.
    @ViewBuilder
    func premiumContentLock(isPremium: Bool, showPaywall: Binding<Bool>) -> some View {
        ZStack {
            self
                .blur(radius: isPremium ? 0 : 2.5)
                .opacity(isPremium ? 1 : 0.82)

            if !isPremium {
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
