import SwiftUI
import SwiftData

struct ProductsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProductsViewModel()
    @State private var showingAddProduct = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                productListView
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProduct = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search by name or SKU")
            .sheet(isPresented: $showingAddProduct) {
                AddProductView()
            }
            .onAppear {
                viewModel.loadProducts(modelContext: modelContext)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProductsViewModel.ProductFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                viewModel.selectedFilter == filter ? Color.blue : Color.gray.opacity(0.15),
                                in: Capsule()
                            )
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var productListView: some View {
        List {
            ForEach(viewModel.filteredProducts) { product in
                NavigationLink {
                    ProductDetailView(product: product)
                } label: {
                    ProductRowView(product: product)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let product = viewModel.filteredProducts[index]
                    viewModel.deleteProduct(product, modelContext: modelContext)
                }
            }
        }
        .overlay {
            if viewModel.filteredProducts.isEmpty {
                ContentUnavailableView(
                    "No Products",
                    systemImage: "cube.box",
                    description: Text("Add products or sync from your stores")
                )
            }
        }
    }
}

struct ProductRowView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(product.name.isEmpty ? product.sku : product.name)
                    .font(.headline)
                Spacer()
                Text(product.stockLevel.rawValue)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(stockLevelColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(stockLevelColor)
            }

            Text("SKU: \(product.sku)")
                .font(.caption)
                .foregroundStyle(.secondary)

            StockLevelBar(available: product.totalAvailable, threshold: product.lowStockThreshold)

            HStack(spacing: 12) {
                if product.shopifyStock > 0 || product.woocommerceStock > 0 {
                    Label("Shopify: \(product.shopifyStock)", systemImage: "bag")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Label("WooCommerce: \(product.woocommerceStock)", systemImage: "cart")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var stockLevelColor: Color {
        switch product.stockLevel {
        case .normal: return .green
        case .low: return .orange
        case .out: return .red
        }
    }
}

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var sku = ""
    @State private var name = ""
    @State private var totalAvailable = ""
    @State private var lowStockThreshold = "5"

    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("SKU", text: $sku)
                    TextField("Name", text: $name)
                    TextField("Total Stock", text: $totalAvailable)
                        .keyboardType(.numberPad)
                    TextField("Low Stock Threshold", text: $lowStockThreshold)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let product = Product(
                            sku: sku,
                            name: name,
                            totalAvailable: Int(totalAvailable) ?? 0,
                            lowStockThreshold: Int(lowStockThreshold) ?? 5
                        )
                        modelContext.insert(product)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(sku.isEmpty)
                }
            }
        }
    }
}
