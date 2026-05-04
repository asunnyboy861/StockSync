import Foundation
import SwiftData

@Model
final class Product {
    @Attribute(.unique) var sku: String
    var name: String
    var totalAvailable: Int
    var lowStockThreshold: Int
    var shopifyStock: Int
    var woocommerceStock: Int
    var etsyStock: Int
    var amazonStock: Int
    var createdAt: Date
    var updatedAt: Date

    var isLowStock: Bool {
        totalAvailable > 0 && totalAvailable <= lowStockThreshold
    }

    var isOutOfStock: Bool {
        totalAvailable == 0
    }

    var stockLevel: StockLevel {
        if totalAvailable == 0 { return .out }
        if totalAvailable <= lowStockThreshold { return .low }
        return .normal
    }

    enum StockLevel: String, CaseIterable {
        case normal = "Normal"
        case low = "Low Stock"
        case out = "Out of Stock"
    }

    init(
        sku: String,
        name: String = "",
        totalAvailable: Int = 0,
        lowStockThreshold: Int = 5,
        shopifyStock: Int = 0,
        woocommerceStock: Int = 0,
        etsyStock: Int = 0,
        amazonStock: Int = 0
    ) {
        self.sku = sku
        self.name = name
        self.totalAvailable = totalAvailable
        self.lowStockThreshold = lowStockThreshold
        self.shopifyStock = shopifyStock
        self.woocommerceStock = woocommerceStock
        self.etsyStock = etsyStock
        self.amazonStock = amazonStock
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
