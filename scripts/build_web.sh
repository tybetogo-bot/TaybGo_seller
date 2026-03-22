#!/bin/bash
# Optimized Flutter web build script for TaybGo Seller
# Produces a deployment-ready build under 8 MB
set -e

echo "=== Building Flutter web (release) ==="
flutter build web --release --no-wasm-dry-run -t lib/main_prod.dart --dart-define=ENV=prod

BUILD_DIR="build/web"

echo ""
echo "=== Removing local CanvasKit (loaded from Google CDN instead) ==="
rm -rf "$BUILD_DIR/canvaskit"

echo "=== Removing sourcemaps and debug symbols ==="
rm -f "$BUILD_DIR"/*.map
rm -f "$BUILD_DIR"/*.symbols

echo ""
echo "=== Build size breakdown ==="
echo "Total: $(du -sh "$BUILD_DIR" | cut -f1)"
echo ""
du -sh "$BUILD_DIR"/* 2>/dev/null | sort -rh
echo ""
echo "Done. Output: $BUILD_DIR"
