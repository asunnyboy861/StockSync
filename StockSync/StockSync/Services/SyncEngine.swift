import Foundation

actor InventorySyncEngine {
    private var syncQueue: [SyncEvent] = []
    private var isProcessing = false

    func enqueue(_ event: SyncEvent) {
        syncQueue.append(event)
    }

    func processQueue(
        onSync: @escaping (SyncEvent) async throws -> Void,
        onRetry: @escaping (SyncEvent) -> Void
    ) async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        while let event = syncQueue.first {
            syncQueue.removeFirst()
            do {
                try await onSync(event)
            } catch {
                onRetry(event)
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    var pendingCount: Int {
        syncQueue.count
    }

    func clear() {
        syncQueue.removeAll()
    }
}
