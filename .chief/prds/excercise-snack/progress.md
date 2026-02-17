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
- Next available pbxproj IDs: A1000004 (build file), A2000007 (file ref)

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
