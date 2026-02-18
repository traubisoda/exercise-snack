# Exercise Snack

A lightweight macOS menu bar app that nudges you to move throughout the workday. It sends hourly notifications with fun, varied movement reminders — so you never sit for too long.

## Why Exercise Snacks?

"Exercise snacks" are brief bursts of physical activity — typically 1 to 5 minutes — spread throughout the day. A growing body of research shows that these short movement breaks can have a significant impact on health, even for people who already exercise regularly.

**Longevity and mortality.** Studies tracking daily activity patterns found that just three to four minutes of vigorous intermittent activity per day is associated with a 25–30% reduction in all-cause mortality. Increasing to around nine minutes per day was linked to a 50% reduction in cardiovascular death and a 40% reduction in cancer-related death.

**Blood sugar regulation.** Research shows that performing 10 bodyweight squats every 45 minutes during prolonged sitting improves blood sugar regulation more effectively than a single 30-minute walk. Brief high-intensity bursts done 3 times per day also improve glucose homeostasis.

**Cardiovascular fitness.** A study on office workers found that running up stairs in ~20-second sessions repeated throughout the day measurably improved their cardiovascular endurance — no gym required.

**Cognitive performance.** Interrupting prolonged sitting with short movement breaks has been shown to enhance cognitive performance, improve mood, and reduce fatigue in sedentary adults.

The key insight is that breaking up sedentary time matters independently of whether you also do longer workouts. Exercise snacks are effective precisely because they are easy to do, require no equipment, and eliminate "lack of time" as a barrier.

### Further Reading

- [Just 9 Minutes of THIS Could Add Years to Your Life](https://www.foundmyfitness.com/episodes/exercise-snacks-for-longevity) — Dr. Rhonda Patrick on exercise snacks and VILPA for longevity
- [This 1-Minute "Snack" Could Add Years to Your Life](https://www.foundmyfitness.com/episodes/exercise-snacks-longevity-glucose) — Dr. Rhonda Patrick on how brief exercise bursts improve glucose regulation and reduce mortality
- [Why Exercise Snacks That Spread Out Exercise Benefit Glucose Regulation](https://www.foundmyfitness.com/episodes/exercise-snacks-martin-gibala) — Dr. Martin Gibala on FoundMyFitness discussing the science of 1-minute workouts
- [Exercise Snacks Explained](https://ai.hubermanlab.com/s/PSRCj_B5) — Dr. Andrew Huberman on exercise snacks for cardiovascular fitness and muscular endurance
- [Exercise Snacks as a Strategy to Interrupt Sedentary Behavior](https://pmc.ncbi.nlm.nih.gov/articles/PMC12732512/) — Systematic review of health outcomes and feasibility (PMC)

## Features

- **Hourly movement reminders** during your configured working hours
- **Snooze or acknowledge** notifications with one click
- **Configurable working hours** — only get reminders when you're working
- **Adjustable snooze duration** (5–30 minutes)
- **Reminder offset** — get notified on the hour, or 5/10 minutes early
- **Launch at login** — start automatically when you log in
- **Automatic update checks** — get notified when a new version is available
- **Lives in your menu bar** — no Dock icon, stays out of your way

## Installation

Exercise Snack is distributed as a DMG file. Download the latest release from the [Releases](https://github.com/traubisoda/exercise-snack/releases) page.

1. Open the `.dmg` file
2. Drag **Exercise Snack** into the **Applications** folder
3. Open **Exercise Snack** from your Applications folder

### Allowing the app to run

Since Exercise Snack is locally signed (not notarized by Apple), macOS will block it on first launch. To allow it:

1. Try opening the app — macOS will show a warning that it cannot verify the developer
2. Open **System Settings** > **Privacy & Security**
3. Scroll down to the **Security** section — you'll see a message about Exercise Snack being blocked
4. Click **Open Anyway**
5. Confirm in the dialog that appears

You only need to do this once. After that, the app will open normally.

## Usage

Once running, Exercise Snack appears as an icon in your menu bar. Click it to see:

- **Next reminder time** — when your next movement reminder is scheduled
- **Settings** — configure working hours, snooze duration, and more
- **Check for Updates** — manually check for a new version

### Notifications

When a reminder fires, you'll see a notification with a movement message. You can:

- **Do it now** — dismiss the notification and get moving
- **Snooze** — postpone the reminder by your configured snooze duration

For the action buttons to appear reliably, set the notification style to **Alerts** (instead of Banners) in **System Settings** > **Notifications** > **Exercise Snack**.

### Settings

Open settings from the menu bar dropdown. You can configure:

| Setting | Default | Description |
|---------|---------|-------------|
| Working hours | 9:00–17:00 | Hours during which reminders are active |
| Reminder offset | On the hour | Get reminded on the hour, or 5/10 minutes early |
| Snooze duration | 10 minutes | How long snooze postpones a reminder |
| Launch at login | Off | Start the app automatically on login |
