# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Propoze |
| **Git URL** | git@github.com:asunnyboy861/Propoze.git |
| **Repo URL** | https://github.com/asunnyboy861/Propoze |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | Enabled (from /docs folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Propoze/ | Active |
| Support | https://asunnyboy861.github.io/Propoze/support.html | Active |
| Privacy Policy | https://asunnyboy861.github.io/Propoze/privacy.html | Active |
| Terms of Use | https://asunnyboy861.github.io/Propoze/terms.html | Active |

Note: Terms of Use required for IAP subscription apps.

## Repository Structure

```
Propoze/
├── Propoze/                       # iOS App Source Code
│   ├── Propoze.xcodeproj/         # Xcode Project
│   ├── Propoze/                   # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── ViewModels/
│   │   ├── Utilities/
│   │   └── ...
│   └── ...
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html                 # Landing Page
│   ├── support.html               # Support Page
│   ├── privacy.html               # Privacy Policy
│   └── terms.html                 # Terms of Use
├── us.md                          # English Development Guide
├── keytext.md                     # App Store Metadata
├── capabilities.md                # Capabilities Configuration
├── icon.md                        # App Icon Details
├── price.md                       # Pricing Configuration
└── nowgit.md                      # This File
```
