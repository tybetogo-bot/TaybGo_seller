# TybeToGo Seller App - Releases

## About
TybeToGo Vendor App - Restaurant management and order handling application for sellers/vendors.

**Package Name:** `teybatseller`
**Current Version:** `1.0.1+2`

---

## Available APKs

### Universal APK
| File | Description |
|------|-------------|
| `taybgo-seller-v1.0.1+2-prod-release.apk` | Universal APK that works on all Android devices. Larger file size but maximum compatibility. |

### Split APKs (Recommended for smaller file size)
| File | Architecture | Target Devices |
|------|--------------|----------------|
| `taybgo-seller-v1.0.1+2-prod-arm64-v8a.apk` | ARM 64-bit | Most modern Android phones (2017+), Samsung Galaxy S8+, Pixel 2+, OnePlus 5+ |
| `taybgo-seller-v1.0.1+2-prod-armeabi-v7a.apk` | ARM 32-bit | Older Android phones, budget devices, some tablets |
| `taybgo-seller-v1.0.1+2-prod-x86_64.apk` | x86 64-bit | Android emulators, Intel-based tablets, Chromebooks |

### Dev Split APKs
| File | Architecture | Target Use |
|------|--------------|------------|
| `taybgo-seller-v1.0.1+2-dev-arm64-v8a.apk` | ARM 64-bit | Internal testing on most modern Android phones |
| `taybgo-seller-v1.0.1+2-dev-armeabi-v7a.apk` | ARM 32-bit | Internal testing on older Android phones |
| `taybgo-seller-v1.0.1+2-dev-x86_64.apk` | x86 64-bit | Internal testing on emulators and Chromebooks |

---

## Which APK Should I Download?

1. **If unsure:** Download the **Universal APK** - it works on all devices
2. **For most modern phones:** Download **arm64-v8a** - smaller and optimized
3. **For older/budget phones:** Download **armeabi-v7a**
4. **For emulators/testing:** Download **x86_64**

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
- **Target SDK:** Android 14 (API 34)

---

## Changelog

### v1.0.1 (14 April, 2026)
- Added support for expired order status handling
- Added reorder action for expired orders in history and order details
- Refreshed About page release metadata for this build

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

*Last updated: 2026-04-14*
