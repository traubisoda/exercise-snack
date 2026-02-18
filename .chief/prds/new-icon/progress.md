## Codebase Patterns
- Icon generation uses a standalone Swift script (`generate_icon.swift`) that can be re-run to regenerate all icons
- All icon sizes are defined in Contents.json already — just replace the PNG files
- The icon generator designs at 512px and scales all coordinates proportionally using `size / 512.0`
- CoreGraphics even-odd fill rule is used to create the donut shape (outer circle minus hole minus bite)
- Sprinkles are only drawn at sizes >= 64px where they'd be visible
- Menu bar icons use a separate generator script (`generate_menubar_icon.swift`) with monochrome design
- Menu bar template images: set `template-rendering-intent: template` in Contents.json for automatic light/dark mode
- MenuBarExtra uses `image:` parameter (not `systemImage:`) for custom asset catalog images
- Notifications: use `UNUserNotificationCenter.removeAllPendingNotificationRequests()` + `removeAllDeliveredNotifications()` for full cleanup
- App lifecycle: observe `NSApplication.willTerminateNotification` in NotificationManager for cleanup on quit (no AppDelegate needed)
- Wake from sleep: use `NSWorkspace.shared.notificationCenter` (not `NotificationCenter.default`) to observe `NSWorkspace.didWakeNotification`
- `rescheduleNotifications()` already handles the "clear all + reschedule only future" pattern — reuse it for wake-from-sleep

---

## 2026-02-18 - US-001: Programmatic App Icon
- What was implemented:
  - Created `generate_icon.swift` — a standalone Swift script using CoreGraphics/AppKit to programmatically draw a bitten-donut icon
  - Design: green gradient background (light→dark, top-left→bottom-right), tan donut body, purple/violet glazing on top half, bite taken from upper-right, colorful sprinkles
  - Generated all 10 required macOS icon sizes (16x16 through 512x512@2x, actual pixels 16-1024)
  - Replaced existing icon PNGs in `Assets.xcassets/AppIcon.appiconset/`
  - Contents.json was already configured correctly — no changes needed
  - Build verified successfully with `xcodebuild`
- Files changed:
  - `generate_icon.swift` (new — icon generation script)
  - `ExerciseSnack/Assets.xcassets/AppIcon.appiconset/icon_*.png` (all 10 files replaced)
- **Learnings for future iterations:**
  - CGContext with lockFocus/unlockFocus on NSImage is the simplest way to draw programmatic icons on macOS
  - Use NSBitmapImageRep for precise pixel-size control when saving PNGs (NSImage size is in points, not pixels)
  - Even-odd fill rule (`ctx.fillPath(using: .evenOdd)`) is perfect for creating shapes with holes (donut = outer circle + hole circle + bite circle filled with even-odd)
  - Design at a fixed base size (512) and multiply all coordinates by `size / 512.0` for clean scaling
  - Sprinkles and fine details should be conditionally drawn only at sizes where they're visible (>= 64px)
---

## 2026-02-18 - US-002: Menu Bar Icon
- What was implemented:
  - Created `generate_menubar_icon.swift` — standalone Swift script for monochrome menu bar icon
  - Design: black silhouette of bitten donut with hole, bite from upper-right, and a white glazing arc for detail
  - Generated 18x18 (@1x) and 36x36 (@2x) template images
  - Created `Assets.xcassets/MenuBarIcon.imageset/` with Contents.json using `template-rendering-intent: template`
  - Updated `MenuBarExtra` in `ExerciseSnackApp.swift` from `systemImage: "figure.run"` to `image: "MenuBarIcon"`
  - Build verified successfully with `xcodebuild`
- Files changed:
  - `generate_menubar_icon.swift` (new — menu bar icon generation script)
  - `ExerciseSnack/Assets.xcassets/MenuBarIcon.imageset/Contents.json` (new)
  - `ExerciseSnack/Assets.xcassets/MenuBarIcon.imageset/menubar_icon.png` (new — 18x18)
  - `ExerciseSnack/Assets.xcassets/MenuBarIcon.imageset/menubar_icon@2x.png` (new — 36x36)
  - `ExerciseSnack/ExerciseSnackApp.swift` (modified — changed MenuBarExtra icon reference)
- **Learnings for future iterations:**
  - macOS template images should be drawn in black on transparent background — the system handles light/dark mode rendering
  - `template-rendering-intent: template` in the imageset Contents.json is the asset catalog way to set template rendering
  - `MenuBarExtra("title", image: "AssetName")` uses asset catalog images; `systemImage:` is for SF Symbols only
  - Menu bar icons should be ~18x18 points (provide @1x and @2x); the design base was 36px scaled with `size / 36.0`
  - Even at small sizes (18px), the bitten-donut silhouette is recognizable: outer circle + hole + bite using even-odd fill
---

## 2026-02-18 - US-003: Clear Notifications on Quit
- What was implemented:
  - Added `clearAllNotifications()` method to `NotificationManager` that removes both pending and delivered notifications
  - Wired it into the Quit button action in `ExerciseSnackApp.swift` so notifications are cleared before `NSApplication.terminate`
  - Added `NSApplication.willTerminateNotification` observer in `NotificationManager.init()` as a safety net for any termination path
  - Two-layer approach: explicit call in Quit button + observer on willTerminate ensures reliable cleanup
  - Build verified successfully with `xcodebuild`
- Files changed:
  - `ExerciseSnack/NotificationManager.swift` (added `clearAllNotifications()` method and willTerminate observer)
  - `ExerciseSnack/ExerciseSnackApp.swift` (call clearAllNotifications before terminate in Quit button)
- **Learnings for future iterations:**
  - `UNUserNotificationCenter.removeAllPendingNotificationRequests()` clears scheduled-but-not-yet-fired notifications
  - `UNUserNotificationCenter.removeAllDeliveredNotifications()` clears notifications already shown in Notification Center
  - Both calls are synchronous (fire-and-forget) — safe to call right before `NSApplication.terminate`
  - In SwiftUI apps without AppDelegate, observe `NSApplication.willTerminateNotification` via `NotificationCenter.default` for cleanup
  - The `.keyboardShortcut("q")` on a MenuBarExtra button handles Cmd+Q, so the button action covers that path too
---

## 2026-02-18 - US-004: Handle Wake from Sleep / Stale Notifications
- What was implemented:
  - Added `NSWorkspace.didWakeNotification` observer in `NotificationManager.init()` to detect wake from sleep
  - Created `handleWakeFromSleep()` method that clears delivered (stale) notifications and calls `rescheduleNotifications()`
  - `rescheduleNotifications()` already removes all pending notifications and reschedules only for future working hours, so no duplicate handling needed
  - Status text auto-updates via the existing `rescheduleNotifications()` → `updateStatusText()` chain
  - Build verified successfully with `xcodebuild`
- Files changed:
  - `ExerciseSnack/NotificationManager.swift` (added didWakeNotification observer and handleWakeFromSleep method)
- **Learnings for future iterations:**
  - `NSWorkspace.didWakeNotification` is observed via `NSWorkspace.shared.notificationCenter` — NOT `NotificationCenter.default`
  - The existing `rescheduleNotifications()` method already handles the pattern of "clear everything + schedule only future" — reuse it rather than writing custom stale-detection logic
  - `removeAllDeliveredNotifications()` clears stale notifications shown in Notification Center before sleep
  - No need for `willSleepNotification` — handling wake is sufficient since that's when we need to reconcile state
---
