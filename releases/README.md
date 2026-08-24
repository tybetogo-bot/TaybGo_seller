# TybeToGo Seller App - Releases

## About
TybeToGo Vendor App - Restaurant management and order handling application for sellers/vendors.

**Package Name:** `teybatseller`
**Current Version:** `1.0.15+16`

---

## Available Artifacts

### Prod Split APKs

| File | Architecture | Target Devices |
|------|--------------|----------------|
| `taybgo-seller-v1.0.15+16-2026-08-24-prod-arm64-v8a.apk` | ARM 64-bit | Most modern Android phones (2017+), Samsung Galaxy S8+, Pixel 2+, OnePlus 5+ |
| `taybgo-seller-v1.0.15+16-2026-08-24-prod-armeabi-v7a.apk` | ARM 32-bit | Older Android phones, budget devices, some tablets |
| `taybgo-seller-v1.0.15+16-2026-08-24-prod-x86_64.apk` | x86 64-bit | Android emulators, Intel-based tablets, Chromebooks |

### Dev Split APKs
| File | Architecture | Target Use |
|------|--------------|------------|
| `taybgo-seller-v1.0.15+16-2026-08-24-dev-arm64-v8a.apk` | ARM 64-bit | Internal testing on most modern Android phones |
| `taybgo-seller-v1.0.15+16-2026-08-24-dev-armeabi-v7a.apk` | ARM 32-bit | Internal testing on older Android phones |
| `taybgo-seller-v1.0.15+16-2026-08-24-dev-x86_64.apk` | x86 64-bit | Internal testing on emulators and Chromebooks |

### Latest Web Build
| File | Description |
|------|-------------|
| `taybgo-seller-v1.0.13+14-2026-08-20-prod-web.zip` | Zipped production web build matching the deployed hosting release. |

---

## Which APK Should I Download?

1. **For most phones:** Download **arm64-v8a**.
2. **For older/budget phones:** Download **armeabi-v7a**.
3. **For emulators/testing:** Download **x86_64**.

### How to check your device architecture:
1. Go to Settings > About Phone
2. Look for "CPU" or "Processor" information
3. Or use an app like "CPU-Z" from Play Store

---

## Installation Instructions

1. Download the appropriate APK for your device
2. Enable "Install from Unknown Sources" in your device settings
3. Open the downloaded APK file
4. Follow the on-screen installation prompts
5. Launch the app and sign in with your vendor credentials

---

## Build Information

- **Built with:** Flutter
- **Min SDK:** Android 5.0 (API 21)
- **Target SDK:** Android 16 (API 36)
- **Maps configuration:** Release builds inject the restricted key with `--dart-define=GOOGLE_MAPS_API_KEY=...`

---

## Changelog

### v1.0.15 (24 August, 2026)
- Restored address autocomplete and coordinate lookup in Flutter Web through the Google Maps JavaScript Places library
- Added compatibility fallback for Google projects that still use the established Places JavaScript service
- Centralized Google Maps configuration while preserving the existing native Places REST behavior for Android and iOS
- Published signed dev and prod split APKs for ARM 64-bit, ARM 32-bit, and x86 64-bit devices

### v1.0.14 (24 August, 2026)
- Added runtime-managed seller authentication that selects password or verification-code sign-in according to the latest account policy
- Added password-based seller login while preserving OTP support when enabled by TaybGo
- Added a required-update experience for unsupported app versions
- Synchronized Terms and Privacy links with backend-managed application settings
- Improved authentication errors, validation, and safe fallback behavior while preserving short and international phone-number support
- Published dated dev and prod split APKs for ARM 64-bit, ARM 32-bit, and x86 64-bit devices

### v1.0.13 (20 August, 2026)
- Added a translated What's New page under Help & Support
- Renamed Pending Orders to New Orders and included pending, accepted, and driver-search orders
- Added a compact status filter to the Home New Orders section, with All selected by default
- Improved seller login for short, formatted, and pasted international phone numbers
- Fixed intermittent order-total updates during manual order creation
- Limited delivery vehicle choices to Bike and Car while other pricing policies are unavailable
- Automatically hides the guided tour after the seller has orders
- Published dev/prod split APKs and deployed the production web release to `https://sellertaybgo.web.app`

### v1.0.12 (19 July, 2026)
- Added country-aware phone parsing and E.164 normalization for seller login
- Automatically detects a pasted international number's country and keeps the national part editable
- Handles `+` and `00` international prefixes, trunk zeros, formatted numbers, and Arabic/Persian digits
- Updated login, profile, and About release metadata to version 1.0.12+13 dated 19 July 2026
- Published signed prod AAB, dev/prod split APKs, and a production web archive
- Deployed the production web build to `https://sellertaybgo.web.app`

### v1.0.11 (17 July, 2026)
- Standardized seller-facing monetary values on the euro symbol across dashboards, orders, earnings, menu customizations, help content, and PDF receipts
- Updated login, profile, and About release metadata to version 1.0.11+12 dated 17 July 2026
- Aligned Firebase web configuration and hosting with the `sellertaybgo` project
- Published signed prod AAB, dev/prod split APKs, and a production web archive
- Deployed the production web build to `https://sellertaybgo.web.app`

### v1.0.9 (10 July, 2026)
- Redesigned the seller profile flow with a more compact restaurant header, grouped sections, and a combined edit profile experience
- Added delivery-enabled support across restaurant state, profile screens, and restaurant settings
- Switched seller order actions to backend-provided allowed status options and kept accepted orders actionable
- Removed redundant delivery details copy from the create-order payment section while keeping API-backed pricing in the order summary
- Published dated dev and prod split APK release artifacts for the new version

### v1.0.8 (19 May, 2026)
- Made the entire app fully responsive across phone, tablet, and desktop form factors (NavigationRail on tablet/desktop, content max-width per screen, ScreenUtil scale clamped on wide screens)
- Required at least one item before a seller can create an order (the warning dialog no longer allows bypass)
- Published dated prod AAB, dev/prod split APKs, and prod web release artifacts
### v1.0.7 (13 May, 2026)
- Fixed repeated restaurant settings edits by preserving restaurant IDs after update responses
- Aligned restaurant settings update payloads with the seller restaurant API contract
- Added missing working-hours translations across supported locales
- Published dated prod web and dev/prod split APK release artifacts

### v1.0.5 (11 May, 2026)
- Added Firebase Crashlytics integration for Android and iOS
- Added dev-only mobile Crashlytics test controls for non-fatal and forced crash reports
- Aligned iOS bundle identifier and Crashlytics dSYM upload configuration with Firebase
- Published dated prod web and dev/prod split APK release artifacts

### v1.0.1 (16 April, 2026)
- Added support for expired order status handling
- Added reorder action for expired orders in history and order details
- Refreshed About page release metadata for the 16 April 2026 release
- Added seller role/account-type guardrails in auth and seller-only flows
- Published dated prod web and dev/prod split APK release artifacts

### v1.0.0 (Initial Release)
- Restaurant management features
- Order handling and tracking
- Menu management with Cloudinary integration
- QR code scanning
- PDF receipt generation
- Multi-language support

---

## Troubleshooting

**App won't install:**
- Make sure you have enough storage space
- Enable "Install from Unknown Sources"
- Try downloading the Universal APK if split APK doesn't work

**App crashes on startup:**
- Clear app cache and data
- Reinstall the app
- Make sure you're using the correct APK for your device architecture

---

*Last updated: 2026-08-24*
