import Foundation
import CryptoKit

final class ShopifyAPIClient {
    private let storeDomain: String
    private let accessToken: String
    private let session: URLSession

    init(storeDomain: String, accessToken: String) {
        self.storeDomain = storeDomain
        self.accessToken = accessToken
        self.session = URLSession.shared
    }

    func fetchProducts() async throws -> [ShopifyProduct] {
        var request = URLRequest(
            url: URL(string: "https://\(storeDomain)/admin/api/2025-04/products.json?status=active&fields=id,title,sku,variants")!
        )
        request.setValue(accessToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        request.httpMethod = "GET"

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(ShopifyProductsResponse.self, from: data)
        return response.products
    }

    func updateInventory(sku: String, change: Int) async throws {
        let itemId = try await lookupInventoryItemId(sku: sku)

        var request = URLRequest(
            url: URL(string: "https://\(storeDomain)/admin/api/2025-04/inventory_levels/adjust.json")!
        )
        request.setValue(accessToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let body: [String: Any] = [
            "inventory_item_id": itemId,
            "available_adjustment": change
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.apiError("Shopify inventory update failed for SKU: \(sku)")
        }
    }

    func verifyWebhook(data: Data, hmacHeader: String) -> Bool {
        let key = SymmetricKey(data: Data(accessToken.utf8))
        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        let computedHMAC = Data(hmac).map { String(format: "%02x", $0) }.joined()
        return computedHMAC == hmacHeader
    }

    private func lookupInventoryItemId(sku: String) async throws -> String {
        var request = URLRequest(
            url: URL(string: "https://\(storeDomain)/admin/api/2025-04/inventory_items.json?sku=\(sku.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? sku)")!
        )
        request.setValue(accessToken, forHTTPHeaderField: "X-Shopify-Access-Token")

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(ShopifyInventoryItemsResponse.self, from: data)
        guard let item = response.inventoryItems.first else {
            throw SyncError.skuNotFound(sku)
        }
        return String(item.id)
    }
}

enum SyncError: LocalizedError {
    case apiError(String)
    case skuNotFound(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .apiError(let msg): return msg
        case .skuNotFound(let sku): return "SKU not found: \(sku)"
        case .networkError(let msg): return "Network error: \(msg)"
        }
    }
}

struct ShopifyProductsResponse: Codable {
    let products: [ShopifyProduct]
}

struct ShopifyProduct: Codable, Identifiable {
    let id: Int
    let title: String
    let sku: String?
    let variants: [ShopifyVariant]?

    var displaySKU: String { sku ?? "SKU-\(id)" }
}

struct ShopifyVariant: Codable {
    let id: Int
    let sku: String?
    let inventoryItemId: Int?
    let inventoryQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case id, sku
        case inventoryItemId = "inventory_item_id"
        case inventoryQuantity = "inventory_quantity"
    }
}

struct ShopifyInventoryItemsResponse: Codable {
    let inventoryItems: [ShopifyInventoryItem]

    enum CodingKeys: String, CodingKey {
        case inventoryItems = "inventory_items"
    }
}

struct ShopifyInventoryItem: Codable {
    let id: Int
    let sku: String?
}
