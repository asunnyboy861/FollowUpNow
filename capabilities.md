# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Notifications (提醒/通知) → Push Notifications capability
- Contacts import (联系人导入) → Contacts Framework
- Background refresh (后台刷新) → Background Modes
- In-App Purchase (订阅/会员/Pro/Pro+) → StoreKit 2
- iCloud sync (云同步) → CloudKit (Pro+ tier only, optional)
- MessageUI (iMessage/邮件) → MessageUI Framework
- AI content generation → Apple Foundation Models (on-device)

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications (Local) | ✅ Configured | Code-based (UNUserNotificationCenter) |
| Contacts Framework | ✅ Configured | Info.plist NSContactsUsageDescription |
| Background Modes (Background Fetch) | ✅ Configured | Info.plist UIBackgroundModes |
| MessageUI | ✅ Configured | Framework import |
| StoreKit 2 | ✅ Configured | Framework import |
| Apple Foundation Models | ✅ Configured | Framework import (iOS 26+) |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| iCloud / CloudKit | ⏳ Pending (Pro+ only) | 1. Enable iCloud capability in Xcode 2. Create CloudKit container 3. Switch to NSPersistentCloudKitContainer 4. Add iCloud entitlement to App ID |

## No Configuration Needed

- HealthKit — Not applicable
- Camera / Photo Library — Not applicable
- Location Services — Not applicable
- Siri — Not applicable
- Apple Watch — Not applicable (future consideration)
- Sign in with Apple — Not applicable
- HomeKit — Not applicable
- Maps — Not applicable

## Required Info.plist Keys

| Key | Value |
|-----|-------|
| NSContactsUsageDescription | "FollowUpNow needs access to your contacts to help you set up client follow-ups." |
| NSUserNotificationsUsageDescription | "FollowUpNow sends reminders so you never miss a follow-up." |
| UIBackgroundModes | ["fetch"] |

## Verification
- Build succeeded after configuration: Pending (Phase 4)
- All entitlements correct: Pending (Phase 4)
