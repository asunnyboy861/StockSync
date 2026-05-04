# StockSync - iOS Development Guide

## Executive Summary

**StockSync** is a native iOS inventory synchronization app designed for small-to-medium e-commerce businesses selling across multiple channels (Shopify, WooCommerce, Etsy, Amazon). The app solves the critical problem of **overselling** — when inventory systems show stock that has already been sold elsewhere — by providing real-time, webhook-driven inventory sync across all connected sales channels.

**Target Audience**: Multi-channel sellers, small e-commerce teams (1-5 people, 100-1000 SKUs), dropshippers, and wholesalers in the US market.

**Key Differentiators**:
- Only iOS native app focused exclusively on inventory sync (not bloated ERP/CRM)
- Sub-30-second webhook-driven sync (vs. 5-15 min for Linnworks/Cin7)
- Small business pricing: Free tier + $9.99-$24.99/month (vs. $300+/month competitors)
- Mobile-first: Check stock, get alerts, monitor sync from your pocket

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Linnworks ($300+/mo) | Full ERP, multi-channel | Expensive, slow sync (5-15min), poor support, no iOS app | 30x cheaper, real-time sync, native iOS |
| Cin7 ($349+/mo) | Near real-time, comprehensive | Very expensive, feature bloat, no iOS app | Focused sync only, mobile-first, affordable |
| Trunk ($29+/mo) | Near real-time, good rating | Web only, no iOS app, limited channels | Native iOS, more channels planned |
| Syncio ($9-99/mo) | Affordable, WooCommerce support | Shopify only, limited features, no iOS app | Multi-channel, iOS native, richer features |
| QuickSync ($19-69/mo) | Shopify-WooCommerce sync | No standalone app, limited to 2 platforms | Independent iOS app, more platforms |
| Zoho Inventory (Free-$79) | Free tier, iOS app exists | Scheduled sync (not real-time), Zoho ecosystem lock-in | Real-time webhook sync, platform agnostic |

**Market Gap**: No iOS native app combines real-time multi-channel inventory sync + affordable pricing + focused feature set.

## Apple Design Guidelines Compliance

- **Clarity**: Clean dashboard with color-coded stock status (green/yellow/red), 3-tap max for any action
- **Consistency**: Standard iOS navigation patterns (TabView, NavigationStack, Sheets)
- **Deference**: Content-first design, minimal chrome, ultra-thin material backgrounds
- **Depth**: Card-based layout with subtle shadows, layered navigation hierarchy
- **Liquid Glass (iOS 26)**: Adopt translucent materials for toolbars and tab bars where appropriate
- **Accessibility**: Dynamic Type support, VoiceOver labels, minimum 44x44pt touch targets, 4.5:1 contrast ratios
- **Dark Mode**: Full support — warehouse/retail users frequently use dark mode to reduce glare

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), SwiftData for persistence
- **Networking**: URLSession + async/await (no third-party dependencies)
- **Security**: Keychain Services for token storage, CryptoKit for HMAC verification
- **Charts**: Swift Charts (iOS 16+)
- **Notifications**: APNs via Supabase Edge Functions
- **Backend**: Supabase (PostgreSQL + Edge Functions + Realtime subscriptions)
- **Sync Engine**: Swift Actor-based concurrent sync with retry logic
- **Minimum iOS**: 17.0

## Module Structure

```
StockSync/
├── App/
│   └── StockSyncApp.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── StatCardView.swift
│   ├── Products/
│   │   ├── ProductsView.swift
│   │   ├── ProductDetailView.swift
│   │   └── ProductRowView.swift
│   ├── Stores/
│   │   ├── StoresView.swift
│   │   ├── ConnectStoreView.swift
│   │   └── StoreDetailView.swift
│   ├── SyncLog/
│   │   ├── SyncLogView.swift
│   │   └── SyncLogRowView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ContactSupportView.swift
│   │   └── PaywallView.swift
│   └── Components/
│       ├── StockLevelBar.swift
│       ├── SyncStatusBadge.swift
│       └── LowStockBanner.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── ProductsViewModel.swift
│   ├── StoresViewModel.swift
│   ├── SyncLogViewModel.swift
│   └── SettingsViewModel.swift
├── Models/
│   ├── Product.swift
│   ├── Store.swift
│   ├── SyncLog.swift
│   ├── SyncEvent.swift
│   └── SubscriptionTier.swift
├── Services/
│   ├── SyncEngine.swift
│   ├── ShopifyAPIClient.swift
│   ├── WooCommerceAPIClient.swift
│   ├── SupabaseService.swift
│   ├── PurchaseManager.swift
│   └── NotificationService.swift
└── Utilities/
    ├── KeychainHelper.swift
    └── Constants.swift
```

## Implementation Flow

1. **Data Models**: Define SwiftData models for Product, Store, SyncLog, SyncEvent
2. **Sync Engine**: Build Actor-based InventorySyncEngine with queue, retry, and parallel channel updates
3. **API Clients**: Implement ShopifyAPIClient (OAuth + REST) and WooCommerceAPIClient (Basic Auth + REST)
4. **Dashboard View**: Stats cards (Total Stock, Low Stock, Sync Status) + Low Stock Alert + Recent Activity
5. **Products View**: Filterable product list with stock level bars and per-channel stock display
6. **Stores View**: Connected stores list + Connect Store flow (Shopify OAuth, WooCommerce API keys)
7. **Sync Log View**: Chronological sync activity with status badges and retry capability
8. **Settings View**: Account, subscription, notifications, policy links, contact support
9. **IAP Integration**: StoreKit 2 PurchaseManager with Free/Starter/Pro/Lifetime tiers
10. **Notifications**: Low stock alerts, sync failure alerts, oversell warnings via APNs
11. **Policy Pages**: Support, Privacy Policy, Terms of Use (for subscription)

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: Blue-to-Cyan gradient (#007AFF → #00C7BE) representing sync/flow
  - Secondary: Purple (#5856D6) for smart/AI features
  - Success: Green (#34C759) — sync OK, stock sufficient
  - Warning: Orange (#FF9500) — low stock
  - Danger: Red (#FF3B30) — oversell, sync failed
  - Background Light: #F2F2F7, Dark: #1C1C1E
- **Typography**: SF Pro (system default), 17pt body, 34pt large titles
- **Layout**: Card-based dashboard, 16pt spacing, 12pt inner padding, max-width 720pt for iPad
- **Animations**: Subtle spring animations on sync status changes, haptic feedback on alerts
- **Tab Bar**: 4 tabs — Dashboard, Products, Stores, Settings (with Sync Log accessible from Dashboard)
- **iPad**: Adaptive layout with sidebar navigation, max-width constraints on content areas

## Code Generation Rules

- No code comments unless explicitly requested
- MVVM pattern: View + ViewModel for each feature module
- Swift Concurrency: async/await + Actor for thread-safe sync engine
- SwiftData for all persistent models with optional attributes and inverse relationships
- Keychain Services for all API tokens and credentials
- No third-party dependencies unless absolutely necessary
- All network calls use URLSession with async/await
- Color-coded stock levels: Green (>20%), Orange (5-20%), Red (<5% or 0)

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.StockSync
- [ ] Deployment Target: iOS 17.0
- [ ] App Icon generated and configured
- [ ] Capabilities: Push Notifications, Background Modes (background fetch)
- [ ] StoreKit 2 configuration for IAP testing
- [ ] Policy pages deployed (Support + Privacy + Terms)
- [ ] Tested on iPhone XS Max and iPad Pro 13-inch (M4)
- [ ] No API keys or secrets in source code
- [ ] App Store metadata prepared (keytext.md)
