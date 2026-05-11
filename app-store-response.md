# App Store Review Response Template

## Issue: Guideline 3.1.2(c) - Subscriptions Compliance

### What was fixed:

1. **GitHub Pages Enabled** - Policy pages (Privacy Policy, Terms of Use, Support) are now deployed and accessible at:
   - Privacy Policy: https://asunnyboy861.github.io/Propoze/privacy.html
   - Terms of Use (EULA): https://asunnyboy861.github.io/Propoze/terms.html
   - Support Page: https://asunnyboy861.github.io/Propoze/support.html

2. **PaywallView Updated** - Added required subscription compliance information:
   - Subscription Details section with auto-renewal terms
   - Functional link to Privacy Policy
   - Functional link to Terms of Use (EULA)

3. **App Store Metadata Updated** - Added EULA and Privacy Policy links to App Description in keytext.md

### App Store Connect Actions Required:

1. **Privacy Policy URL**: Set to `https://asunnyboy861.github.io/Propoze/privacy.html` in App Store Connect > App Information > Privacy Policy field

2. **App Description**: Update with the content from keytext.md (includes EULA and Privacy Policy links)

3. **EULA**: Using standard Apple EULA (link included in App Description)

### Screen Recording Checklist:

Record the following in the app:
1. Open app → Go to Settings tab
2. Tap "Upgrade to Pro" → PaywallView appears
3. Scroll down to show "Subscription Details" section
4. Tap "Privacy Policy" link → Opens in Safari
5. Tap "Terms of Use (EULA)" link → Opens in Safari
6. Go back to app → Scroll to bottom of Settings → Tap "Privacy Policy" and "Terms of Use" links in Legal section
