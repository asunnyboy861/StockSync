import Foundation
import SwiftData

@Model
final class Store {
    @Attribute(.unique) var storeId: String
    var name: String
    var platform: String
    var storeURL: String
    var accessToken: String?
    var consumerKey: String?
    var consumerSecret: String?
    var isConnected: Bool
    var lastSyncAt: Date?
    var connectedAt: Date

    enum Platform: String, CaseIterable, Codable {
        case shopify = "Shopify"
        case woocommerce = "WooCommerce"
        case etsy = "Etsy"
        case amazon = "Amazon"
    }

    init(
        storeId: String = UUID().uuidString,
        name: String = "",
        platform: String = "Shopify",
        storeURL: String = "",
        accessToken: String? = nil,
        consumerKey: String? = nil,
        consumerSecret: String? = nil,
        isConnected: Bool = false
    ) {
        self.storeId = storeId
        self.name = name
        self.platform = platform
        self.storeURL = storeURL
        self.accessToken = accessToken
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.isConnected = isConnected
        self.connectedAt = Date()
    }
}
