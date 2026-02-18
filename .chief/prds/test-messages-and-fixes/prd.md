# Test Notification & Settings Fix

## Overview
Add a developer-only menu option to send a test notification for debugging purposes, and fix a visual bug where the settings window content scrolls behind the title bar.

## User Stories

### US-001: Fix Settings Content Scrolling Behind Title Bar
**Priority:** 1
**Description:** As a user, I want the settings window content to not overlap with the title bar so that all settings are fully visible when scrolling.

**Acceptance Criteria:**
- [ ] When the settings window is open and content is scrolled, no content appears behind or under the window title bar
- [ ] The grouped form style and overall layout remain visually unchanged
- [ ] The settings window still uses `.windowResizability(.contentSize)` and is not freely resizable

### US-002: Developer-Only Test Notification Menu Item
**Priority:** 2
**Description:** As a developer, I want a menu option to send a test notification immediately so that I can verify notification behavior without waiting for the next scheduled time.

**Acceptance Criteria:**
- [ ] A "Send Test Notification" button appears in the menu bar dropdown (between the status/alert section and the "Settings..." button)
- [ ] The button is only present in Debug builds (`#if DEBUG` compilation flag)
- [ ] Tapping the button immediately delivers a notification using the existing notification content format (random message from the pool, with the `EXERCISE_SNACK` category so action buttons appear)
- [ ] The test notification does not interfere with the regular scheduling (does not remove or reschedule existing pending notifications)
- [ ] The button is not present in Release/production builds
