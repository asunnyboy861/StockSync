import Foundation
import SwiftData
import Observation

@Observable
final class ProductsViewModel {
    var searchText = ""
    var selectedFilter: ProductFilter = .all
    var products: [Product] = []

    enum ProductFilter: String, CaseIterable {
        case all = "All"
        case lowStock = "Low Stock"
        case outOfStock = "Out of Stock"
    }

    var filteredProducts: [Product] {
        var result = products
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.sku.localizedCaseInsensitiveContains(searchText)
            }
        }
        switch selectedFilter {
        case .all: break
        case .lowStock: result = result.filter { $0.isLowStock }
        case .outOfStock: result = result.filter { $0.isOutOfStock }
        }
        return result
    }

    func loadProducts(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Product>(sortBy: [SortDescriptor(\.name)])
        do {
            products = try modelContext.fetch(descriptor)
        } catch {
            print("Products load error: \(error)")
        }
    }

    func deleteProduct(_ product: Product, modelContext: ModelContext) {
        modelContext.delete(product)
        try? modelContext.save()
        loadProducts(modelContext: modelContext)
    }
}
