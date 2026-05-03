# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: Propoze Premium
- **Group ID**: Auto-generated

## Subscription Tiers

### 1. Monthly Subscription (Pro)
- **Reference Name**: Pro Monthly
- **Product ID**: `com.zzoutuo.Propoze.proMonthly`
- **Price**: $9.99 per month
- **Display Name**: Pro Monthly
- **Description**: Unlimited proposals, tracking, branding
- **Localization**: English (US)

### 2. Yearly Subscription (Pro)
- **Reference Name**: Pro Yearly
- **Product ID**: `com.zzoutuo.Propoze.proYearly`
- **Price**: $79.99 per year (33% savings vs monthly)
- **Display Name**: Pro Yearly
- **Description**: Best value - unlimited proposals & tracking
- **Localization**: English (US)

### 3. Lifetime Purchase (Pro)
- **Reference Name**: Lifetime Pro
- **Product ID**: `com.zzoutuo.Propoze.lifetime`
- **Price**: $149.99 one-time
- **Display Name**: Lifetime Pro
- **Description**: Pay once, own forever - no subscription
- **Note**: Available because local-only app has no ongoing API costs for core features

## Free Tier Features
| Feature | Included |
|---------|----------|
| Proposal creation | ✅ Unlimited |
| Proposal sending | ✅ Unlimited |
| Built-in templates | ✅ 3 templates |
| E-signature | ✅ Included |
| PDF export | ✅ Included |
| Brand customization | ❌ Propoze branding |
| Proposal tracking | ❌ |
| Custom templates | ❌ |
| Pricing table | ✅ Basic (3 rows) |
| Client management | ✅ Up to 5 clients |
| AI assistance | ❌ |

## Pro Tier Features (All Free +)
| Feature | Included |
|---------|----------|
| Proposal creation | ✅ Unlimited |
| Proposal sending | ✅ Unlimited |
| Templates | ✅ Unlimited + custom |
| E-signature | ✅ Included |
| PDF export | ✅ Included |
| Brand customization | ✅ Full (remove Propoze branding) |
| Proposal tracking | ✅ Real-time + activity timeline |
| Pricing table | ✅ Unlimited rows + interactive |
| Client management | ✅ Unlimited clients |
| AI assistance | ✅ 10 uses/month |

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to Pro Monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented
