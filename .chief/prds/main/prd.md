# General Movement Notification Messages

## Overview
Replace the current exercise-specific notification messages (e.g. "Drop and give me 10 squats!") with funny, general movement encouragement messages that don't reference specific exercises. The notification titles remain unchanged.

## User Stories

### US-001: Replace Exercise-Specific Messages with General Movement Messages
**Priority:** 1
**Description:** As a user, I want notification messages that encourage general movement in a funny, lighthearted tone so that I feel motivated to take a break without being told exactly what exercise to do.

**Acceptance Criteria:**
- [ ] Notification bodies no longer reference specific exercises or rep counts
- [ ] At least 15 funny, encouraging general movement messages are provided (e.g. "Time to put on those dancing shoes and do your exercise snack!", "Your chair is getting jealous of your standing desk impression!")
- [ ] Messages use a funny, lighthearted, encouraging tone
- [ ] The `ExerciseSuggestion` struct is simplified — remove the `exercise` field, keep only the `message` field (or rename the struct to reflect its new purpose)
- [ ] The non-repeating selection logic (no consecutive duplicate messages within a day) is preserved
- [ ] Notification titles remain unchanged ("Time to move!", "Exercise snack time!", etc.)
- [ ] Snoozed notifications still carry forward the same message from the original notification
