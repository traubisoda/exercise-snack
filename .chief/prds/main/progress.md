## Codebase Patterns
- See `.chief/prds/excercise-snack/progress.md` for comprehensive patterns
- Reminder offset uses minutes-before-the-hour stored as Int in UserDefaults (0, 5, or 10)
- Combine `combineLatest` can take up to 3 publishers — used for workStartHour + workEndHour + reminderOffset

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
