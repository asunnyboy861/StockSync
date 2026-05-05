# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | StockSync |
| **Git URL** | git@github.com:asunnyboy861/StockSync.git |
| **Repo URL** | https://github.com/asunnyboy861/StockSync |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/StockSync/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/StockSync/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/StockSync/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/StockSync/terms.html | ⏳ Pending |

**Note**: Terms of Use required for IAP subscription apps.

## Repository Structure

### Main App Repository
```
StockSync/
├── StockSync/                        # iOS App Source Code
│   ├── StockSync.xcodeproj/          # Xcode Project
│   ├── StockSync/                    # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Dashboard/
│   │   │   ├── Products/
│   │   │   ├── Stores/
│   │   │   ├── SyncLog/
│   │   │   ├── Settings/
│   │   │   └── Components/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Utilities/
│   └── ...
├── docs/                             # Policy pages for GitHub Pages
│   ├── index.html                    # Landing Page
│   ├── support.html                  # Support Page
│   ├── privacy.html                  # Privacy Policy
│   └── terms.html                    # Terms of Use
├── .github/workflows/                # GitHub Actions
│   └── deploy.yml                    # Deploys /docs to GitHub Pages
├── us.md                             # English Development Guide
├── keytext.md                        # App Store Metadata
├── capabilities.md                   # Capabilities Configuration
├── icon.md                           # App Icon Details
├── price.md                          # Pricing Configuration
└── nowgit.md                         # This File
```

## Deployment Checklist

- [x] Xcode project builds successfully
- [x] SwiftData models configured
- [x] StoreKit 2 IAP products defined
- [x] Keychain integration for secure token storage
- [x] Policy pages created (support, privacy, terms)
- [x] Git repository initialized and committed
- [ ] GitHub repository created and pushed
- [ ] GitHub Pages enabled for policy pages
- [ ] App Store Connect app record created
- [ ] TestFlight build uploaded
- [ ] App Store metadata submitted
- [ ] Screenshots generated
