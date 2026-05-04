import Foundation

enum SubscriptionTier: String, CaseIterable {
    case free = "Free"
    case starter = "Starter"
    case pro = "Pro"
    case lifetime = "Lifetime"

    var maxStores: Int {
        switch self {
        case .free: return 1
        case .starter: return 2
        case .pro: return .max
        case .lifetime: return .max
        }
    }

    var maxSKUs: Int {
        switch self {
        case .free: return 50
        case .starter: return 500
        case .pro: return .max
        case .lifetime: return .max
        }
    }

    var syncType: String {
        switch self {
        case .free: return "Manual"
        case .starter: return "Auto (5 min)"
        case .pro: return "Real-time Webhook"
        case .lifetime: return "Real-time Webhook"
        }
    }

    var hasLowStockAlert: Bool { self != .free }
    var hasOversellProtection: Bool { self == .pro || self == .lifetime }
    var hasReturnSync: Bool { self == .pro || self == .lifetime }
    var hasCSVExport: Bool { self != .free }
    var hasPushNotifications: Bool { self != .free }
}
