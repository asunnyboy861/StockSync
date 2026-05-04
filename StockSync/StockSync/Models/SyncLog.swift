import Foundation
import SwiftData

@Model
final class SyncLogEntry {
    var id: String
    var sourceStore: String
    var targetStore: String
    var sku: String
    var quantityChange: Int
    var status: String
    var errorMessage: String?
    var timestamp: Date

    enum Status: String, CaseIterable {
        case success = "success"
        case failed = "failed"
        case pending = "pending"
        case retrying = "retrying"
    }

    init(
        id: String = UUID().uuidString,
        sourceStore: String = "",
        targetStore: String = "",
        sku: String = "",
        quantityChange: Int = 0,
        status: String = "pending",
        errorMessage: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sourceStore = sourceStore
        self.targetStore = targetStore
        self.sku = sku
        self.quantityChange = quantityChange
        self.status = status
        self.errorMessage = errorMessage
        self.timestamp = timestamp
    }
}
