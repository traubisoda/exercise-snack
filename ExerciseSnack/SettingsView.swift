import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared

    private var isValid: Bool {
        settings.workEndHour > settings.workStartHour
    }

    var body: some View {
        Form {
            Section("Working Hours") {
                Picker("Start Hour", selection: $settings.workStartHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%d:00", hour)).tag(hour)
                    }
                }

                Picker("End Hour", selection: $settings.workEndHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%d:00", hour)).tag(hour)
                    }
                }

                if !isValid {
                    Text("End hour must be after start hour.")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section("Notifications") {
                Picker("Reminder offset", selection: $settings.reminderOffset) {
                    Text("On the hour").tag(0)
                    Text("5 minutes early").tag(5)
                    Text("10 minutes early").tag(10)
                }
            }

            Section("Snooze") {
                Picker("Snooze Duration", selection: $settings.snoozeDuration) {
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                    Text("15 minutes").tag(15)
                    Text("20 minutes").tag(20)
                    Text("30 minutes").tag(30)
                }
            }

            Section("General") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .frame(width: 320, height: 400)
        .fixedSize()
        .toolbarBackground(.visible, for: .windowToolbar)
    }
}
