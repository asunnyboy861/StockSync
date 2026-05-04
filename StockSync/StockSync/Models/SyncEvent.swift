import Foundation

struct SyncEvent: Identifiable, Codable {
    let id: UUID
    let source: ChannelType
    let sku: String
    let quantityChange: Int
    let timestamp: Date
    let orderId: String?

    enum ChannelType: String, CaseIterable, Codable {
        case shopify = "Shopify"
        case woocommerce = "WooCommerce"
        case etsy = "Etsy"
        case amazon = "Amazon"
        case manual = "Manual"
    }

    init(
        id: UUID = UUID(),
        source: ChannelType,
        sku: String,
        quantityChange: Int,
        orderId: String? = nil
    ) {
        self.id = id
        self.source = source
        self.sku = sku
        self.quantityChange = quantityChange
        self.timestamp = Date()
        self.orderId = orderId
    }
}
