import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private enum Keys {
        static let workStartHour = "workStartHour"
        static let workEndHour = "workEndHour"
        static let snoozeDuration = "snoozeDuration"
    }

    @Published var workStartHour: Int {
        didSet { UserDefaults.standard.set(workStartHour, forKey: Keys.workStartHour) }
    }

    @Published var workEndHour: Int {
        didSet { UserDefaults.standard.set(workEndHour, forKey: Keys.workEndHour) }
    }

    @Published var snoozeDuration: Int {
        didSet { UserDefaults.standard.set(snoozeDuration, forKey: Keys.snoozeDuration) }
    }

    private init() {
        let defaults = UserDefaults.standard

        // Register defaults
        defaults.register(defaults: [
            Keys.workStartHour: 9,
            Keys.workEndHour: 17,
            Keys.snoozeDuration: 10
        ])

        self.workStartHour = defaults.integer(forKey: Keys.workStartHour)
        self.workEndHour = defaults.integer(forKey: Keys.workEndHour)
        self.snoozeDuration = defaults.integer(forKey: Keys.snoozeDuration)
    }
}
