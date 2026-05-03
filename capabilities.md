# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Proposal creation and editing (no special capability needed)
- E-signature via PencilKit (no special capability needed)
- PDF export (no special capability needed)
- SwiftData local storage (no special capability needed)
- StoreKit 2 for IAP (no special capability needed)
- CloudKit for sync (mentioned in guide but optional for MVP)
- Network access for tracking/feedback (outgoing network needed)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| StoreKit 2 (IAP) | ✅ Configured | Code-level, no entitlement needed |
| PencilKit (Signature) | ✅ Configured | Framework import, no entitlement needed |
| SwiftData | ✅ Configured | Framework import, no entitlement needed |
| PDFKit | ✅ Configured | Framework import, no entitlement needed |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| iCloud / CloudKit | ⏳ Pending | 1. Add iCloud capability in Xcode 2. Select CloudKit container 3. Configure container identifier as iCloud.com.zzoutuo.Propoze 4. Enable SwiftData CloudKit sync in code |

## No Configuration Needed
- Push Notifications (not needed for MVP)
- HealthKit (not applicable)
- Camera / Photo Library (not needed for MVP)
- Location Services (not applicable)
- Apple Watch (not in MVP scope)
- Siri (not in MVP scope)
- Background Modes (not needed for MVP)

## Verification
- Build succeeded after configuration: ⏳ Pending (will verify in Phase 6)
- All entitlements correct: ✅ (no special entitlements needed for MVP)
