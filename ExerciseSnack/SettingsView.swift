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
        }
        .formStyle(.grouped)
        .frame(width: 320, height: 180)
        .fixedSize()
    }
}
