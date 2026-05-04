import SwiftUI
import SwiftData

struct SyncLogView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SyncLogViewModel()

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            logListView
        }
        .navigationTitle("Sync Activity")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear", role: .destructive) {
                    viewModel.clearLogs(modelContext: modelContext)
                }
            }
        }
        .onAppear {
            viewModel.loadLogs(modelContext: modelContext)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SyncLogViewModel.LogFilter.allCases, id: \.self) { filter in
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

    private var logListView: some View {
        List {
            ForEach(viewModel.filteredLogs) { log in
                SyncLogRowView(entry: log)
            }
        }
        .overlay {
            if viewModel.filteredLogs.isEmpty {
                ContentUnavailableView(
                    "No Sync Logs",
                    systemImage: "clock",
                    description: Text("Sync activity will appear here")
                )
            }
        }
    }
}

struct SyncLogRowView: View {
    let entry: SyncLogEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(entry.sourceStore) → \(entry.targetStore)")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(entry.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("SKU: \(entry.sku) | Qty: \(entry.quantityChange > 0 ? "+" : "")\(entry.quantityChange)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let error = entry.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var statusIcon: String {
        switch entry.status {
        case "success": return "checkmark.circle.fill"
        case "failed": return "xmark.circle.fill"
        case "pending": return "clock.fill"
        case "retrying": return "arrow.clockwise.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch entry.status {
        case "success": return .green
        case "failed": return .red
        case "pending": return .orange
        case "retrying": return .yellow
        default: return .gray
        }
    }
}
