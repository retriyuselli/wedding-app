import Foundation
import StoreKit

@MainActor
final class PremiumStore: ObservableObject {
    static let shared = PremiumStore()

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var purchaseInFlight = false
    @Published var errorMessage: String?
    @Published private(set) var localEntitled = false
    @Published private(set) var sharedPremiumAccess: [SharedPremiumAccess] = []

    private var updatesTask: Task<Void, Never>?

    var proProduct: Product? {
        products.first { $0.id == BillingProduct.proUnlock }
    }

    var sharedGuestAccess: [SharedPremiumAccess] {
        sharedPremiumAccess.filter(\.canAccessGuests)
    }

    var sharedBudgetAccess: [SharedPremiumAccess] {
        sharedPremiumAccess.filter(\.canAccessBudget)
    }

    private init() {
        updatesTask = Task { await listenForTransactions() }
        Task { await refreshProducts() }
        Task { await refreshLocalEntitlements() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func isPremium(user: User?) -> Bool {
        // Server flag is the source of truth for feature access.
        // Local StoreKit entitlement alone must not unlock Pro — Non-Consumable
        // purchases survive account deletion and would wrongly show "Aktif"
        // on a newly registered free account.
        user?.isPremium == true
    }

    /// True when this Apple ID owns the Non-Consumable on-device (for Restore UX).
    var hasLocalStoreKitEntitlement: Bool { localEntitled }

    /// Call when the API returns `premium_required`.
    func markServerEntitlementMissing() {
        // no-op for unlock path; kept for call sites / future server sync hooks
    }

    func resetAfterAccountDeletion() {
        localEntitled = false
        sharedPremiumAccess = []
        errorMessage = nil
    }

    func refreshProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: BillingProduct.allProIds)
            if proProduct == nil {
                errorMessage = L10n.Premium.productUnavailable
            } else {
                errorMessage = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshLocalEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               BillingProduct.allProIds.contains(transaction.productID) {
                entitled = true
                break
            }
        }
        localEntitled = entitled
    }

    func clearSharedPremiumAccess() {
        sharedPremiumAccess = []
    }

    func refreshServerEntitlement() async {
        do {
            let envelope: Envelope<BillingEntitlement> = try await APIClient.shared.request("billing/entitlement")
            sharedPremiumAccess = envelope.data.sharedPremiumAccess
        } catch {
            guard !error.isRequestCancelled else { return }
            #if DEBUG
            print("[Premium] entitlement refresh failed: \(error)")
            #endif
        }
    }

    @discardableResult
    func purchasePro(session: SessionStore) async -> Bool {
        do {
            await refreshLocalEntitlements()
            if localEntitled {
                let restored = await restorePurchases(session: session)
                if restored {
                    return true
                }
                // Restore found a StoreKit entitlement but server sync failed → keep that error.
                if errorMessage != nil, errorMessage != L10n.Premium.restoreEmpty {
                    return false
                }
                // Stale local flag / empty entitlements → continue with a real purchase attempt.
            }

            if proProduct == nil {
                await refreshProducts()
            }
            guard let product = proProduct else {
                errorMessage = L10n.Premium.productUnavailable
                return false
            }

            purchaseInFlight = true
            errorMessage = nil
            defer { purchaseInFlight = false }

            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                let synced = await syncToServer(
                    productId: transaction.productID,
                    transactionId: String(transaction.id),
                    originalTransactionId: String(transaction.originalID),
                    signedTransaction: verification.jwsRepresentation,
                    session: session
                )
                await transaction.finish()
                await refreshLocalEntitlements()
                return synced
            case .userCancelled:
                return false
            case .pending:
                errorMessage = L10n.Premium.purchasePending
                return false
            @unknown default:
                errorMessage = L10n.Premium.purchaseFailed
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func restorePurchases(session: SessionStore) async -> Bool {
        purchaseInFlight = true
        errorMessage = nil
        defer { purchaseInFlight = false }

        do {
            try await AppStore.sync()
            var sawProEntitlement = false
            var restored = false
            var lastSyncError: String?

            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result,
                      BillingProduct.allProIds.contains(transaction.productID) else {
                    continue
                }

                sawProEntitlement = true
                if await syncToServer(
                    productId: transaction.productID,
                    transactionId: String(transaction.id),
                    originalTransactionId: String(transaction.originalID),
                    signedTransaction: result.jwsRepresentation,
                    session: session
                ) {
                    restored = true
                } else {
                    lastSyncError = errorMessage
                }
            }

            await refreshLocalEntitlements()

            if restored {
                errorMessage = nil
                return true
            }

            if sawProEntitlement {
                // Never replace a real API/sync error with "no purchase found".
                errorMessage = lastSyncError ?? L10n.Premium.purchaseFailed
                return false
            }

            errorMessage = L10n.Premium.restoreEmpty
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result,
                  BillingProduct.allProIds.contains(transaction.productID) else {
                continue
            }
            localEntitled = true
            await transaction.finish()
        }
    }

    private func syncToServer(
        productId: String,
        transactionId: String,
        originalTransactionId: String,
        signedTransaction: String,
        session: SessionStore
    ) async -> Bool {
        do {
            struct VerifyResponse: Decodable {
                let message: String?
                let user: User
            }

            let response: VerifyResponse = try await APIClient.shared.request(
                "billing/apple/verify",
                method: "POST",
                json: [
                    "product_id": productId,
                    "transaction_id": transactionId,
                    "original_transaction_id": originalTransactionId,
                    "signed_transaction": signedTransaction,
                ]
            )
            session.updateCurrentUser(response.user)
            localEntitled = true
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.userFacingMessage
            return false
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PremiumStoreError.unverified
        case .verified(let safe):
            return safe
        }
    }
}

enum PremiumStoreError: LocalizedError {
    case unverified

    var errorDescription: String? {
        L10n.Premium.unverifiedTransaction
    }
}
