## Codebase Patterns
- This is a native Swift/SwiftUI macOS menu bar app using Xcode project (not SPM)
- Build with: `xcodebuild -project ExerciseSnack.xcodeproj -scheme ExerciseSnack -configuration Debug build`
- App entry point: `ExerciseSnack/ExerciseSnackApp.swift` using `@main` and SwiftUI `App` protocol
- LSUIElement=YES set via Info.plist and INFOPLIST_KEY_LSUIElement build setting for menu-bar-only behavior
- Menu bar UI uses SwiftUI `MenuBarExtra` with SF Symbol `figure.run`
- Deployment target: macOS 14.0 (Sonoma)
- Bundle ID: com.exercisesnack.app
- Settings persistence: `SettingsManager` singleton with `@Published` properties backed by `UserDefaults`
- Settings window: Opened via `openWindow(id: "settings")` using a SwiftUI `Window` scene
- When adding new .swift files: update 4 places in pbxproj (PBXBuildFile, PBXFileReference, PBXGroup children, PBXSourcesBuildPhase files)
- Next available pbxproj IDs: A1000006 (build file), A2000009 (file ref)
- Exercise suggestions: `ExerciseSuggestionProvider` singleton provides non-repeating exercise selection via `suggestionsForDay(count:)`
- Notifications: `NotificationManager` singleton handles UNUserNotificationCenter scheduling, permission requests, and daily rescheduling
- NotificationManager observes SettingsManager changes via Combine and auto-reschedules

---

## 2026-02-17 - US-001: Menu Bar App Shell
- What was implemented:
  - Created Xcode project from scratch (project.pbxproj, Info.plist, entitlements)
  - Implemented SwiftUI menu bar app with `MenuBarExtra` using `figure.run` SF Symbol
  - Added Quit button with keyboard shortcut (Cmd+Q)
  - Configured LSUIElement=YES for no-Dock-icon behavior
  - Set minimum deployment target to macOS 14.0
- Files changed:
  - `ExerciseSnack.xcodeproj/project.pbxproj` (new)
  - `ExerciseSnack/ExerciseSnackApp.swift` (new)
  - `ExerciseSnack/Info.plist` (new)
  - `ExerciseSnack/ExerciseSnack.entitlements` (new)
  - `.gitignore` (new)
- **Learnings for future iterations:**
  - The Xcode project was created manually (no xcodegen/tuist available) — when adding new .swift files, they must be added to both the PBXFileReference and PBXBuildFile sections in project.pbxproj, and referenced in the Sources build phase and the ExerciseSnack group
  - `MenuBarExtra` is the SwiftUI way to create menu bar apps (macOS 13+)
  - Use unique hex IDs in pbxproj (A1xxxxxx for build files, A2xxxxxx for file refs, etc.)
---

## 2026-02-17 - US-002: Working Hours Configuration
- What was implemented:
  - Created `SettingsManager` singleton with `@Published` properties for workStartHour, workEndHour, snoozeDuration backed by `UserDefaults`
  - Created `SettingsView` with hour pickers (0-23) and validation (end hour must be after start hour)
  - Added "Settings..." menu item to the menu bar dropdown that opens a settings window
  - Settings window uses SwiftUI `Window` scene with `openWindow(id:)` API
  - Default working hours: 9:00-17:00, default snooze: 10 minutes
- Files changed:
  - `ExerciseSnack/SettingsManager.swift` (new)
  - `ExerciseSnack/SettingsView.swift` (new)
  - `ExerciseSnack/ExerciseSnackApp.swift` (modified — added Settings menu item and Window scene)
  - `ExerciseSnack.xcodeproj/project.pbxproj` (modified — added new source files)
- **Learnings for future iterations:**
  - Use `@Environment(\.openWindow)` and `Window("title", id: "id")` scene to open settings windows from menu bar apps
  - `NSApplication.shared.activate(ignoringOtherApps: true)` is needed to bring the settings window to front since menu bar apps don't have normal activation
  - `UserDefaults.register(defaults:)` sets defaults without overwriting existing values — good for first-launch defaults
  - `.formStyle(.grouped)` gives macOS-native grouped form appearance in settings
  - The `SettingsManager.shared` singleton pattern allows any future component to observe settings changes via `@ObservedObject`
---

## 2026-02-17 - US-003: Hourly Notification Scheduling
- What was implemented:
  - Created `NotificationManager` singleton that uses `UNUserNotificationCenter` to schedule local notifications
  - Requests notification permission on first launch (called from `ExerciseSnackApp.init()`)
  - Schedules notifications at top of each hour within working hours (e.g., 9-17 → 10:00, 11:00, ..., 17:00)
  - Only schedules future notifications for the current day (skips past hours)
  - Reschedules daily via a midnight timer, and on settings changes via Combine observation
  - Notification titles use encouraging tone (5 random variants)
  - Notification bodies suggest specific exercises with encouraging messages (10 suggestions)
  - Settings changes (working hours) trigger automatic rescheduling with debounce
- Files changed:
  - `ExerciseSnack/NotificationManager.swift` (new)
  - `ExerciseSnack/ExerciseSnackApp.swift` (modified — added NotificationManager init and permission request)
  - `ExerciseSnack.xcodeproj/project.pbxproj` (modified — added NotificationManager.swift)
- **Learnings for future iterations:**
  - `UNUserNotificationCenter` doesn't require any special entitlements for local notifications (no sandbox entitlement needed)
  - Use `UNCalendarNotificationTrigger` with `repeats: false` for one-time date-based notifications
  - Notification identifiers like `exercise-snack-{hour}` allow easy management of per-hour notifications
  - Combine `$property.combineLatest()` with `.dropFirst().debounce()` is a clean pattern for reacting to settings changes without triggering on initial load
  - `requestAuthorization` should be called early (app init) — scheduling only happens after permission is granted
---

## 2026-02-17 - US-004: Exercise Suggestions
- What was implemented:
  - Created `ExerciseSuggestions.swift` with `ExerciseSuggestion` struct and `ExerciseSuggestionProvider` singleton
  - Provider contains 12 exercises with specific rep counts and encouraging messages
  - `suggestionsForDay(count:)` returns non-repeating consecutive exercise selections
  - Tracks last used index per day to avoid consecutive repeats
  - Updated `NotificationManager.scheduleTodayNotifications()` to pre-generate all suggestions for the day at once using the provider, ensuring no consecutive repeats
  - Removed old inline `notificationBody()` method from NotificationManager
- Files changed:
  - `ExerciseSnack/ExerciseSuggestions.swift` (new)
  - `ExerciseSnack/NotificationManager.swift` (modified — uses ExerciseSuggestionProvider instead of inline suggestions)
  - `ExerciseSnack.xcodeproj/project.pbxproj` (modified — added ExerciseSuggestions.swift)
- **Learnings for future iterations:**
  - When extracting functionality into a new file, the old code in NotificationManager can be simplified by pre-generating all needed values before the scheduling loop
  - The non-repeating pattern uses a simple `lastUsedIndex` tracker with a repeat-until-different loop — works well when the pool is large enough (>1 item)
  - Remember to increment the "next available pbxproj IDs" in Codebase Patterns after consuming an ID pair
---
