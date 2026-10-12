#!/bin/sh
set -eu

# Local release exports preserve dSYMs in the xcarchive. Opt in to remote
# Crashlytics uploads in CI/Xcode when network access and credentials are ready.
if [ "${UPLOAD_CRASHLYTICS_SYMBOLS:-NO}" != "YES" ]; then
  echo 'Crashlytics: preserving local dSYMs; set UPLOAD_CRASHLYTICS_SYMBOLS=YES to upload.'
  exit 0
fi

# Flutter plugins may use CocoaPods or Swift Package Manager.
upload_script="${PODS_ROOT:-}/FirebaseCrashlytics/upload-symbols"
if [ ! -x "$upload_script" ]; then
  upload_script="$SRCROOT/../build/ios/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
fi
if [ ! -x "$upload_script" ]; then
  upload_script="${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
fi
if [ ! -x "$upload_script" ]; then
  echo 'error: Firebase Crashlytics upload-symbols was not found.' >&2
  exit 1
fi

firebase_plist="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/GoogleService-Info.plist"
for symbols in "$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME" "$DWARF_DSYM_FOLDER_PATH/App.framework.dSYM"; do
  if [ -d "$symbols" ]; then
    "$upload_script" --build-phase --validate -gsp "$firebase_plist" -- "$symbols"
    "$upload_script" --build-phase -gsp "$firebase_plist" -- "$symbols"
  fi
done
