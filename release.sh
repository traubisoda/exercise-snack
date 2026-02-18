#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT="ExerciseSnack.xcodeproj"
SCHEME="ExerciseSnack"
APP_NAME="ExerciseSnack"
BUILD_DIR="$PROJECT_DIR/build/release"
DMG_DIR="$BUILD_DIR/dmg-staging"
DMG_OUTPUT="$BUILD_DIR/$APP_NAME.dmg"

echo "==> Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Building $APP_NAME (Release)..."
xcodebuild -project "$PROJECT_DIR/$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=NO \
  build

APP_PATH="$(find "$BUILD_DIR/DerivedData" -name "$APP_NAME.app" -type d | head -1)"
if [ -z "$APP_PATH" ]; then
  echo "Error: $APP_NAME.app not found in build output"
  exit 1
fi

echo "==> Found app at: $APP_PATH"

# Remove quarantine attribute if present
xattr -cr "$APP_PATH" 2>/dev/null || true

echo "==> Packaging DMG..."
mkdir -p "$DMG_DIR"
cp -R "$APP_PATH" "$DMG_DIR/"

# Add a symlink to /Applications for drag-to-install
ln -s /Applications "$DMG_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_DIR" \
  -ov \
  -format UDZO \
  "$DMG_OUTPUT"

rm -rf "$DMG_DIR"

DMG_SIZE=$(du -h "$DMG_OUTPUT" | cut -f1 | xargs)
echo ""
echo "==> DMG created: $DMG_OUTPUT ($DMG_SIZE)"
echo "    Run ./gh-release.sh <version> to publish a GitHub release."
