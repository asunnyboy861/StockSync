import Foundation
import SwiftData
import Observation

@Observable
final class StoresViewModel {
    var stores: [Store] = []
    var isConnecting = false
    var errorMessage: String?

    func loadStores(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Store>(sortBy: [SortDescriptor(\.name)])
        do {
            stores = try modelContext.fetch(descriptor)
        } catch {
            print("Stores load error: \(error)")
        }
    }

    func connectShopify(storeDomain: String, accessToken: String, modelContext: ModelContext) async {
        isConnecting = true
        errorMessage = nil
        defer { isConnecting = false }

        let client = ShopifyAPIClient(storeDomain: storeDomain, accessToken: accessToken)
        do {
            let _ = try await client.fetchProducts()
            KeychainHelper.shared.saveString(key: "shopify_\(storeDomain)_token", value: accessToken)
            let store = Store(
                name: storeDomain.replacingOccurrences(of: ".myshopify.com", with: ""),
                platform: Store.Platform.shopify.rawValue,
                storeURL: "https://\(storeDomain)",
                accessToken: accessToken,
                isConnected: true
            )
            modelContext.insert(store)
            try? modelContext.save()
            loadStores(modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func connectWooCommerce(storeURL: String, consumerKey: String, consumerSecret: String, modelContext: ModelContext) async {
        isConnecting = true
        errorMessage = nil
        defer { isConnecting = false }

        let client = WooCommerceAPIClient(storeURL: storeURL, consumerKey: consumerKey, consumerSecret: consumerSecret)
        do {
            let _ = try await client.fetchProducts()
            KeychainHelper.shared.saveString(key: "wc_\(storeURL)_ck", value: consumerKey)
            KeychainHelper.shared.saveString(key: "wc_\(storeURL)_cs", value: consumerSecret)
            let store = Store(
                name: storeURL.extractDomain(),
                platform: Store.Platform.woocommerce.rawValue,
                storeURL: storeURL,
                consumerKey: consumerKey,
                consumerSecret: consumerSecret,
                isConnected: true
            )
            modelContext.insert(store)
            try? modelContext.save()
            loadStores(modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func disconnectStore(_ store: Store, modelContext: ModelContext) {
        store.isConnected = false
        try? modelContext.save()
        loadStores(modelContext: modelContext)
    }
}

extension String {
    func extractDomain() -> String {
        if let url = URL(string: self), let host = url.host {
            return host
        }
        return self
    }
}
