import SwiftUI

@main
struct ExerciseSnackApp: App {
    @ObservedObject private var settings = SettingsManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.openWindow) private var openWindow

    init() {
        NotificationManager.shared.requestPermissionAndSchedule()
    }

    var body: some Scene {
        MenuBarExtra("Exercise Snack", image: "MenuBarIcon") {
            Text(notificationManager.statusText)
                .disabled(true)

            if notificationManager.showAlertStylePrompt {
                Divider()

                Text("⚠ Notifications disappear before you")
                    .disabled(true)
                Text("  can tap \"Do it now\" or \"Snooze\".")
                    .disabled(true)
                Text("  To fix, change to Alerts style:")
                    .disabled(true)

                Divider()

                Text("  1. Open System Settings")
                    .disabled(true)
                Text("  2. Go to Notifications")
                    .disabled(true)
                Text("  3. Find Exercise Snack")
                    .disabled(true)
                Text("  4. Change style: Banners → Alerts")
                    .disabled(true)

                Divider()

                Button("Open Notification Settings") {
                    notificationManager.openNotificationSettings()
                }

                Button("Dismiss") {
                    notificationManager.dismissAlertStylePrompt()
                }
            }

            #if DEBUG
            Divider()

            Button("Send Test Notification") {
                notificationManager.sendTestNotification()
            }
            #endif

            Divider()

            Button("Settings...") {
                openWindow(id: "settings")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",")

            Divider()

            Button("Quit") {
                NotificationManager.shared.clearAllNotifications()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }

        Window("Exercise Snack Settings", id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified(showsTitle: true))
    }
}
