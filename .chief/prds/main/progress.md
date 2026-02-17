## Codebase Patterns
- See `.chief/prds/excercise-snack/progress.md` for comprehensive patterns
- Reminder offset uses minutes-before-the-hour stored as Int in UserDefaults (0, 5, or 10)
- Combine `combineLatest` can take up to 3 publishers — used for workStartHour + workEndHour + reminderOffset
- `UNNotificationSettings.alertStyle` detects Alerts vs Banners — `.alert` means persistent, `.banner` means auto-dismiss
- Use `x-apple.systempreferences:com.apple.Notifications-Settings.extension` URL to open Notifications settings pane
- Custom notification sounds: bundle an .aiff file in Resources, reference with `UNNotificationSound(named: UNNotificationSoundName("filename.aiff"))`
- The project now has a PBXResourcesBuildPhase (A6000002) — add resource files there (not PBXSourcesBuildPhase)
- Next available pbxproj IDs: A1000008 (build file), A200000B (file ref)
- Asset catalogs use `lastKnownFileType = folder.assetcatalog` in PBXFileReference and go in PBXResourcesBuildPhase
- For macOS 11+ app icons, provide full-bleed square PNGs (no rounded rect mask) — macOS applies the squircle mask automatically

---

## 2026-02-17 - US-001: Notification Offset Configuration
- What was implemented:
  - Added `reminderOffset` property to `SettingsManager` persisted via UserDefaults (default: 0)
  - Added "Notifications" section to `SettingsView` with a picker: "On the hour" (0), "5 minutes early" (5), "10 minutes early" (10)
  - Updated `NotificationManager.scheduleTodayNotifications()` to apply offset by subtracting `offset * 60` seconds from each hour's base fire date
  - Updated Combine observation to include `$reminderOffset` so changing the offset triggers immediate rescheduling
  - Status text automatically shows correct offset time because it reads `nextTriggerDate()` from the actual trigger
  - Snoozed notifications remain unaffected (they use `UNTimeIntervalNotificationTrigger`, a relative delay)
  - Increased settings window height from 320 to 400
- Files changed:
  - `ExerciseSnack/SettingsManager.swift` (modified — added reminderOffset property, key, default)
  - `ExerciseSnack/SettingsView.swift` (modified — added Notifications section with offset picker, increased height)
  - `ExerciseSnack/NotificationManager.swift` (modified — offset-aware scheduling, Combine observation includes offset)
- **Learnings for future iterations:**
  - `Date.addingTimeInterval()` with negative value is a clean way to shift a date backwards (offset minutes before the hour)
  - The status text needed no changes because it already reads `nextTriggerDate()` from the actual triggers — the offset is baked into the trigger's fire date
  - Snooze is naturally unaffected because it uses `UNTimeIntervalNotificationTrigger` (relative delay), not calendar-based scheduling
  - `combineLatest` on `Publisher` supports up to 3 publishers natively (no need for nested combineLatest)
---

## 2026-02-17 - US-001: Fully Visible Notification Style Warning with Step-by-Step Instructions
- What was implemented:
  - Replaced the single truncated button ("⚠ Notifications auto-dismiss. Click to fix...") with a multi-line warning display in the menu bar dropdown
  - Warning now shows the problem explanation: "Notifications disappear before you can tap 'Do it now' or 'Snooze'"
  - Added numbered step-by-step instructions: 1) Open System Settings, 2) Go to Notifications, 3) Find Exercise Snack, 4) Change style: Banners → Alerts
  - Each line uses a `Text` view with `.disabled(true)` for non-interactive display in the standard menu
  - Dividers separate the problem description, instructions, and action buttons
  - Renamed button from truncated text to clear "Open Notification Settings"
  - "Dismiss" button remains available
- Files changed:
  - `ExerciseSnack/ExerciseSnackApp.swift` (modified — replaced single warning button with multi-line Text items and clear action buttons)
- **Learnings for future iterations:**
  - In a standard `MenuBarExtra` (menu style), `Text("...").disabled(true)` renders as non-interactive disabled menu items — useful for displaying multi-line informational content
  - Each `Text` item in a menu bar dropdown is inherently single-line, so multi-line content must be split across multiple `Text` items
  - `Divider()` between sections creates visual grouping within the menu
  - No need to switch to `.menuBarExtraStyle(.window)` for this use case — the standard menu style handles it well with multiple Text items
---

## 2026-02-17 - US-002: Notification Chime Sound
- What was implemented:
  - Bundled a pleasant chime sound (Glass.aiff from macOS system sounds) as `chime.aiff` in the app
  - Added PBXResourcesBuildPhase to the Xcode project (the project previously had no resources phase)
  - Replaced `UNNotificationSound.default` with `UNNotificationSound(named: "chime.aiff")` for both regular and snoozed notifications
  - The chime plays automatically when notifications are delivered and respects system DND/Focus mode (handled by the notification framework)
- Files changed:
  - `ExerciseSnack/chime.aiff` (new — bundled Glass system sound, a gentle pleasant chime)
  - `ExerciseSnack/NotificationManager.swift` (modified — added static chimeSound, replaced .default with custom sound)
  - `ExerciseSnack.xcodeproj/project.pbxproj` (modified — added PBXResourcesBuildPhase, file reference, build file for chime.aiff)
- **Learnings for future iterations:**
  - The Xcode project originally had no PBXResourcesBuildPhase — it had to be created and added to the target's buildPhases list
  - `UNNotificationSound(named: UNNotificationSoundName("filename.aiff"))` looks for the file in the app bundle's Resources directory
  - System DND/Focus mode compliance is automatic — `UNUserNotificationCenter` handles sound suppression when Focus mode is active
  - macOS system sounds at `/System/Library/Sounds/` are good sources for pleasant, well-designed notification tones
  - Resource files need: PBXFileReference (with `lastKnownFileType = audio.aiff`), PBXBuildFile (in Resources), PBXGroup children entry, and PBXResourcesBuildPhase files entry
---

## 2026-02-17 - US-003: Application Logo
- What was implemented:
  - Created a custom app icon with a green gradient background, white running stick figure, and yellow lightning bolt accent
  - Created `Assets.xcassets` with `AppIcon.appiconset` containing all 10 required macOS icon sizes (16x16 through 512x512@2x = 1024x1024)
  - Added asset catalog to Xcode project (PBXFileReference, PBXBuildFile in Resources, PBXGroup, PBXResourcesBuildPhase)
  - Build produces `AppIcon.icns` in the app bundle automatically from the asset catalog
  - The icon is a full-bleed square PNG — macOS applies the rounded-rect (squircle) mask automatically
- Files changed:
  - `ExerciseSnack/Assets.xcassets/Contents.json` (new — asset catalog root)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/Contents.json` (new — icon set configuration with all 10 macOS sizes)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/icon_*.png` (new — 10 icon PNGs from 16x16 to 1024x1024)
  - `ExerciseSnack.xcodeproj/project.pbxproj` (modified — added Assets.xcassets file reference and build file)
- **Learnings for future iterations:**
  - macOS app icons need 10 images: 5 sizes (16, 32, 128, 256, 512) × 2 scales (1x, 2x)
  - For macOS 11+, provide full-bleed square images — the system applies the squircle mask; do NOT pre-apply a rounded-rect mask
  - Asset catalogs use `lastKnownFileType = folder.assetcatalog` in PBXFileReference
  - The `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` build setting was already configured — just needed the actual asset catalog
  - Xcode compiles the asset catalog into `Assets.car` and `AppIcon.icns` in the app bundle automatically
  - Pillow's `Image.resize()` with `Image.LANCZOS` produces high-quality downscaled icon variants from a 1024x1024 source
---
