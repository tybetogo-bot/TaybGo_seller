# TybeToGo Seller App - Releases

## About
TybeToGo Vendor App - Restaurant management and order handling application for sellers/vendors.

**Package Name:** `teybatseller`
**Current Version:** `1.0.9+10`

---

## Available Artifacts

### Play Store Bundle
| File | Description |
|------|-------------|
| `taybgo-seller-v1.0.8+9-2026-05-19-prod-store.aab` | Signed Android App Bundle for Play Store upload. |

### Prod Split APKs

| File | Architecture | Target Devices |
|------|--------------|----------------|
| `taybgo-seller-v1.0.8+9-2026-05-19-prod-arm64-v8a.apk` | ARM 64-bit | Most modern Android phones (2017+), Samsung Galaxy S8+, Pixel 2+, OnePlus 5+ |
| `taybgo-seller-v1.0.8+9-2026-05-19-prod-armeabi-v7a.apk` | ARM 32-bit | Older Android phones, budget devices, some tablets |
| `taybgo-seller-v1.0.8+9-2026-05-19-prod-x86_64.apk` | x86 64-bit | Android emulators, Intel-based tablets, Chromebooks |

### Dev Split APKs
| File | Architecture | Target Use |
|------|--------------|------------|
| `taybgo-seller-v1.0.9+10-2026-07-10-dev-arm64-v8a.apk` | ARM 64-bit | Internal testing on most modern Android phones |
| `taybgo-seller-v1.0.9+10-2026-07-10-dev-armeabi-v7a.apk` | ARM 32-bit | Internal testing on older Android phones |
| `taybgo-seller-v1.0.9+10-2026-07-10-dev-x86_64.apk` | x86 64-bit | Internal testing on emulators and Chromebooks |

### Web Build
| File | Description |
|------|-------------|
| `taybgo-seller-v1.0.8+9-2026-05-19-prod-web.zip` | Zipped production web build matching the deployed hosting release. |

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

---

## Changelog

### v1.0.9 (10 July, 2026)
- Redesigned the seller profile flow with a more compact restaurant header, grouped sections, and a combined edit profile experience
- Added delivery-enabled support across restaurant state, profile screens, and restaurant settings
- Switched seller order actions to backend-provided allowed status options and kept accepted orders actionable
- Removed redundant delivery details copy from the create-order payment section while keeping API-backed pricing in the order summary
- Published dated dev split APK release artifacts for the new version

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

*Last updated: 2026-07-10*
