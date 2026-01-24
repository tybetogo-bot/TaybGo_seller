# APK Build Guide for TybeToGo Seller App

This guide will help you build release APKs for the TybeToGo Seller app on your local machine.

---

## Prerequisites

Before building, ensure you have:

- [ ] Flutter SDK installed ([Install Flutter](https://docs.flutter.dev/get-started/install))
- [ ] Android SDK installed (via Android Studio)
- [ ] Java JDK 11 or higher
- [ ] Git installed

### Verify Installation

```bash
flutter doctor
```

Make sure all checkmarks are green for Android development.

---

## Step 1: Clone/Pull Latest Code

```bash
# If you haven't cloned yet
git clone https://github.com/abdulzilah/tybetogoSeller.git
cd tybetogoSeller

# If already cloned, pull latest
git pull origin main
```

---

## Step 2: Get Dependencies

```bash
flutter pub get
```

---

## Step 3: Build APKs

### Option A: Build Universal APK (Works on all devices)

```bash
flutter build apk --release
```

**Output location:** `build/app/outputs/flutter-apk/app-release.apk`

### Option B: Build Split APKs (Smaller, architecture-specific)

```bash
flutter build apk --split-per-abi --release
```

**Output locations:**
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (Modern phones)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (Older phones)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (Emulators)

### Option C: Build Both (Recommended)

```bash
# Build universal first
flutter build apk --release

# Then build split APKs
flutter build apk --split-per-abi --release
```

---

## Step 4: Copy APKs to Releases Folder

```bash
# Create releases folder if it doesn't exist
mkdir -p releases

# Copy universal APK
cp build/app/outputs/flutter-apk/app-release.apk releases/tybetogoSeller-v1.0.0-release.apk

# Copy split APKs
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk releases/tybetogoSeller-v1.0.0-arm64-v8a.apk
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk releases/tybetogoSeller-v1.0.0-armeabi-v7a.apk
cp build/app/outputs/flutter-apk/app-x86_64-release.apk releases/tybetogoSeller-v1.0.0-x86_64.apk
```

---

## Step 5: Commit and Push to GitHub

```bash
# Add all APKs
git add releases/

# Commit with message
git commit -m "Add APK releases v1.0.0 (universal and split)"

# Push to repository
git push origin main
```

---

## Quick One-Liner Script

Copy and paste this entire block to build everything at once:

```bash
flutter pub get && \
flutter build apk --release && \
flutter build apk --split-per-abi --release && \
mkdir -p releases && \
cp build/app/outputs/flutter-apk/app-release.apk releases/tybetogoSeller-v1.0.0-release.apk && \
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk releases/tybetogoSeller-v1.0.0-arm64-v8a.apk && \
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk releases/tybetogoSeller-v1.0.0-armeabi-v7a.apk && \
cp build/app/outputs/flutter-apk/app-x86_64-release.apk releases/tybetogoSeller-v1.0.0-x86_64.apk && \
echo "✅ All APKs built and copied successfully!"
```

---

## Updating Version Numbers

When releasing a new version:

1. **Update `pubspec.yaml`:**
   ```yaml
   version: 1.0.1+2  # format: major.minor.patch+buildNumber
   ```

2. **Update file names in copy commands:**
   ```bash
   # Change v1.0.0 to your new version
   cp build/app/outputs/flutter-apk/app-release.apk releases/tybetogoSeller-v1.0.1-release.apk
   ```

3. **Update `releases/README.md`** with new changelog entry

---

## Build Troubleshooting

### "Flutter not found"
```bash
# Add Flutter to PATH (replace with your Flutter path)
export PATH="$PATH:/path/to/flutter/bin"
```

### "Android SDK not found"
```bash
# Set Android SDK path
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### "Gradle build failed"
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### "Java version error"
Make sure you're using JDK 11 or higher:
```bash
java -version
```

### Build takes too long
First build is slow. Subsequent builds are faster. Be patient!

---

## APK Signing (Optional - For Play Store)

For Play Store releases, you need to sign your APK:

1. **Generate a keystore:**
   ```bash
   keytool -genkey -v -keystore ~/tybetogoSeller-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tybetogoSeller
   ```

2. **Create `android/key.properties`:**
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=tybetogoSeller
   storeFile=/path/to/tybetogoSeller-release.jks
   ```

3. **Update `android/app/build.gradle`** to use the keystore

---

## File Size Reference

Approximate APK sizes:
| APK Type | Expected Size |
|----------|---------------|
| Universal | ~50-80 MB |
| arm64-v8a | ~25-40 MB |
| armeabi-v7a | ~20-35 MB |
| x86_64 | ~25-40 MB |

---

## Need Help?

- Flutter Docs: https://docs.flutter.dev/deployment/android
- Android Build Docs: https://developer.android.com/studio/build

---

*Last updated: 2026-01-24*
