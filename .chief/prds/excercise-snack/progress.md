## Codebase Patterns
- This is a native Swift/SwiftUI macOS menu bar app using Xcode project (not SPM)
- Build with: `xcodebuild -project ExerciseSnack.xcodeproj -scheme ExerciseSnack -configuration Debug build`
- App entry point: `ExerciseSnack/ExerciseSnackApp.swift` using `@main` and SwiftUI `App` protocol
- LSUIElement=YES set via Info.plist and INFOPLIST_KEY_LSUIElement build setting for menu-bar-only behavior
- Menu bar UI uses SwiftUI `MenuBarExtra` with SF Symbol `figure.run`
- Deployment target: macOS 14.0 (Sonoma)
- Bundle ID: com.exercisesnack.app

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
