import Foundation

struct DailyGoal: Codable {
    var newTarget: Int = 10
    var reviewTarget: Int = 10
}

enum SessionKind: String, Codable {
    case new, review, study

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = (try? container.decode(String.self)) ?? SessionKind.review.rawValue
        self = SessionKind(rawValue: rawValue) ?? .review
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .new, .review:
            try container.encode(rawValue)
        case .study:
            // Keep persisted values backward-compatible for older app versions.
            try container.encode(SessionKind.review.rawValue)
        }
    }
}

struct SessionLogEntry: Codable {
    let date: Date
    let kind: SessionKind
    let cardID: UUID?
    let durationSec: Int?
}

struct GoalProgress {
    let newDone: Int
    let reviewDone: Int
    let target: DailyGoal
}

extension GoalProgress {
    static func compute(entries: [SessionLogEntry], on day: Date, goal: DailyGoal, cal: Calendar = .current) -> GoalProgress {
        let today = entries.filter { cal.isDate($0.date, inSameDayAs: day) }
        let newDone = today.filter { $0.kind == .new }.count
        let reviewDone = today.filter { $0.kind == .review }.count
        return GoalProgress(newDone: newDone, reviewDone: reviewDone, target: goal)
    }
}
