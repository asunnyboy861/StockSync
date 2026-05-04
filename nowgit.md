# StockSync - NowGit Deployment Guide

## Repository Information

- **App Name**: StockSync
- **Bundle ID**: com.zzoutuo.StockSync
- **Platform**: iOS 17.0+
- **Language**: Swift 5.9+ / SwiftUI
- **Repository**: https://github.com/zzoutuo/StockSync

## Architecture Overview

```
StockSync/
├── StockSync/
│   ├── StockSyncApp.swift          # App entry point
│   ├── ContentView.swift           # Main TabView
│   ├── Models/                     # SwiftData models
│   │   ├── Product.swift
│   │   ├── Store.swift
│   │   ├── SyncLog.swift
│   │   ├── SyncEvent.swift
│   │   └── SubscriptionTier.swift
│   ├── ViewModels/                 # MVVM ViewModels
│   │   ├── DashboardViewModel.swift
│   │   ├── ProductsViewModel.swift
│   │   ├── StoresViewModel.swift
│   │   ├── SyncLogViewModel.swift
│   │   └── SettingsViewModel.swift
│   ├── Views/                      # SwiftUI Views
│   │   ├── Dashboard/
│   │   ├── Products/
│   │   ├── Stores/
│   │   ├── SyncLog/
│   │   ├── Settings/
│   │   └── Components/
│   ├── Services/                   # Business logic
│   │   ├── SyncEngine.swift
│   │   ├── ShopifyAPIClient.swift
│   │   ├── WooCommerceAPIClient.swift
│   │   └── PurchaseManager.swift
│   └── Utilities/
│       ├── KeychainHelper.swift
│       └── Constants.swift
├── docs/                           # Policy pages
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── us.md                           # Development guide
├── nowgit.md                       # This file
├── price.md                        # Pricing configuration
├── keytext.md                      # App Store metadata
├── capabilities.md                 # App capabilities
└── icon.md                         # Icon specifications
```

## GitHub Repository Setup

### Initial Push

```bash
cd /Volumes/ORICO-APFS/app/20260504/StockSync
git init
git add .
git commit -m "Initial commit: StockSync iOS app"
git branch -M main
git remote add origin git@github.com:zzoutuo/StockSync.git
git push -u origin main
```

### Branch Strategy

- `main` — Production-ready code
- `develop` — Active development
- `feature/*` — Feature branches
- `hotfix/*` — Emergency fixes

## GitHub Pages Deployment

Policy pages are served via GitHub Pages from the `docs/` directory.

### Setup Steps

1. Go to repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: `main` / `/docs`
4. Save

### URLs

- **Support**: https://zzoutuo.github.io/StockSync/support.html
- **Privacy Policy**: https://zzoutuo.github.io/StockSync/privacy.html
- **Terms of Use**: https://zzoutuo.github.io/StockSync/terms.html

## CI/CD Pipeline

### GitHub Actions (Optional)

```yaml
name: Build
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: |
          cd StockSync
          xcodebuild build -scheme StockSync -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | Yes |
| `SHOPIFY_CLIENT_ID` | Shopify OAuth client ID | Yes |
| `WOOCOMMERCE_CONSUMER_KEY` | WooCommerce API key | Per store |

## Deployment Checklist

- [x] Xcode project builds successfully
- [x] SwiftData models configured
- [x] StoreKit 2 IAP products defined
- [x] Keychain integration for secure token storage
- [x] Policy pages created (support, privacy, terms)
- [ ] GitHub repository created and pushed
- [ ] GitHub Pages enabled for policy pages
- [ ] App Store Connect app record created
- [ ] TestFlight build uploaded
- [ ] App Store metadata submitted
- [ ] Screenshots generated

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.0.0 | 2026-05-04 | Initial release with Shopify + WooCommerce sync |
