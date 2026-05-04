# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Inventory sync across channels (Shopify, WooCommerce) → Network access required
- Push notifications for low stock / sync failure / oversell alerts → Push Notifications capability
- Background sync / periodic inventory refresh → Background Modes (Background Fetch)
- In-App Purchase for subscription tiers (Free/Starter/Pro/Lifetime) → StoreKit (IAP)
- Secure token storage → Keychain Services (no capability needed, framework access)
- API authentication (OAuth, API keys) → Network + Keychain

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | ✅ Configured | Xcode project signing |
| Background Modes (Background Fetch) | ✅ Configured | Xcode project signing |
| In-App Purchase | ✅ Configured | StoreKit 2 (no entitlement needed for iOS 17+) |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| APNs Certificate | ⏳ Pending | 1. Go to Apple Developer → Certificates → Create APNs certificate 2. Upload to Supabase Edge Functions for push notification delivery |
| StoreKit Configuration | ⏳ Pending | 1. Create StoreKit Configuration File in Xcode 2. Add subscription groups and products per price.md 3. Test IAP flow in Simulator |

## No Configuration Needed

- iCloud / CloudKit — Not required (using Supabase as backend)
- HealthKit — Not applicable
- Camera / Photo Library — Not needed
- Location Services — Not needed
- Apple Watch — Not in v1 scope
- Siri — Not in v1 scope
- Sign in with Apple — Not in v1 scope (using email auth via Supabase)
- HomeKit — Not applicable
- Maps — Not applicable

## Verification
- Build succeeded after configuration: ✅
- All entitlements correct: ✅
