# Exercise Snack

## Overview
A native macOS menu bar utility that reminds users with sedentary jobs to take short exercise breaks ("exercise snacks") throughout their working hours. The app sends a notification at the end of every working hour with an encouraging exercise suggestion. Users can acknowledge or snooze reminders, configure their working hours and snooze duration, and optionally launch the app at system startup.

## User Stories

### US-001: Menu Bar App Shell
**Priority:** 1
**Description:** As a user, I want the app to live in the macOS menu bar so that it stays out of my way while being always accessible.

**Acceptance Criteria:**
- [ ] App displays an icon in the macOS menu bar (use a small dumbbell or running figure SF Symbol)
- [ ] Clicking the icon opens a dropdown menu
- [ ] The dropdown menu contains a "Quit" option that exits the app
- [ ] App has no Dock icon (LSUIElement / menu bar-only app)
- [ ] Built as a native Swift/SwiftUI macOS application
- [ ] Minimum deployment target is macOS 14 (Sonoma)

### US-002: Working Hours Configuration
**Priority:** 2
**Description:** As a user, I want to set my working hours so that I only receive reminders during the times I'm actually working.

**Acceptance Criteria:**
- [ ] The menu bar dropdown contains a "Settings..." option that opens a settings window
- [ ] Settings window has a start hour picker (hour only, e.g. 9:00)
- [ ] Settings window has an end hour picker (hour only, e.g. 17:00)
- [ ] Default working hours are 9:00 to 17:00
- [ ] End hour must be after start hour; show validation if not
- [ ] Settings are persisted using UserDefaults so they survive app restarts
- [ ] Changing working hours immediately reschedules any pending notifications

### US-003: Hourly Notification Scheduling
**Priority:** 3
**Description:** As a user, I want to receive a notification at the end of each working hour so that I'm reminded to do an exercise snack.

**Acceptance Criteria:**
- [ ] App uses UNUserNotificationCenter to schedule local notifications
- [ ] App requests notification permission on first launch
- [ ] Notifications are scheduled at the top of each hour within working hours (e.g. for 9-17: notifications at 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00)
- [ ] Notifications are only scheduled for the current day
- [ ] Notifications are rescheduled daily (e.g. at midnight or on app launch)
- [ ] If the app launches mid-day, only future notifications for today are scheduled
- [ ] Notification title uses a happy, encouraging tone (e.g. "Time to move!")
- [ ] Notification body suggests a specific exercise in an encouraging tone (e.g. "Drop and give me 10 squats! Your body will thank you!")

### US-004: Exercise Suggestions
**Priority:** 4
**Description:** As a user, I want each notification to suggest a specific exercise with an encouraging tone so that I know what to do and feel motivated.

**Acceptance Criteria:**
- [ ] App contains a built-in list of at least 10 exercise suggestions
- [ ] Each suggestion includes a specific exercise with a rep count (e.g. "10 squats", "15 desk push-ups", "30-second plank", "20 calf raises", "10 lunges per leg")
- [ ] Notification messages use a happy, encouraging, friendly tone
- [ ] Each notification randomly selects an exercise from the list
- [ ] Avoid repeating the same exercise in consecutive notifications within a day

### US-005: Notification Actions — Acknowledge and Snooze
**Priority:** 5
**Description:** As a user, I want to either acknowledge a reminder by clicking "Do it now" or snooze it so that I can handle the reminder on my terms.

**Acceptance Criteria:**
- [ ] Each notification has two action buttons: "Do it now" and "Snooze"
- [ ] Clicking "Do it now" dismisses the notification (fire-and-forget, no tracking)
- [ ] Clicking "Snooze" schedules a new notification after the configured snooze duration
- [ ] The snoozed notification contains the same exercise suggestion as the original
- [ ] If the notification is dismissed without clicking either button (e.g. swiped away), no follow-up occurs

### US-006: Snooze Duration Configuration
**Priority:** 6
**Description:** As a user, I want to configure how long the snooze delay is so that I can tailor reminders to my workflow.

**Acceptance Criteria:**
- [ ] Settings window includes a snooze duration picker
- [ ] Available options: 5 minutes, 10 minutes, 15 minutes, 20 minutes, 30 minutes
- [ ] Default snooze duration is 10 minutes
- [ ] Snooze duration is persisted using UserDefaults
- [ ] Changing snooze duration applies to future snoozes immediately

### US-007: Launch at Startup
**Priority:** 7
**Description:** As a user, I want to optionally have the app launch when I start my Mac so that I never forget to run it.

**Acceptance Criteria:**
- [ ] Settings window includes a "Launch at login" toggle
- [ ] Toggle uses the ServiceManagement framework (SMAppService) to register/unregister as a login item
- [ ] Default is off (not launching at startup)
- [ ] Setting is persisted and reflected correctly when reopening settings
- [ ] Toggle state accurately reflects the current login item status

### US-008: Menu Bar Status Display
**Priority:** 8
**Description:** As a user, I want to see when my next reminder is so that I know the app is working and can plan accordingly.

**Acceptance Criteria:**
- [ ] The menu bar dropdown shows the time of the next scheduled reminder (e.g. "Next reminder: 14:00")
- [ ] If no more reminders are scheduled for today, show "No more reminders today"
- [ ] If outside working hours, show "Outside working hours"
- [ ] Status updates automatically when a notification fires or is snoozed
