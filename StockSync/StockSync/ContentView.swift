import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(0)

            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "cube.box")
                }
                .tag(1)

            StoresView()
                .tabItem {
                    Label("Stores", systemImage: "storefront")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Product.self, Store.self, SyncLogEntry.self], inMemory: true)
}
