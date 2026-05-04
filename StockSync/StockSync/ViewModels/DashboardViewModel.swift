import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {
    var totalStock = 0
    var lowStockCount = 0
    var failedSyncCount = 0
    var isSyncing = false
    var recentSyncLogs: [SyncLogEntry] = []
    var lowStockProducts: [Product] = []

    private var syncEngine = InventorySyncEngine()

    func loadDashboard(modelContext: ModelContext) {
        let productDescriptor = FetchDescriptor<Product>()
        let logDescriptor = FetchDescriptor<SyncLogEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let products = try modelContext.fetch(productDescriptor)
            let logs = try modelContext.fetch(logDescriptor)

            totalStock = products.reduce(0) { $0 + $1.totalAvailable }
            lowStockProducts = products.filter { $0.isLowStock || $0.isOutOfStock }
            lowStockCount = lowStockProducts.count
            failedSyncCount = logs.filter { $0.status == "failed" }.count
            recentSyncLogs = Array(logs.prefix(5))
        } catch {
            print("Dashboard load error: \(error)")
        }
    }

    func triggerManualSync(modelContext: ModelContext) async {
        isSyncing = true
        defer { isSyncing = false }

        let storeDescriptor = FetchDescriptor<Store>(predicate: #Predicate { $0.isConnected })
        do {
            let connectedStores = try modelContext.fetch(storeDescriptor)
            for _ in connectedStores {
                let event = SyncEvent(
                    source: .manual,
                    sku: "ALL",
                    quantityChange: 0
                )
                await syncEngine.enqueue(event)
            }
            await syncEngine.processQueue(
                onSync: { event in
                    let log = SyncLogEntry(
                        sourceStore: event.source.rawValue,
                        targetStore: "All",
                        sku: event.sku,
                        quantityChange: event.quantityChange,
                        status: "success"
                    )
                    modelContext.insert(log)
                },
                onRetry: { event in
                    let log = SyncLogEntry(
                        sourceStore: event.source.rawValue,
                        targetStore: "All",
                        sku: event.sku,
                        quantityChange: event.quantityChange,
                        status: "retrying"
                    )
                    modelContext.insert(log)
                }
            )
            try? modelContext.save()
            loadDashboard(modelContext: modelContext)
        } catch {
            print("Sync error: \(error)")
        }
    }
}
