# Propoze - iOS Development Guide

## Executive Summary

Propoze is a native iOS proposal creation and management app designed for freelancers, small agencies, and consultants. Unlike web-first competitors (Proposify, PandaDoc, Better Proposals), Propoze delivers a mobile-first experience with instant editor loading (<0.5s vs 3-8s), built-in e-signatures via PencilKit, real-time proposal tracking, and complete brand customization at every price tier.

**Product Vision**: Become the go-to proposal tool for mobile-first professionals who need to create, send, track, and sign proposals entirely from their iPhone or iPad.

**Target Audience**: Independent freelancers (~30M), small agencies 1-5 people (~5M), and consultants (~8M) in the US market.

**Key Differentiators**:
- iOS-native: Sub-0.5s editor vs 3-8s web competitors
- Mobile-first: Full editing on iPhone/iPad, not just viewing
- No per-user pricing: Flat pricing regardless of team size
- Built-in e-signature: PencilKit integration, no third-party tool needed
- Unlimited proposals: No "5 per month" traps like Proposify Basic

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| PandaDoc | Full-featured, CRM integrations, G2 4.7/5 | $19-35/user/mo, mobile editing poor, Starter plan limited to 5 templates | Flat pricing, native mobile editor, unlimited templates |
| Proposify | Good tracking, team features | $19-49/user/mo, Basic plan 5 sends/mo, mobile can only view not edit | Unlimited sends, full mobile editing, no per-user cost |
| Better Proposals | Clean UI, affordable entry | $13-19/mo, poor mobile, slow support, 10 sends/mo Starter | Native mobile, faster support, unlimited sends |
| AI Proposal Writer (iOS) | AI generation, App Store presence | $6.99/week, no editor, no signature, no tracking, 4.4/5 (15 ratings) | Full editor, signature, tracking, better value |
| AI Proposal Generator (iOS) | AI-powered, simple form | No editor, no signature, no brand customization, 1 rating | Complete proposal workflow |

## Apple Design Guidelines Compliance

- **Hierarchy**: Dashboard uses status cards with clear visual priority; editor focuses on content
- **Harmony**: SF Pro system fonts, native SwiftUI components, system colors with brand accent
- **Consistency**: Standard iOS navigation patterns (TabView, NavigationStack, sheets)
- **Accessibility**: VoiceOver labels, Dynamic Type support, minimum 44pt touch targets
- **Dark Mode**: Full support with semantic colors, automatic system following
- **iPad Layout**: Responsive layout with max-width 720pt for content, no restrictive sidebar styles
- **Liquid Glass**: Adopt translucent materials for toolbars and cards on iOS 26+
- **PencilKit**: Native Apple Pencil signature experience on iPad

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (PencilKit canvas wrapper)
- **Data**: SwiftData with CloudKit for sync
- **Editor**: InfomaniakRichHTMLEditor (MIT, WYSIWYG HTML editor)
- **PDF**: PDFKit + WKWebView printFormatter
- **Signature**: PencilKit (PKCanvasView)
- **IAP**: StoreKit 2
- **Analytics**: Firebase Analytics
- **Networking**: URLSession
- **Minimum iOS**: 17.0

## Module Structure

```
Propoze/
├── PropozeApp.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── StatusCardView.swift
│   ├── Editor/
│   │   ├── ProposalEditorView.swift
│   │   ├── EditorToolbarView.swift
│   │   └── PricingTableView.swift
│   ├── Templates/
│   │   ├── TemplatePickerView.swift
│   │   └── TemplateCardView.swift
│   ├── Signature/
│   │   └── SignatureView.swift
│   ├── Tracking/
│   │   └── ProposalTrackingView.swift
│   ├── Clients/
│   │   ├── ClientListView.swift
│   │   └── ClientFormView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── BrandThemeView.swift
│   │   ├── PaywallView.swift
│   │   └── ContactSupportView.swift
│   └── Components/
│       ├── StatusBadge.swift
│       └── SearchBar.swift
├── Models/
│   ├── Proposal.swift
│   ├── PricingItem.swift
│   ├── BrandTheme.swift
│   ├── ProposalTemplate.swift
│   └── Client.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── EditorViewModel.swift
│   └── PurchaseManager.swift
├── Services/
│   ├── TemplateEngine.swift
│   ├── PDFExportService.swift
│   └── TrackingService.swift
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

## Implementation Flow

1. Set up SwiftData models (Proposal, PricingItem, BrandTheme, ProposalTemplate, Client)
2. Build navigation architecture (TabView with Proposals, Clients, Stats tabs)
3. Implement Dashboard view with status cards and recent proposals list
4. Integrate InfomaniakRichHTMLEditor for proposal editing
5. Build template system with built-in templates and template picker
6. Implement pricing table component (add/edit/remove line items)
7. Build PencilKit signature view with clear/confirm actions
8. Implement PDF export service (HTML to PDF via WKWebView)
9. Build brand theme customization (colors, logo, company info)
10. Implement client management (CRUD operations)
11. Build proposal tracking view with activity timeline
12. Implement StoreKit 2 purchase manager and paywall
13. Build settings view with policy links and support
14. Add contact support feedback form
15. Test on iPhone and iPad simulators

## UI/UX Design Specifications

### Color Scheme

| Role | Light | Dark | Usage |
|------|-------|------|-------|
| Primary | #2563EB | #3B82F6 | Buttons, active states, headers |
| Secondary | #10B981 | #34D399 | Success, signed status |
| Warning | #F59E0B | #FBBF24 | Pending, expiring soon |
| Danger | #EF4444 | #F87171 | Declined, expired |
| Background | #F8FAFC | #0F172A | Screen background |
| Card | #FFFFFF | #1E293B | Card backgrounds |
| Text Primary | #1E293B | #F1F5F9 | Main text |
| Text Secondary | #64748B | #94A3B8 | Subtitles, metadata |
| Text Disabled | #94A3B8 | #475569 | Disabled states |

### Typography

| Usage | Font | Size | Weight |
|-------|------|------|--------|
| Large Title | SF Pro Display | 28pt | Bold |
| Page Title | SF Pro Display | 22pt | Semibold |
| Section Header | SF Pro Text | 17pt | Semibold |
| Body | SF Pro Text | 15pt | Regular |
| Caption | SF Pro Text | 13pt | Regular |
| Label | SF Pro Text | 11pt | Medium |

### Layout Rules

- Content max width: 720pt on iPad (`.frame(maxWidth: 720).frame(maxWidth: .infinity)`)
- Standard padding: 16pt horizontal, 12pt vertical
- Card corner radius: 12pt
- Status card grid: 2x2 on iPhone, 4x1 on iPad
- Tab bar: 3 tabs (Proposals, Clients, Stats)
- Navigation: NavigationStack with push navigation
- Modals: `.sheet` for editors, signature, templates

### Animations

- Page transitions: iOS native slide
- Button feedback: Scale to 0.95 + UIImpactFeedbackGenerator
- Loading states: Skeleton views, no spinners
- Pull to refresh: Native RefreshControl
- Swipe actions: Left swipe to delete/archive
- Dark mode: Full support, follows system

## Code Generation Rules

- Single responsibility: One feature per module
- MVVM pattern: View + ViewModel for each screen
- SwiftData @Model for all data entities
- All model attributes must be optional or have default values
- All relationships must have inverse relationships
- No comments in code unless explicitly requested
- No per-user pricing logic in app
- PencilKit for signatures (no third-party)
- StoreKit 2 for IAP (no third-party)
- Native SwiftUI components preferred
- iPad layout must use max-width constraint

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.Propoze
2. Verify Deployment Target: iOS 17.0
3. App Icon generated and configured
4. Capabilities configured (CloudKit if needed)
5. StoreKit Configuration file for testing IAP
6. Build succeeds on iPhone simulator
7. Build succeeds on iPad simulator
8. App launches and core features work
9. No API keys or secrets in source code
10. Push to GitHub repository
11. Deploy policy pages to GitHub Pages
12. Generate App Store screenshots
13. Prepare App Store Connect metadata
