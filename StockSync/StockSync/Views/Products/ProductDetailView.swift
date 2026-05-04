import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Bindable var product: Product
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            Section("Product Info") {
                LabeledContent("Name", value: product.name.isEmpty ? "-" : product.name)
                LabeledContent("SKU", value: product.sku)
                LabeledContent("Stock Level", value: product.stockLevel.rawValue)
            }

            Section("Stock by Channel") {
                LabeledContent("Shopify", value: "\(product.shopifyStock)")
                LabeledContent("WooCommerce", value: "\(product.woocommerceStock)")
                LabeledContent("Etsy", value: "\(product.etsyStock)")
                LabeledContent("Amazon", value: "\(product.amazonStock)")
            }

            Section("Total") {
                LabeledContent("Total Available", value: "\(product.totalAvailable)")
                LabeledContent("Low Stock Threshold", value: "\(product.lowStockThreshold)")

                StockLevelBar(available: product.totalAvailable, threshold: product.lowStockThreshold)
                    .padding(.vertical, 4)
            }

            Section("Details") {
                LabeledContent("Created", value: product.createdAt.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Updated", value: product.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .navigationTitle(product.name.isEmpty ? product.sku : product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
