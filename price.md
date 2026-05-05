# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: FollowUpNow Premium
- **Group ID**: FollowUpNow_Premium

## Subscription Tiers

### 1. Pro - One-Time Purchase
- **Reference Name**: Pro Lifetime
- **Product ID**: `com.zzoutuo.FollowUpNow.pro`
- **Price**: $14.99 one-time
- **Display Name**: Pro Lifetime
- **Description**: Unlock unlimited clients, AI follow-ups, and more
- **Localization**: English (US)

### 2. Pro+ Monthly Subscription
- **Reference Name**: Pro+ Monthly
- **Product ID**: `com.zzoutuo.FollowUpNow.proplus.monthly`
- **Price**: $3.99 per month
- **Display Name**: Pro+ Monthly
- **Description**: Cloud sync, smart suggestions, and priority support
- **Localization**: English (US)

### 3. Pro+ Yearly Subscription
- **Reference Name**: Pro+ Yearly
- **Product ID**: `com.zzoutuo.FollowUpNow.proplus.yearly`
- **Price**: $29.99 per year (37% savings vs monthly)
- **Display Name**: Pro+ Yearly
- **Description**: Best value - cloud sync and smart features
- **Localization**: English (US)

## Free Tier Limits
- Max 10 clients
- Max 5 active follow-up reminders
- Basic notification reminders
- Manual follow-up content writing
- 1 follow-up template
- Simple pipeline view

## Pro Tier Features (One-time $14.99)
- Unlimited clients
- Unlimited follow-up reminders
- AI follow-up content generation (on-device Apple Foundation Models)
- Unlimited follow-up templates
- Interaction history timeline
- Notification action buttons (Call/Text/Snooze/Done)
- Contact auto-import from iOS Contacts
- Data export (CSV/PDF)
- Notification privacy mode

## Pro+ Tier Features ($3.99/month or $29.99/year)
- All Pro features included
- Cloud AI generation (GPT-4o-mini fallback, API cost coverage)
- iCloud cross-device sync
- Smart follow-up suggestions (interaction frequency analysis)
- Batch follow-up operations
- Custom notification sounds
- Priority customer support

## Free Trial
- **Duration**: No separate free trial (free tier serves as perpetual trial)
- **Type**: Freemium model

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Restore purchases functionality implemented
- [ ] Free tier clearly communicates limitations
