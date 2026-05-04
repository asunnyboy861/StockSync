import SwiftUI
import StoreKit

struct PaywallView: View {
    let purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier = .starter
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    tierPicker
                    featureComparison
                    purchaseButton
                    restoreButton
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Never Oversell Again")
                .font(.title.bold())

            Text("Unlock real-time sync, unlimited stores, and oversell protection")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var tierPicker: some View {
        VStack(spacing: 12) {
            ForEach([SubscriptionTier.starter, .pro, .lifetime], id: \.self) { tier in
                tierCard(tier)
            }
        }
    }

    private func tierCard(_ tier: SubscriptionTier) -> some View {
        Button {
            selectedTier = tier
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(tier.rawValue)
                            .font(.headline)
                        if tier == .pro {
                            Text("Most Popular")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue, in: Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(tier.syncType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(tierPriceText(tier))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
                Spacer()
                Image(systemName: selectedTier == tier ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedTier == tier ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(
                selectedTier == tier ? Color.blue.opacity(0.08) : Color.gray.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedTier == tier ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var featureComparison: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's Included")
                .font(.headline)

            let features: [(String, Bool, Bool, Bool)] = [
                ("Auto Sync", false, true, true),
                ("Real-time Webhook", false, false, true),
                ("Low Stock Alerts", false, true, true),
                ("Oversell Protection", false, false, true),
                ("Return Sync", false, false, true),
                ("CSV Export", false, true, true),
                ("Push Notifications", false, true, true),
            ]

            ForEach(features, id: \.0) { feature, free, starter, pro in
                HStack {
                    Text(feature)
                        .font(.subheadline)
                    Spacer()
                    Text(selectedTier == .starter ? (starter ? "✓" : "—") : (pro ? "✓" : "—"))
                        .foregroundStyle(
                            (selectedTier == .starter ? starter : pro) ? .green : .secondary
                        )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var purchaseButton: some View {
        Button {
            Task {
                isPurchasing = true
                let productID = productIDForTier(selectedTier)
                _ = try? await purchaseManager.purchase(productID)
                isPurchasing = false
                if purchaseManager.currentTier != .free {
                    dismiss()
                }
            }
        } label: {
            if isPurchasing {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Subscribe to \(selectedTier.rawValue)")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var restoreButton: some View {
        Button {
            Task { await purchaseManager.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func tierPriceText(_ tier: SubscriptionTier) -> String {
        switch tier {
        case .free: return "Free"
        case .starter: return "$9.99/mo or $89.99/yr"
        case .pro: return "$24.99/mo or $229.99/yr"
        case .lifetime: return "$499.99 one-time"
        }
    }

    private func productIDForTier(_ tier: SubscriptionTier) -> String {
        switch tier {
        case .starter: return "com.zzoutuo.StockSync.starter.monthly"
        case .pro: return "com.zzoutuo.StockSync.pro.monthly"
        case .lifetime: return "com.zzoutuo.StockSync.lifetime"
        default: return ""
        }
    }
}
