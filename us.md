# FollowUpNow - iOS Development Guide

## Executive Summary

FollowUpNow is a lightweight, business-focused client follow-up reminder app for iOS. Unlike traditional CRMs that overwhelm small businesses with features they never use, FollowUpNow does exactly three things: simple pipeline tracking, conversation notes, and smart follow-up reminders with AI-generated content.

**Target Audience**: Freelancers, solo consultants, small business owners (1-5 people), real estate agents, insurance agents, sales professionals, and contractors who need to maintain client relationships without the overhead of a full CRM.

**Key Differentiators**:
- Not a CRM — a pure follow-up tool (anti-overkill positioning)
- AI-generated follow-up content using Apple Foundation Models (on-device, privacy-first)
- Notification action buttons (Call / Text / Snooze / Done) directly from the lock screen
- Simple 3-stage pipeline (New → Contacted → Converted) — no complex sales funnels
- Template system for common follow-up scenarios
- 30-second onboarding — zero learning curve

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| FollowUp (Never Lose Touch) | 4.6 rating, AI follow-ups, contact sync, daily goals | Personal-focused (not business), no pipeline, no templates, no notification actions | Business-focused pipeline + templates + notification actions + on-device AI |
| Always Be In Contact | iCloud sync, Apple Watch, Lead/Prospect/Sold categories | Outdated UI (iOS 13 era), no AI, no templates, limited customization | Modern SwiftUI design + AI content generation + template system |
| Revere | 4.7 rating, people-focused notes, check-in reminders, Siri support | Personal relationships only, no pipeline, no business context, subscription required | Business pipeline + AI content + one-time purchase option + notification actions |

## Apple Design Guidelines Compliance

- **HIG Navigation**: Tab-based navigation with 4 tabs (Home, People, Pipeline, Settings) following standard iOS patterns
- **HIG Notifications**: Local notifications with actionable categories (Call, Text, Snooze, Done) per Apple notification design guidelines
- **HIG Data Entry**: Minimal form fields, smart defaults, date picker for follow-up scheduling
- **HIG Privacy**: All data stored locally via SwiftData, no third-party analytics, on-device AI only
- **HIG Accessibility**: Dynamic Type support, VoiceOver labels on all interactive elements, high contrast compatibility
- **HIG Haptics**: UIImpactFeedbackGenerator for task completion, UINotificationFeedbackGenerator for alerts
- **Liquid Glass Ready**: Navigation bars and tab bars adopt translucent material backgrounds per iOS 26 design language

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), SwiftData for persistence
- **Data**: SwiftData (@Model) with local storage only
- **Notifications**: UserNotifications framework with actionable categories
- **AI**: Apple Foundation Models (on-device, iOS 26+) with fallback to preset templates
- **Contacts**: Contacts Framework for system contact import
- **Messaging**: MessageUI for iMessage/email integration
- **Payments**: StoreKit 2 for in-app purchases
- **Minimum iOS**: 17.0

## Module Structure

```
FollowUpNow/
├── FollowUpNow/
│   ├── FollowUpNowApp.swift
│   ├── Models/
│   │   ├── Client.swift
│   │   ├── FollowUp.swift
│   │   ├── Interaction.swift
│   │   ├── FollowUpTemplate.swift
│   │   └── Enums.swift
│   ├── Views/
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── StatCard.swift
│   │   │   └── FollowUpRow.swift
│   │   ├── Contacts/
│   │   │   ├── ContactsView.swift
│   │   │   ├── ClientDetailView.swift
│   │   │   └── AddClientView.swift
│   │   ├── Pipeline/
│   │   │   └── PipelineView.swift
│   │   ├── FollowUp/
│   │   │   ├── AddFollowUpView.swift
│   │   │   └── FollowUpDetailView.swift
│   │   ├── Templates/
│   │   │   └── TemplatesView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── PaywallView.swift
│   │   │   └── ContactSupportView.swift
│   │   └── Onboarding/
│   │       └── OnboardingView.swift
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift
│   │   ├── ContactsViewModel.swift
│   │   └── PipelineViewModel.swift
│   ├── Services/
│   │   ├── NotificationManager.swift
│   │   ├── AIFollowUpService.swift
│   │   ├── TemplateService.swift
│   │   ├── PurchaseManager.swift
│   │   └── ContactImportService.swift
│   └── Utilities/
│       ├── Constants.swift
│       └── Extensions.swift
├── FollowUpNow.xcodeproj/
└── FollowUpNowTests/
```

## Implementation Flow

1. Set up SwiftData models (Client, FollowUp, Interaction, FollowUpTemplate)
2. Build app navigation skeleton with TabView (4 tabs)
3. Implement Dashboard view with stat cards and follow-up list
4. Implement Contacts view with search and CRUD operations
5. Implement Add/Edit FollowUp flow with date picker and channel selection
6. Implement NotificationManager with actionable categories
7. Implement Pipeline view with 3-column kanban layout
8. Implement AI follow-up content generation service
9. Implement Template system with default templates
10. Implement PurchaseManager with StoreKit 2
11. Implement Paywall view with feature comparison
12. Implement Settings view with policy links and preferences
13. Implement Contact Support view with feedback backend
14. Implement Onboarding flow (3 pages)
15. Implement Contact import from iOS Contacts
16. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary Blue: #007AFF (trust, professional)
  - Success Green: #34C759 (completed, converted)
  - Warning Orange: #FF9500 (pending, contacted)
  - Danger Red: #FF3B30 (overdue, urgent)
  - Accent Purple: #5856D6 (AI features)
  - Background Light: #FFFFFF / #F2F2F7
  - Background Dark: #000000 / #1C1C1E

- **Typography**: SF Pro system font, Dynamic Type support
  - Title: .title, .title2
  - Body: .body, .callout
  - Caption: .caption, .caption2

- **Layout**:
  - Card-based design with .ultraThinMaterial backgrounds
  - 16pt horizontal padding, 12pt vertical spacing
  - Max content width 720pt for iPad (centered)
  - Swipe actions on follow-up rows (leading: Done, trailing: Snooze + Delete)

- **Animations**:
  - Follow-up completion: card slides out with green checkmark
  - Snooze: card shake with clock rotation
  - Overdue: red pulse bar on left side of card
  - Pipeline drag: card lifts with shadow and magnetic snap
  - AI generation: purple glow with text appearing character by character

- **Tab Bar**: 4 tabs — Home (house.fill), People (person.2.fill), Pipeline (chart.bar.fill), Settings (gearshape.fill)

## Code Generation Rules

- Use SwiftUI declarative syntax exclusively, no UIKit mixing
- SwiftData with @Model macro, no CoreData NSManagedObject
- MVVM + Clean Architecture layering (View → ViewModel → Service → Data)
- Protocol-Oriented Design for all services
- async/await for all asynchronous operations, no completion handlers
- Localize all user-visible strings with String(localized:)
- UNNotificationCategory with action buttons for notifications
- @Attribute(.unique) on all model IDs
- Apple Foundation Models for AI, fallback to preset templates
- Privacy-first: all data local, no third-party analytics
- No code comments unless explicitly requested

## Build & Deployment Checklist

- [ ] Xcode project configured with Bundle ID com.zzoutuo.FollowUpNow
- [ ] Deployment target set to iOS 17.0
- [ ] App icon generated and added to Asset Catalog
- [ ] Push Notifications capability enabled
- [ ] StoreKit 2 configuration file created for IAP testing
- [ ] Build succeeds on iPhone simulator
- [ ] Build succeeds on iPad simulator
- [ ] All policy pages deployed to GitHub Pages
- [ ] App Store metadata prepared (keytext.md)
- [ ] Screenshots captured for iPhone and iPad
