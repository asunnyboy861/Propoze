import StoreKit
import Observation

@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPro: Bool = false

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await updatePurchasedProducts()
                }
            }
        }
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [
                AppConstants.IAP.proMonthly,
                AppConstants.IAP.proYearly,
                AppConstants.IAP.lifetime,
            ])
            products = storeProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updatePurchasedProducts()
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedIDs
        isPro = purchasedProductIDs.contains(AppConstants.IAP.proMonthly)
            || purchasedProductIDs.contains(AppConstants.IAP.proYearly)
            || purchasedProductIDs.contains(AppConstants.IAP.lifetime)
    }

    var monthlyProduct: Product? {
        products.first { $0.id == AppConstants.IAP.proMonthly }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == AppConstants.IAP.proYearly }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == AppConstants.IAP.lifetime }
    }
}
