import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var currentTier: SubscriptionTier = .free
    var notificationsEnabled = true
    var lowStockThreshold = 5
    var syncInterval: SyncInterval = .manual

    enum SyncInterval: String, CaseIterable {
        case manual = "Manual"
        case fiveMinutes = "Every 5 min"
        case fifteenMinutes = "Every 15 min"
        case realtime = "Real-time"
    }

    func loadSettings(purchaseManager: PurchaseManager) {
        currentTier = purchaseManager.currentTier
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled") == false ? false : true
        lowStockThreshold = UserDefaults.standard.integer(forKey: "low_stock_threshold").nonZeroOr(5)
        let intervalRaw = UserDefaults.standard.string(forKey: "sync_interval") ?? SyncInterval.manual.rawValue
        syncInterval = SyncInterval(rawValue: intervalRaw) ?? .manual
    }

    func saveNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notifications_enabled")
    }

    func saveLowStockThreshold(_ value: Int) {
        lowStockThreshold = value
        UserDefaults.standard.set(value, forKey: "low_stock_threshold")
    }

    func saveSyncInterval(_ interval: SyncInterval) {
        syncInterval = interval
        UserDefaults.standard.set(interval.rawValue, forKey: "sync_interval")
    }
}

extension Int {
    func nonZeroOr(_ default: Int) -> Int {
        self == 0 ? `default` : self
    }
}
