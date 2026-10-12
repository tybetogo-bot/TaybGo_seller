# Seller iOS Firebase setup

Updated October 12, 2026.

## Background sound update (October 12, 2026)

Build 27 uses a 29-second excerpt of Android's `notif_background.mp3` for iOS remote notifications, with a short fade at the end. It is bundled as `notif_sound.caf`, matching the seller APNs payload in merged backend PR #86. Existing installs retain their previous tone at that filename. The original short tone is preserved as `notif_sound_1.caf` for foreground notifications; repeat variants (3/5/7) are unchanged. Android sounds are unchanged.

The iOS file is 16-bit PCM CAF at 44.1 kHz, stereo. All bundled notification sounds must stay below Apple's 30-second limit. The IPA validator checks their durations and exact source hashes. Upload and install build 27 to hear the longer background tone; a backend-only change cannot replace audio in an installed app. Physical-device playback remains a required check.

## Confirmed registration

- Firebase project: `sellertaybgo` (same project as Android and web).
- Project number / FCM sender ID: `188938523542`.
- Apple app nickname: `TaybGo Seller iOS`.
- Bundle ID: `com.taybgo.seller`.
- Firebase iOS app ID: `1:188938523542:ios:1e5c62e1094e84646343b7`.
- Official Firebase configuration saved at `ios/Runner/GoogleService-Info.plist`; configuration values independently matched against Firebase CLI SDK configuration.

## Local configuration

The native plist and Dart iOS Firebase options match the registration. Runner includes the plist in Copy Bundle Resources. Crashlytics symbol-upload configuration targets the new iOS Firebase app. RunnerTests identifiers also use `com.taybgo.seller`.

Firebase method swizzling is enabled. FlutterFire owns messaging callbacks; the redundant native permission request and custom Messaging delegate were removed. Dart waits briefly for APNs readiness before requesting an FCM token. Existing token-refresh subscription remains active.

The custom AppDelegate uses FlutterImplicitEngineDelegate plugin registration and Info.plist uses FlutterSceneDelegate for the UIScene lifecycle. Push entitlements are connected for Debug, Profile and Release. The source entitlement uses development APNs; distribution provisioning must supply production APNs and the final IPA must be inspected.

## Verification

- Plist and Xcode project syntax validation passed.
- Native/Dart identity, plist resource membership, all three entitlement settings, swizzling and scene configuration checks passed.
- Full suite: 56 tests passed, including an offline test for all 17 bundled UI font weights. These tests do not prove APNs delivery.
- Full Dart analysis: zero errors, 13 warnings and 73 informational diagnostics.
- Native production archive and App Store IPA export succeeded for replacement 1.0.22 (27). Export signature, App Store profile, production APNs, disabled debugging, Firebase resources, bundled fonts and arm64 binaries were inspected. The backend sound PR #86 is merged; live deployment was not checked during IPA preparation. Physical-device playback and Apple upload of build 27 remain unverified.

## Apple and backend follow-up

Firebase Cloud Messaging HTTP v1 is enabled. The user uploaded the production APNs authentication key; the console confirms key ID `5TTLPZXPX6` and team `Z8ZLXJ9696`. The development-key field remains empty.

Runner is configured for automatic signing with team `Z8ZLXJ9696`. Automatic provisioning and export succeeded; the exported artifact uses Apple Distribution signing for the configured team. The APNs .p8 file was not copied into the repository. Firebase's general-settings App Store ID and Team ID have not been configured.

Verify the backend sends seller iOS events through `sellertaybgo`, including device-token ownership and cleanup on logout/account switching. Test physical-device foreground, background and cold-start notification behavior after signing and APNs configuration. Camera/photo permission purposes and permission-handler flags are configured. Poppins/Cairo fonts and licenses are bundled; Arabic PDF receipts now use bundled Cairo fonts. The locked OCR dependency requires iOS 15.5, which is now configured throughout the native build. Build 26 includes the supplied Maps/Places key; autocomplete returned HTTP 200 with five suggestions.

Release configuration requires `-t lib/main_prod.dart --dart-define=ENV=prod` and a valid `GOOGLE_MAPS_API_KEY`. Replacement version/build is `1.0.22 (27)`. App Store Connect availability/processing for build 27 remains unverified. Existing unrelated release-file deletions are excluded from this source change. The PR also aligns the in-app release label with build 27; the previously exported IPA predates that label-only correction.

The native launch screen uses the existing TaybGo logo. Crashlytics dSYMs are preserved in the archive and delivered separately; remote symbol upload is opt-in with `UPLOAD_CRASHLYTICS_SYMBOLS=YES`. Local release evidence and outstanding checks for build 27 are in ignored `build/testflight/background-sound-27/RELEASE_NOTES.md`. Release artifacts and the Maps release-defines JSON are not committed.

## TestFlight notification investigation (October 11, 2026)

The production backend has Firebase enabled and seller credentials for sellertaybgo. Seller account ID 3 has server-created notifications but no iOS DeviceToken. The two iOS tokens present belong to customer accounts. No backend configuration was changed.

Build 25 used firebase_messaging 15.2.10, whose launch-notification observer can miss UIScene's later plugin registration. The replacement uses firebase_messaging 16.7.0, firebase_core 4.15.0 and firebase_crashlytics 5.4.0. AppDelegate calls FLTFirebaseMessagingPlugin.configureNotificationCenterDelegate before launch returns, as required by the current plugin's UIScene integration. Real-device token registration and delivery must still be verified after installation.

The original Places release define was empty. The user supplied an existing key; the app's Places New autocomplete endpoint returned HTTP 200 and five Vienna suggestions. The key is supplied from an ignored release-defines JSON file, rather than committed to source. Use scripts/ios/build_release.sh with the defines JSON and export-options plist to prevent future production builds with a missing key.
