## Codebase Patterns
- `NotificationManager.requestPermissionAndSchedule()` is the single entry point for auth check + scheduling on launch
- `getNotificationSettings` is the reliable way to check current auth status; `requestAuthorization` callback may not fire if permission is already granted
- Always call `rescheduleNotifications()` after confirming authorization — it handles clearing old + scheduling new

---

## 2026-02-18 - US-001: Schedule Notifications on App Launch
- What was implemented:
  - Replaced `requestPermission()` with `requestPermissionAndSchedule()` in NotificationManager
  - New method checks current authorization via `getNotificationSettings` first
  - If already authorized (`.authorized` or `.provisional`), immediately calls `rescheduleNotifications()` — no waiting for `requestAuthorization` callback
  - If `.notDetermined`, preserves existing `requestAuthorization` flow (prompts user, schedules on grant)
  - If denied, just updates status text
  - Updated call site in `ExerciseSnackApp.init()` to use new method name
- Files changed:
  - `ExerciseSnack/NotificationManager.swift` (modified — replaced `requestPermission` with `requestPermissionAndSchedule`)
  - `ExerciseSnack/ExerciseSnackApp.swift` (modified — updated call to new method name)
- **Learnings for future iterations:**
  - `requestAuthorization` completion handler is unreliable when permission is already granted — always use `getNotificationSettings` to check current status first
  - The `authorizationStatus` enum includes `.provisional` which should be treated the same as `.authorized` for scheduling purposes
  - The root cause of "No more reminders today" on relaunch was that `rescheduleNotifications()` was only called inside the `requestAuthorization` callback, which doesn't fire reliably on subsequent launches
---
