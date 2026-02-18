## Codebase Patterns
- App icon configuration requires `CFBundleIconName` in Info.plist for macOS subsystems (notifications, System Settings) to find the icon
- When using `GENERATE_INFOPLIST_FILE = YES` with a manual `INFOPLIST_FILE`, both the manual plist AND `INFOPLIST_KEY_*` build settings are merged into the final Info.plist
- `ASSETCATALOG_COMPILER_APPICON_NAME` alone is not sufficient — `CFBundleIconName` must also be set

---

## 2026-02-17 - US-001: Ensure App Icon Displays in Notifications and System Settings
- What was implemented:
  - Added `CFBundleIconName = AppIcon` to `ExerciseSnack/Info.plist`
  - Added `INFOPLIST_KEY_CFBundleIconName = AppIcon` build setting to both Debug and Release target configurations in `project.pbxproj`
  - This ensures macOS notification banners, System Settings > Notifications, and Notification Center all resolve the app icon from the asset catalog
- Files changed:
  - `ExerciseSnack/Info.plist` (modified — added CFBundleIconName key)
  - `ExerciseSnack.xcodeproj/project.pbxproj` (modified — added INFOPLIST_KEY_CFBundleIconName to Debug and Release configs)
- **Learnings for future iterations:**
  - `ASSETCATALOG_COMPILER_APPICON_NAME` tells the asset catalog compiler which icon set to compile, but `CFBundleIconName` in Info.plist is what macOS subsystems (notifications, System Settings, LaunchServices) use to resolve the app icon at runtime
  - For LSUIElement (menu bar) apps, the icon issue is more visible because the app doesn't appear in the Dock where the icon would normally be cached/registered
  - Belt-and-suspenders: set `CFBundleIconName` in both the manual Info.plist AND via `INFOPLIST_KEY_CFBundleIconName` build setting to ensure it appears in the final merged plist regardless of Xcode's plist generation behavior
  - After building, verify the icon is in the bundle: check for `AppIcon.icns` in `Contents/Resources/` and `CFBundleIconName` in the built `Contents/Info.plist` using PlistBuddy
---
