# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | FollowUpNow |
| **Git URL** | git@github.com:asunnyboy861/FollowUpNow.git |
| **Repo URL** | https://github.com/asunnyboy861/FollowUpNow |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/FollowUpNow/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/FollowUpNow/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/FollowUpNow/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/FollowUpNow/terms.html | ⏳ Pending |

## Repository Structure

### Main App Repository
```
FollowUpNow/
├── FollowUpNow/                        # iOS App Source Code
│   ├── FollowUpNow.xcodeproj/          # Xcode Project
│   ├── FollowUpNow/                    # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Dashboard/
│   │   │   ├── Contacts/
│   │   │   ├── Pipeline/
│   │   │   ├── FollowUp/
│   │   │   ├── Templates/
│   │   │   ├── Settings/
│   │   │   └── Onboarding/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── FollowUpNowApp.swift
│   │   └── ContentView.swift
│   └── ...
├── docs/                               # Policy Pages for GitHub Pages
│   ├── index.html                      # Landing Page
│   ├── support.html                    # Support Page
│   ├── privacy.html                    # Privacy Policy
│   └── terms.html                      # Terms of Use
├── .github/workflows/                  # GitHub Actions
│   └── deploy.yml                      # GitHub Pages deployment
├── us.md                               # English Development Guide
├── keytext.md                          # App Store Metadata
├── capabilities.md                     # Capabilities Configuration
├── icon.md                             # App Icon Details
├── price.md                            # Pricing Configuration
├── nowgit.md                           # This File
└── .gitignore
```
