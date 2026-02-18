# New Icon & Notification Lifecycle

## Overview
Replace the app icon and menu bar icon with a custom bitten-donut design, and improve notification lifecycle by clearing notifications on quit and handling wake-from-sleep scenarios.

## User Stories

### US-001: Programmatic App Icon
**Priority:** 1
**Description:** As a user, I want the app to have a distinctive bitten-donut icon so that it's easily recognizable in Finder, the Dock (if shown), and Spotlight.

**Design Spec:**
- Background: green linear gradient (top-left to bottom-right, light green to darker green)
- Shape: rounded rectangle (standard macOS icon shape)
- Donut: centered, with a bite taken out of the upper-right area
- Glazing: purple/violet color on the top surface of the donut
- Donut body: warm/tan color visible below the glazing and on the bite cross-section
- Sprinkles or simple details optional for visual appeal
- The icon should look good at all sizes from 16x16 to 512x512@2x

**Acceptance Criteria:**
- [ ] App icon uses the bitten-donut design with green gradient background and purple glazing
- [ ] All required macOS icon sizes are generated (16x16, 16x16@2x, 32x32, 32x32@2x, 128x128, 128x128@2x, 256x256, 256x256@2x, 512x512, 512x512@2x)
- [ ] Icon is properly configured in Assets.xcassets/AppIcon.appiconset
- [ ] Icon renders clearly at both small (16px) and large (512px) sizes
- [ ] App builds and displays the new icon in Finder and menu bar "About" context

### US-002: Menu Bar Icon
**Priority:** 2
**Description:** As a user, I want the menu bar to show a small bitten-donut icon instead of the generic running figure so that the app has a consistent brand identity.

**Design Spec:**
- Monochrome/template image (works with macOS light and dark mode automatically)
- Simple silhouette of a donut with a bite taken out
- Should be recognizable at menu bar size (~18x18 points, provide @2x)
- Use `Image(nsImage:)` or a template image in the asset catalog

**Acceptance Criteria:**
- [ ] Menu bar displays a bitten-donut icon instead of `figure.run` SF Symbol
- [ ] Icon adapts to light/dark mode correctly (template rendering)
- [ ] Icon is sharp and recognizable at menu bar size
- [ ] The `MenuBarExtra` in `ExerciseSnackApp.swift` references the new icon

### US-003: Clear Notifications on Quit
**Priority:** 3
**Description:** As a user, I want all pending exercise notifications to be cleared when I quit the app so that I don't receive reminders after intentionally closing the app.

**Acceptance Criteria:**
- [ ] When the user clicks "Quit" (or Cmd+Q), all pending exercise snack notifications are removed before the app terminates
- [ ] Delivered (but not yet dismissed) notifications in Notification Center are also cleared
- [ ] The notification clearing happens reliably before `NSApplication.terminate` completes
- [ ] No orphaned notifications appear after the app has quit

### US-004: Handle Wake from Sleep / Stale Notifications
**Priority:** 4
**Description:** As a user, I want the app to detect when my Mac wakes from sleep (or was powered off) and clear any stale past-due notifications so that I don't receive a burst of outdated reminders.

**Acceptance Criteria:**
- [ ] App subscribes to `NSWorkspace.willSleepNotification` and/or `NSWorkspace.didWakeNotification`
- [ ] On wake, all pending notifications with fire dates in the past are removed
- [ ] On wake, notifications are rescheduled for the remaining working hours of the current day
- [ ] Already-delivered stale notifications in Notification Center are cleared on wake
- [ ] Status text updates correctly after wake-from-sleep rescheduling
- [ ] No duplicate notifications are created (existing future notifications are handled cleanly)
