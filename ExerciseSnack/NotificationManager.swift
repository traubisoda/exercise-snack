import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    private var midnightTimer: Timer?

    private init() {
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

        // Notifications fire at the top of each hour within working hours.
        // For working hours 9-17, notifications are at: 10, 11, 12, 13, 14, 15, 16, 17
        for hour in (startHour + 1)...endHour {
            // Build date components for today at this hour
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = 0
            components.second = 0

            guard let fireDate = calendar.date(from: components),
                  fireDate > now else {
                continue // Skip past notifications
            }

            let content = UNMutableNotificationContent()
            content.title = notificationTitle()
            content.body = notificationBody()
            content.sound = .default

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

    private func notificationBody() -> String {
        let suggestions = [
            "Drop and give me 10 squats! Your body will thank you!",
            "How about 15 desk push-ups? You've got this!",
            "Hold a 30-second plank — you're stronger than you think!",
            "Time for 20 calf raises! Stand tall and feel the burn!",
            "Do 10 lunges per leg — your future self will thank you!",
            "Stretch it out! Touch your toes and hold for 30 seconds!",
            "Try 15 jumping jacks to get your blood pumping!",
            "Roll your shoulders 10 times each way — release that tension!",
            "Do 10 tricep dips on your chair! Arms of steel incoming!",
            "Walk around for 2 minutes — every step counts!",
        ]
        return suggestions.randomElement()!
    }
}
