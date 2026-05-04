import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    var currentTier: SubscriptionTier = .free
    var purchasedProductIDs: Set<String> = []
    var isLoading = false

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
        Task { await loadPurchases() }
    }

    func loadPurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let _ = try await StoreKit.Product.products(for: allProductIDs)
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    await handleTransaction(transaction)
                }
            }
        } catch {
            print("Failed to load purchases: \(error)")
        }
    }

    func purchase(_ productID: String) async throws -> Bool {
        let products = try await StoreKit.Product.products(for: [productID])
        guard let product = products.first else { return false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await handleTransaction(transaction)
                return true
            }
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await loadPurchases()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    private func handleTransaction(_ transaction: Transaction) async {
        purchasedProductIDs.insert(transaction.productID)
        currentTier = tierForProductID(transaction.productID)
        await transaction.finish()
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self?.handleTransaction(transaction)
                }
            }
        }
    }

    private func tierForProductID(_ id: String) -> SubscriptionTier {
        if id.contains("pro") { return .pro }
        if id.contains("starter") { return .starter }
        if id.contains("lifetime") { return .lifetime }
        return .free
    }

    var allProductIDs: [String] {
        [
            "com.zzoutuo.StockSync.starter.monthly",
            "com.zzoutuo.StockSync.starter.yearly",
            "com.zzoutuo.StockSync.pro.monthly",
            "com.zzoutuo.StockSync.pro.yearly",
            "com.zzoutuo.StockSync.lifetime"
        ]
    }
}
