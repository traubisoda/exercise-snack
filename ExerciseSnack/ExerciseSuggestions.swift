import Foundation

struct MovementMessage {
    let message: String
}

class MovementMessageProvider {
    static let shared = MovementMessageProvider()

    private let messages: [MovementMessage] = [
        MovementMessage(message: "Time to put on those dancing shoes and do your exercise snack!"),
        MovementMessage(message: "Your chair is getting jealous of your standing desk impression!"),
        MovementMessage(message: "Your skeleton called — it wants to be taken for a walk!"),
        MovementMessage(message: "Plot twist: your body wasn't designed to be furniture!"),
        MovementMessage(message: "Stand up and pretend you're looking for something important!"),
        MovementMessage(message: "Wiggle break! Nobody's watching. Probably."),
        MovementMessage(message: "Your muscles just filed a complaint with HR. Time to move!"),
        MovementMessage(message: "This is your hourly reminder that you have legs. Use them!"),
        MovementMessage(message: "Alert: your body has been in power-saving mode too long!"),
        MovementMessage(message: "The floor misses your feet. Go say hello!"),
        MovementMessage(message: "Sitting is so last hour. Standing is the new black!"),
        MovementMessage(message: "Quick — move before your chair absorbs you permanently!"),
        MovementMessage(message: "Your future self just texted. They said 'thanks for moving!'"),
        MovementMessage(message: "Stretch like nobody's watching. Because they're not. Hopefully."),
        MovementMessage(message: "Breaking news: local developer discovers they can move!"),
        MovementMessage(message: "Time to shake it off! Taylor Swift would be proud."),
        MovementMessage(message: "Exercise snack time! No calories, all the benefits."),
        MovementMessage(message: "Your body's check engine light just came on. Time for a stretch!"),
    ]

    private var lastUsedIndex: Int? = nil
    private var lastUsedDate: Date? = nil

    private init() {}

    /// Returns an array of movement messages for the given count,
    /// ensuring no two consecutive messages are the same.
    func messagesForDay(count: Int) -> [MovementMessage] {
        resetIfNewDay()

        var result: [MovementMessage] = []
        for _ in 0..<count {
            let msg = pickNonRepeating()
            result.append(msg)
        }
        return result
    }

    private func pickNonRepeating() -> MovementMessage {
        var index: Int
        repeat {
            index = Int.random(in: 0..<messages.count)
        } while index == lastUsedIndex && messages.count > 1

        lastUsedIndex = index
        lastUsedDate = Date()
        return messages[index]
    }

    private func resetIfNewDay() {
        let calendar = Calendar.current
        if let lastDate = lastUsedDate,
           !calendar.isDateInToday(lastDate) {
            lastUsedIndex = nil
        }
    }
}
