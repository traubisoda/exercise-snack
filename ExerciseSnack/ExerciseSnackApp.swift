import SwiftUI

@main
struct ExerciseSnackApp: App {
    @ObservedObject private var settings = SettingsManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.openWindow) private var openWindow

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        MenuBarExtra("Exercise Snack", systemImage: "figure.run") {
            Text(notificationManager.statusText)
                .disabled(true)

            Divider()

            Button("Settings...") {
                openWindow(id: "settings")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",")

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }

        Window("Exercise Snack Settings", id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
