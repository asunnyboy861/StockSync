# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: StockSync Premium
- **Group ID**: StockSyncPremium

## Subscription Tiers

### 1. Monthly Starter
- **Reference Name**: Starter Monthly
- **Product ID**: `com.zzoutuo.StockSync.starter.monthly`
- **Price**: $9.99 per month
- **Display Name**: Starter Monthly
- **Description**: 2 stores, 500 SKUs, auto sync
- **Localization**: English (US)

### 2. Yearly Starter
- **Reference Name**: Starter Yearly
- **Product ID**: `com.zzoutuo.StockSync.starter.yearly`
- **Price**: $89.99 per year (25% savings vs monthly)
- **Display Name**: Starter Yearly
- **Description**: 2 stores, 500 SKUs, auto sync
- **Localization**: English (US)

### 3. Monthly Pro
- **Reference Name**: Pro Monthly
- **Product ID**: `com.zzoutuo.StockSync.pro.monthly`
- **Price**: $24.99 per month
- **Display Name**: Pro Monthly
- **Description**: Unlimited stores, real-time sync
- **Localization**: English (US)

### 4. Yearly Pro
- **Reference Name**: Pro Yearly
- **Product ID**: `com.zzoutuo.StockSync.pro.yearly`
- **Price**: $229.99 per year (23% savings vs monthly)
- **Display Name**: Pro Yearly
- **Description**: Unlimited stores, real-time sync
- **Localization**: English (US)

### 5. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.StockSync.lifetime`
- **Price**: $499.99 one-time
- **Display Name**: Lifetime Access
- **Description**: All Pro features forever
- **Localization**: English (US)

## Free Tier (No IAP Required)
- 1 store connection
- 50 SKU limit
- Manual sync only
- Basic dashboard
- 7-day sync log history

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial on Starter or Pro subscription (auto-converts to paid)
- **Applies to**: First subscription purchase only

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included (if applicable)
- [ ] Restore purchases functionality implemented
