import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private static let categoryIdentifier = "EXERCISE_SNACK"
    private static let doItNowAction = "DO_IT_NOW"
    private static let snoozeAction = "SNOOZE"

    private let center = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    private var midnightTimer: Timer?

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
            .combineLatest(settings.$workEndHour)
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
            break
        default:
            // Default action (tapped notification body) or dismiss — no follow-up
            break
        }
        completionHandler()
    }

    func rescheduleNotifications() {
        // Remove all pending notifications and reschedule
        center.removeAllPendingNotificationRequests()
        scheduleTodayNotifications()
        scheduleMidnightReschedule()
    }

    private func scheduleTodayNotifications() {
        let settings = SettingsManager.shared
        let startHour = settings.workStartHour
        let endHour = settings.workEndHour

        guard endHour > startHour else { return }

        let calendar = Calendar.current
        let now = Date()

        // Collect future hours to schedule
        var futureHours: [Int] = []
        for hour in (startHour + 1)...endHour {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = 0
            components.second = 0

            guard let fireDate = calendar.date(from: components),
                  fireDate > now else {
                continue
            }
            futureHours.append(hour)
        }

        guard !futureHours.isEmpty else { return }

        // Get non-repeating exercise suggestions for all future hours
        let suggestions = ExerciseSuggestionProvider.shared.suggestionsForDay(count: futureHours.count)

        for (index, hour) in futureHours.enumerated() {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = 0
            components.second = 0

            guard let fireDate = calendar.date(from: components) else { continue }

            let content = UNMutableNotificationContent()
            content.title = notificationTitle()
            content.body = suggestions[index].message
            content.sound = .default
            content.categoryIdentifier = Self.categoryIdentifier

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "exercise-snack-\(hour)",
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

        center.add(request)
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
