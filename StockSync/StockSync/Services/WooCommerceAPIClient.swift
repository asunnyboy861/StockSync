import Foundation

final class WooCommerceAPIClient {
    private let storeURL: String
    private let consumerKey: String
    private let consumerSecret: String
    private let session: URLSession

    init(storeURL: String, consumerKey: String, consumerSecret: String) {
        self.storeURL = storeURL.hasSuffix("/") ? String(storeURL.dropLast()) : storeURL
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.session = URLSession.shared
    }

    func fetchProducts() async throws -> [WCProduct] {
        var components = URLComponents(string: "\(storeURL)/wp-json/wc/v3/products")!
        components.queryItems = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "status", value: "publish")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode([WCProduct].self, from: data)
    }

    func updateInventory(sku: String, change: Int) async throws {
        let productId = try await lookupProductId(sku: sku)
        let currentStock = try await getCurrentStock(productId: productId)
        let newStock = currentStock + change

        var request = URLRequest(
            url: URL(string: "\(storeURL)/wp-json/wc/v3/products/\(productId)")!
        )
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"

        let body: [String: Any] = ["stock_quantity": newStock]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.apiError("WooCommerce inventory update failed for SKU: \(sku)")
        }
    }

    private var base64Credentials: String {
        Data("\(consumerKey):\(consumerSecret)".utf8).base64EncodedString()
    }

    private func lookupProductId(sku: String) async throws -> Int {
        var components = URLComponents(string: "\(storeURL)/wp-json/wc/v3/products")!
        components.queryItems = [URLQueryItem(name: "sku", value: sku)]

        var request = URLRequest(url: components.url!)
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let products = try JSONDecoder().decode([WCProduct].self, from: data)
        guard let product = products.first else {
            throw SyncError.skuNotFound(sku)
        }
        return product.id
    }

    private func getCurrentStock(productId: Int) async throws -> Int {
        var request = URLRequest(
            url: URL(string: "\(storeURL)/wp-json/wc/v3/products/\(productId)")!
        )
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let product = try JSONDecoder().decode(WCProduct.self, from: data)
        return product.stockQuantity ?? 0
    }
}

struct WCProduct: Codable, Identifiable {
    let id: Int
    let name: String
    let sku: String?
    let stockQuantity: Int?
    let manageStock: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, sku
        case stockQuantity = "stock_quantity"
        case manageStock = "manage_stock"
    }

    var displaySKU: String { sku ?? "SKU-\(id)" }
}
