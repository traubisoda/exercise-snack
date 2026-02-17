import SwiftUI

@main
struct ExerciseSnackApp: App {
    @ObservedObject private var settings = SettingsManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra("Exercise Snack", systemImage: "figure.run") {
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
