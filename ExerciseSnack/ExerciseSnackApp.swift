import SwiftUI

@main
struct ExerciseSnackApp: App {
    var body: some Scene {
        MenuBarExtra("Exercise Snack", systemImage: "figure.run") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
