# Icon Fixes - Notification & System Settings App Icon

## Overview
The Exercise Snack app icon appears as the default macOS placeholder in notifications and System Settings > Notifications, despite having a full AppIcon asset catalog. This PRD addresses ensuring the app icon displays correctly everywhere macOS uses it.

## User Stories

### US-001: Ensure App Icon Displays in Notifications and System Settings
**Priority:** 1
**Description:** As a user, I want to see the Exercise Snack app icon in notifications and System Settings so that I can easily identify the app.

**Acceptance Criteria:**
- [ ] App icon appears correctly in macOS notification banners/alerts (not the default placeholder)
- [ ] App icon appears correctly in System Settings > Notifications list
- [ ] App icon appears correctly in Notification Center history
- [ ] Icon displays at proper resolution on both Retina and non-Retina displays
- [ ] Verified by building, running, and triggering a test notification

**Implementation Notes:**
The root cause is likely one or more of:
1. **Missing `CFBundleIconName` in Info.plist** — While `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` is set in build settings and `GENERATE_INFOPLIST_FILE = YES` should auto-generate it, explicitly adding `CFBundleIconName = AppIcon` to the manual `Info.plist` ensures the key is present in the final merged plist.
2. **Missing `CFBundleIconFile`** — Some macOS subsystems (including notification center) may look for the legacy `CFBundleIconFile` key pointing to an `.icns` file. Consider generating and including an `.icns` file.
3. **Icon PNG dimensions mismatch** — Verify each PNG file in `AppIcon.appiconset` has the exact pixel dimensions expected (e.g., `icon_16x16@2x.png` must be exactly 32x32 pixels).
4. **Code signing** — Unsigned or ad-hoc signed apps may not have their icon recognized by macOS notification subsystem. Ensure the app is signed with a valid identity (even a local development certificate).
5. **Icon cache** — macOS aggressively caches app icons. After fixing, the old cached placeholder may persist until the cache is cleared or the app is re-registered.

Investigate each cause and apply the necessary fixes.
