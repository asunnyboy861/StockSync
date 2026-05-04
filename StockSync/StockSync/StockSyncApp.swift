import SwiftUI
import SwiftData

@main
struct StockSyncApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Product.self, Store.self, SyncLogEntry.self])
    }
}
