import Foundation
import UserNotifications
import Combine
import AppKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private static let categoryIdentifier = "EXERCISE_SNACK"
    private static let doItNowAction = "DO_IT_NOW"
    private static let snoozeAction = "SNOOZE"

    @Published var statusText: String = "No more reminders today"
    /// Whether to show a guidance prompt telling the user to enable Alert-style notifications
    @Published var showAlertStylePrompt: Bool = false

    private let center = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    private var midnightTimer: Timer?
    private var statusTimer: Timer?

    private override init() {
        super.init()

        // Register notification category with actions
        let doItNow = UNNotificationAction(
            identifier: Self.doItNowAction,
            title: "Do it now",
            options: []
        )
        let snooze = UNNotificationAction(
            identifier: Self.snoozeAction,
            title: "Snooze",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [doItNow, snooze],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
        center.delegate = self

        // Observe settings changes to reschedule notifications
        let settings = SettingsManager.shared
        settings.$workStartHour
            .combineLatest(settings.$workEndHour, settings.$reminderOffset)
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.rescheduleNotifications()
            }
            .store(in: &cancellables)
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.rescheduleNotifications()
                    self.checkAlertStyle()
                }
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case Self.snoozeAction:
            scheduleSnoozeNotification(from: response.notification)
        case Self.doItNowAction:
            // Fire-and-forget — just dismiss
            updateStatusText()
        default:
            // Default action (tapped notification body) or dismiss — no follow-up
            updateStatusText()
        }
        completionHandler()
    }

    func rescheduleNotifications() {
        // Remove all pending notifications and reschedule
        center.removeAllPendingNotificationRequests()
        scheduleTodayNotifications()
        scheduleMidnightReschedule()
        // Delay status update slightly so pending requests are registered
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateStatusText()
        }
    }

    private func scheduleTodayNotifications() {
        let settings = SettingsManager.shared
        let startHour = settings.workStartHour
        let endHour = settings.workEndHour
        let offset = settings.reminderOffset

        guard endHour > startHour else { return }

        let calendar = Calendar.current
        let now = Date()

        // Collect future fire dates (hour label + actual fire date with offset applied)
        var futureSlots: [(hour: Int, fireDate: Date)] = []
        for hour in (startHour + 1)...endHour {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = 0
            components.second = 0

            guard let baseDate = calendar.date(from: components) else { continue }

            // Apply offset: fire `offset` minutes before the hour
            let fireDate = baseDate.addingTimeInterval(TimeInterval(-offset * 60))

            guard fireDate > now else { continue }
            futureSlots.append((hour: hour, fireDate: fireDate))
        }

        guard !futureSlots.isEmpty else { return }

        // Get non-repeating exercise suggestions for all future slots
        let suggestions = ExerciseSuggestionProvider.shared.suggestionsForDay(count: futureSlots.count)

        for (index, slot) in futureSlots.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = notificationTitle()
            content.body = suggestions[index].message
            content.sound = .default
            content.categoryIdentifier = Self.categoryIdentifier

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: slot.fireDate),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "exercise-snack-\(slot.hour)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    private func scheduleMidnightReschedule() {
        midnightTimer?.invalidate()

        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) else {
            return
        }

        let interval = tomorrow.timeIntervalSinceNow
        midnightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.rescheduleNotifications()
        }
    }

    // MARK: - Status

    func updateStatusText() {
        checkAlertStyle()

        let settings = SettingsManager.shared
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)

        // Check if outside working hours
        if currentHour < settings.workStartHour || currentHour >= settings.workEndHour {
            statusText = "Outside working hours"
            scheduleStatusTimer()
            return
        }

        // Query pending notifications to find the next one
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }

            let snackRequests = requests.filter { $0.identifier.hasPrefix("exercise-snack") }

            // Find the earliest fire date among pending notifications
            var nextDate: Date?
            for request in snackRequests {
                if let calTrigger = request.trigger as? UNCalendarNotificationTrigger,
                   let fireDate = calTrigger.nextTriggerDate(),
                   fireDate > now {
                    if nextDate == nil || fireDate < nextDate! {
                        nextDate = fireDate
                    }
                } else if let timeTrigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                          let fireDate = timeTrigger.nextTriggerDate(),
                          fireDate > now {
                    if nextDate == nil || fireDate < nextDate! {
                        nextDate = fireDate
                    }
                }
            }

            DispatchQueue.main.async {
                if let nextDate = nextDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    self.statusText = "Next reminder: \(formatter.string(from: nextDate))"
                } else {
                    self.statusText = "No more reminders today"
                }
                self.scheduleStatusTimer()
            }
        }
    }

    private func scheduleStatusTimer() {
        statusTimer?.invalidate()

        // Recalculate status at the top of the next minute
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.minute = (components.minute ?? 0) + 1
        components.second = 0

        guard let nextMinute = calendar.date(from: components) else { return }
        let interval = nextMinute.timeIntervalSince(now)

        statusTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.updateStatusText()
        }
    }

    // MARK: - Snooze

    private func scheduleSnoozeNotification(from notification: UNNotification) {
        let originalContent = notification.request.content
        let snoozeDuration = SettingsManager.shared.snoozeDuration

        let content = UNMutableNotificationContent()
        content.title = originalContent.title
        content.body = originalContent.body
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(snoozeDuration * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "exercise-snack-snooze-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatusText()
            }
        }
    }

    // MARK: - Alert Style Detection

    /// Check whether the app's notification style is set to Alerts (persistent) and update the prompt flag.
    func checkAlertStyle() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let isAlertStyle = settings.alertStyle == .alert
                if isAlertStyle {
                    // Setting is correct — clear any previous dismissal and hide prompt
                    UserDefaults.standard.removeObject(forKey: "alertStylePromptDismissed")
                    self.showAlertStylePrompt = false
                } else {
                    let dismissed = UserDefaults.standard.bool(forKey: "alertStylePromptDismissed")
                    self.showAlertStylePrompt = !dismissed
                }
            }
        }
    }

    /// Open macOS System Settings to the Notifications pane for this app.
    func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Dismiss the alert style guidance prompt permanently.
    func dismissAlertStylePrompt() {
        UserDefaults.standard.set(true, forKey: "alertStylePromptDismissed")
        showAlertStylePrompt = false
    }

    // MARK: - Notification Content

    private func notificationTitle() -> String {
        let titles = [
            "Time to move!",
            "Exercise snack time!",
            "Let's get moving!",
            "Break time!",
            "Your body says thanks!",
        ]
        return titles.randomElement()!
    }

}
