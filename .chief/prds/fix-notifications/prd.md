# Fix Notifications Not Scheduling on App Launch

## Overview
When the app is launched (or relaunched), it shows "No more reminders today" and does not send any notifications, even when the user is within their working hours. The root cause is that all pending notifications are cleared on app termination, but rescheduling on launch is gated behind the `requestAuthorization` completion handler, which may not fire reliably when permission has already been granted. The app needs to unconditionally check authorization status on launch and schedule notifications if authorized.

## User Stories

### US-001: Schedule Notifications on App Launch
**Priority:** 1
**Description:** As a user, I want the app to schedule notifications when I launch it so that I receive reminders during my working hours without any manual intervention.

**Acceptance Criteria:**
- [ ] On app launch, the app checks current notification authorization status (via `getNotificationSettings`) independently of `requestAuthorization`
- [ ] If authorization is already granted, notifications are scheduled immediately without waiting for `requestAuthorization` callback
- [ ] If authorization has not yet been granted, the existing `requestAuthorization` flow is preserved (prompts user, schedules on grant)
- [ ] The status text correctly shows the next scheduled reminder time (not "No more reminders today") when within working hours
- [ ] Relaunching the app after a quit correctly reschedules all remaining notifications for the day

### US-002: Remove Redundant Notification Cleanup on Terminate
**Priority:** 2
**Description:** As a user, I want the app to avoid double-clearing notifications so that the termination/launch cycle is clean and predictable.

**Acceptance Criteria:**
- [ ] The `willTerminateNotification` observer in `NotificationManager.init()` is removed (the Quit button already calls `clearAllNotifications()` explicitly before terminating)
- [ ] Quitting via the Quit button still clears notifications as before
- [ ] Quitting via other means (e.g., force quit, system shutdown) does not leave stale notifications because the app reschedules on next launch anyway (US-001)
