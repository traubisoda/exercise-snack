#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="ExerciseSnack"
BUILD_DIR="$PROJECT_DIR/build/release"
DMG_OUTPUT="$BUILD_DIR/$APP_NAME.dmg"

# Require version as argument
if [ -z "${1:-}" ]; then
  echo "Usage: ./gh-release.sh <version>"
  echo "Example: ./gh-release.sh v1.2.0"
  exit 1
fi
VERSION="$1"

# Check we're on the main branch
CURRENT_BRANCH=$(git -C "$PROJECT_DIR" branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Warning: You are on branch '$CURRENT_BRANCH', not 'main'."
  read -rp "Continue anyway? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# Check for uncommitted changes
if ! git -C "$PROJECT_DIR" diff --quiet || ! git -C "$PROJECT_DIR" diff --cached --quiet; then
  echo "Warning: You have uncommitted changes."
  git -C "$PROJECT_DIR" status --short
  read -rp "Continue anyway? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# Ensure gh CLI is available
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is required. Install with: brew install gh"
  exit 1
fi

# Check the tag doesn't already exist
if git -C "$PROJECT_DIR" rev-parse "$VERSION" &>/dev/null; then
  echo "Error: Tag $VERSION already exists"
  exit 1
fi

# Check the DMG was built
if [ ! -f "$DMG_OUTPUT" ]; then
  echo "Error: DMG not found at $DMG_OUTPUT"
  echo "       Run ./release.sh first to build it."
  exit 1
fi

# Prompt for release notes (auto-generate if left empty)
LAST_TAG=$(git -C "$PROJECT_DIR" describe --tags --abbrev=0 2>/dev/null || echo "")
echo ""
echo "==> Enter release notes (leave empty to auto-generate from commits):"
echo "    Press Ctrl-D when done, or just press Enter then Ctrl-D for auto-generate."
NOTES=$(cat 2>/dev/null || true)

if [ -z "$NOTES" ]; then
  echo "==> Auto-generating release notes from commits..."
  if [ -n "$LAST_TAG" ]; then
    NOTES=$(git -C "$PROJECT_DIR" log "$LAST_TAG"..HEAD --pretty=format:"- %s" --no-merges)
  else
    NOTES=$(git -C "$PROJECT_DIR" log --pretty=format:"- %s" --no-merges -20)
  fi
  if [ -z "$NOTES" ]; then
    NOTES="Release $VERSION"
  fi
  echo "$NOTES"
fi

# Create tag and GitHub release
echo ""
echo "==> Creating tag $VERSION..."
git -C "$PROJECT_DIR" tag "$VERSION"
git -C "$PROJECT_DIR" push origin "$VERSION"

echo "==> Creating GitHub release..."
gh release create "$VERSION" "$DMG_OUTPUT" \
  --title "$APP_NAME $VERSION" \
  --notes "$NOTES"

echo ""
echo "==> Release $VERSION published!"
echo "    $(gh release view "$VERSION" --json url -q .url)"
