# TaybGo Seller

Restaurant management and order handling app for TaybGo sellers. Built with Flutter, targeting Android, iOS, and Web.

## Prerequisites

- Flutter SDK `^3.10.4`
- Dart SDK `^3.10.4`
- Java 17 (for Android builds)
- Firebase CLI (for web deployment)
- Android Studio / Xcode (for native builds)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable, riverpod_generator)
dart run build_runner build --delete-conflicting-outputs
```

## Flavors

The app has two flavors configured via `--dart-define` and Android product flavors:

| Flavor | App Name       | API Base URL                                    | Package ID Suffix |
|--------|----------------|-------------------------------------------------|-------------------|
| `dev`  | Seller Dev     | `https://dev.taybgo.com`                        | `.dev`            |
| `prod` | TaybGo Seller  | `https://taybat-backend-dev.onrender.com`       | _(none)_          |

### Running

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart --dart-define=ENV=dev

# Production
flutter run --flavor prod -t lib/main_prod.dart --dart-define=ENV=prod

# Web (no --flavor flag needed)
flutter run -d chrome -t lib/main_dev.dart --dart-define=ENV=dev
```

### Building

```bash
# Android APK (dev)
flutter build apk --flavor dev -t lib/main_dev.dart --dart-define=ENV=dev

# Android APK (prod)
flutter build apk --flavor prod -t lib/main_prod.dart --dart-define=ENV=prod

# Web (prod)
flutter build web -t lib/main_prod.dart --dart-define=ENV=prod

# iOS (prod)
flutter build ios --flavor prod -t lib/main_prod.dart --dart-define=ENV=prod
```

### VS Code

Open the Run & Debug panel to use pre-configured launch configurations:
- **Dev** - Debug on device with dev API
- **Dev (Profile)** - Profile mode with dev API
- **Prod** - Debug on device with prod API
- **Prod (Release)** - Release mode with prod API
- **Dev (Web)** / **Prod (Web)** - Chrome targets

## Project Structure

```
lib/
├── main.dart                  # Shared entry point
├── main_dev.dart              # Dev entry point
├── main_prod.dart             # Prod entry point
├── firebase_options.dart      # Firebase config (generated)
├── app/
│   └── router/                # GoRouter navigation
├── core/
│   ├── config/                # App config, env config, constants
│   ├── network/               # Dio API client & interceptors
│   ├── providers/             # Riverpod dependency injection
│   ├── services/              # Push notifications, etc.
│   ├── theme/                 # Material theme
│   ├── i18n/                  # Internationalization
│   ├── errors/                # Error handling
│   ├── currency/              # Currency formatting
│   └── data/                  # Core data models
├── features/
│   ├── auth/                  # Phone OTP authentication
│   ├── splash/                # Splash screen
│   ├── onboarding/            # Seller onboarding flow
│   ├── home/                  # Dashboard
│   ├── orders/                # Order management
│   ├── menu/                  # Menu & category management
│   ├── restaurant/            # Restaurant settings
│   ├── coupons/               # Coupon management
│   ├── profile/               # User profile
│   ├── notifications/         # Push notifications
│   ├── addresses/             # Address management
│   ├── public_menu/           # Public-facing menu
│   ├── tour/                  # Interactive app tour
│   ├── support/               # Support features
│   ├── documentation/         # In-app docs
│   └── knowledge_base/        # Knowledge base
├── shared/                    # Shared UI widgets
└── packages/
    └── phone_otp_auth_ui/     # Phone OTP auth UI package
```

## Tech Stack

| Category            | Libraries                                          |
|---------------------|----------------------------------------------------|
| State Management    | Riverpod, riverpod_generator                       |
| Navigation          | GoRouter                                           |
| Networking          | Dio                                                |
| Local Storage       | SharedPreferences, Hive                            |
| Firebase            | firebase_core, firebase_messaging                  |
| Maps & Location     | google_maps_flutter, geolocator, geocoding         |
| Image Handling      | image_picker, cached_network_image, Cloudinary     |
| Code Generation     | freezed, json_serializable, build_runner            |
| PDF                 | pdf, printing                                      |
| AI                  | google_generative_ai (Gemini)                      |
| Scanner             | mobile_scanner, google_mlkit_text_recognition      |

## Firebase Deployment (Web)

```bash
# Build and deploy web to Firebase Hosting
flutter build web -t lib/main_prod.dart --dart-define=ENV=prod
firebase deploy --only hosting
```

## Code Generation

After modifying any `@freezed`, `@JsonSerializable`, or `@riverpod` annotated classes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## App Icons

```bash
dart run flutter_launcher_icons
```
