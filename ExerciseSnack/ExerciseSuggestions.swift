import Foundation

struct ExerciseSuggestion {
    let exercise: String
    let message: String
}

class ExerciseSuggestionProvider {
    static let shared = ExerciseSuggestionProvider()

    private let suggestions: [ExerciseSuggestion] = [
        ExerciseSuggestion(exercise: "10 squats", message: "Drop and give me 10 squats! Your body will thank you!"),
        ExerciseSuggestion(exercise: "15 desk push-ups", message: "How about 15 desk push-ups? You've got this!"),
        ExerciseSuggestion(exercise: "30-second plank", message: "Hold a 30-second plank — you're stronger than you think!"),
        ExerciseSuggestion(exercise: "20 calf raises", message: "Time for 20 calf raises! Stand tall and feel the burn!"),
        ExerciseSuggestion(exercise: "10 lunges per leg", message: "Do 10 lunges per leg — your future self will thank you!"),
        ExerciseSuggestion(exercise: "30-second toe touch", message: "Stretch it out! Touch your toes and hold for 30 seconds!"),
        ExerciseSuggestion(exercise: "15 jumping jacks", message: "Try 15 jumping jacks to get your blood pumping!"),
        ExerciseSuggestion(exercise: "10 shoulder rolls each way", message: "Roll your shoulders 10 times each way — release that tension!"),
        ExerciseSuggestion(exercise: "10 tricep dips", message: "Do 10 tricep dips on your chair! Arms of steel incoming!"),
        ExerciseSuggestion(exercise: "2-minute walk", message: "Walk around for 2 minutes — every step counts!"),
        ExerciseSuggestion(exercise: "20 high knees", message: "Pump out 20 high knees — feel that energy surge!"),
        ExerciseSuggestion(exercise: "15 seated leg raises", message: "Try 15 seated leg raises — sneak in some core work!"),
    ]

    /// Index of the last suggestion used today, to avoid consecutive repeats.
    private var lastUsedIndex: Int? = nil
    private var lastUsedDate: Date? = nil

    private init() {}

    /// Returns an array of exercise suggestions for the given count,
    /// ensuring no two consecutive suggestions are the same.
    func suggestionsForDay(count: Int) -> [ExerciseSuggestion] {
        resetIfNewDay()

        var result: [ExerciseSuggestion] = []
        for _ in 0..<count {
            let suggestion = pickNonRepeating()
            result.append(suggestion)
        }
        return result
    }

    private func pickNonRepeating() -> ExerciseSuggestion {
        var index: Int
        repeat {
            index = Int.random(in: 0..<suggestions.count)
        } while index == lastUsedIndex && suggestions.count > 1

        lastUsedIndex = index
        lastUsedDate = Date()
        return suggestions[index]
    }

    private func resetIfNewDay() {
        let calendar = Calendar.current
        if let lastDate = lastUsedDate,
           !calendar.isDateInToday(lastDate) {
            lastUsedIndex = nil
        }
    }
}
