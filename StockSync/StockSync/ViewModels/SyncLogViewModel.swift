import Foundation
import SwiftData
import Observation

@Observable
final class SyncLogViewModel {
    var syncLogs: [SyncLogEntry] = []
    var selectedFilter: LogFilter = .all

    enum LogFilter: String, CaseIterable {
        case all = "All"
        case success = "Success"
        case failed = "Failed"
    }

    var filteredLogs: [SyncLogEntry] {
        switch selectedFilter {
        case .all: return syncLogs
        case .success: return syncLogs.filter { $0.status == "success" }
        case .failed: return syncLogs.filter { $0.status == "failed" }
        }
    }

    func loadLogs(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<SyncLogEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            syncLogs = try modelContext.fetch(descriptor)
        } catch {
            print("Sync log load error: \(error)")
        }
    }

    func clearLogs(modelContext: ModelContext) {
        for log in syncLogs {
            modelContext.delete(log)
        }
        try? modelContext.save()
        loadLogs(modelContext: modelContext)
    }
}
