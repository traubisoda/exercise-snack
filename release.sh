#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT="ExerciseSnack.xcodeproj"
SCHEME="ExerciseSnack"
APP_NAME="ExerciseSnack"
BUILD_DIR="$PROJECT_DIR/build/release"
DMG_DIR="$BUILD_DIR/dmg-staging"
DMG_OUTPUT="$BUILD_DIR/$APP_NAME.dmg"

# Require version as argument
if [ -z "${1:-}" ]; then
  echo "Usage: ./release.sh <version>"
  echo "Example: ./release.sh v1.2.0"
  exit 1
fi
VERSION="$1"

# Ensure gh CLI is available
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is required. Install with: brew install gh"
  exit 1
fi

# Check the tag doesn't already exist
if git rev-parse "$VERSION" &>/dev/null; then
  echo "Error: Tag $VERSION already exists"
  exit 1
fi

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

# Prompt for release notes (auto-generate if left empty)
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
echo ""
echo "==> Enter release notes (leave empty to auto-generate from commits):"
echo "    Press Ctrl-D when done, or just press Enter then Ctrl-D for auto-generate."
NOTES=$(cat 2>/dev/null || true)

if [ -z "$NOTES" ]; then
  echo "==> Auto-generating release notes from commits..."
  if [ -n "$LAST_TAG" ]; then
    NOTES=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s" --no-merges)
  else
    NOTES=$(git log --pretty=format:"- %s" --no-merges -20)
  fi
  if [ -z "$NOTES" ]; then
    NOTES="Release $VERSION"
  fi
  echo "$NOTES"
fi

# Create tag and GitHub release
echo ""
echo "==> Creating tag $VERSION..."
git tag "$VERSION"
git push origin "$VERSION"

echo "==> Creating GitHub release..."
gh release create "$VERSION" "$DMG_OUTPUT" \
  --title "$APP_NAME $VERSION" \
  --notes "$NOTES"

echo ""
echo "==> Release $VERSION published!"
echo "    $(gh release view "$VERSION" --json url -q .url)"
