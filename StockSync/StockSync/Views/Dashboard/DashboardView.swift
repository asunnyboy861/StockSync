import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statsRow
                    if !viewModel.lowStockProducts.isEmpty {
                        lowStockAlert
                    }
                    recentActivitySection
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("StockSync")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.triggerManualSync(modelContext: modelContext) }
                    } label: {
                        if viewModel.isSyncing {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SyncLogView()
                    } label: {
                        Image(systemName: "bell.badge")
                    }
                }
            }
            .refreshable {
                await viewModel.triggerManualSync(modelContext: modelContext)
            }
            .onAppear {
                viewModel.loadDashboard(modelContext: modelContext)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCardView(
                title: "Total Stock",
                value: "\(viewModel.totalStock)",
                icon: "cube.box",
                color: .blue
            )
            StatCardView(
                title: "Low Stock",
                value: "\(viewModel.lowStockCount)",
                icon: "exclamationmark.triangle",
                color: viewModel.lowStockCount == 0 ? .green : .orange
            )
            StatCardView(
                title: "Sync Status",
                value: viewModel.failedSyncCount == 0 ? "OK" : "\(viewModel.failedSyncCount)",
                icon: viewModel.failedSyncCount == 0 ? "checkmark.circle" : "xmark.circle",
                color: viewModel.failedSyncCount == 0 ? .green : .red
            )
        }
    }

    private var lowStockAlert: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Low Stock Alert", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(viewModel.lowStockProducts.prefix(3)) { product in
                HStack {
                    Circle()
                        .fill(product.totalAvailable == 0 ? Color.red : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(product.name.isEmpty ? product.sku : product.name)
                        .font(.subheadline)
                    Spacer()
                    Text("\(product.totalAvailable) left")
                        .font(.subheadline.bold())
                        .foregroundStyle(product.totalAvailable == 0 ? .red : .orange)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Sync Activity")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    SyncLogView()
                }
                .font(.subheadline)
            }

            if viewModel.recentSyncLogs.isEmpty {
                ContentUnavailableView(
                    "No Activity Yet",
                    systemImage: "clock",
                    description: Text("Sync events will appear here")
                )
            } else {
                ForEach(viewModel.recentSyncLogs) { log in
                    SyncLogRowView(entry: log)
                }
            }
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
