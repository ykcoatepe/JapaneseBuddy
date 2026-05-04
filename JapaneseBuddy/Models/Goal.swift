import Foundation

struct DailyGoal: Codable {
    var newTarget: Int = 10
    var reviewTarget: Int = 10
    var lessonTarget: Int = 1

    init(newTarget: Int = 10, reviewTarget: Int = 10, lessonTarget: Int = 1) {
        self.newTarget = newTarget
        self.reviewTarget = reviewTarget
        self.lessonTarget = lessonTarget
    }

    private enum CodingKeys: String, CodingKey {
        case newTarget, reviewTarget, lessonTarget
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newTarget = try container.decodeIfPresent(Int.self, forKey: .newTarget) ?? 10
        reviewTarget = try container.decodeIfPresent(Int.self, forKey: .reviewTarget) ?? 10
        lessonTarget = try container.decodeIfPresent(Int.self, forKey: .lessonTarget) ?? 1
    }
}

enum SessionKind: String, Codable {
    case new, review, study, lesson

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = (try? container.decode(String.self)) ?? SessionKind.review.rawValue
        self = SessionKind(rawValue: rawValue) ?? .review
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .new, .review, .lesson:
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
    let lessonDone: Int
    let target: DailyGoal

    var totalDone: Int {
        newDone + reviewDone + lessonDone
    }

    var totalTarget: Int {
        target.newTarget + target.reviewTarget + target.lessonTarget
    }

    var ratio: Double {
        guard totalTarget > 0 else { return 1 }
        return min(1, Double(totalDone) / Double(totalTarget))
    }
}

extension GoalProgress {
    static func compute(entries: [SessionLogEntry], on day: Date, goal: DailyGoal, cal: Calendar = .current) -> GoalProgress {
        let today = entries.filter { cal.isDate($0.date, inSameDayAs: day) }
        let newDone = today.filter { $0.kind == .new }.count
        let reviewDone = today.filter { $0.kind == .review && $0.durationSec == nil }.count
        let lessonDone = today.filter { $0.kind == .lesson && $0.durationSec == nil }.count
        return GoalProgress(newDone: newDone, reviewDone: reviewDone, lessonDone: lessonDone, target: goal)
    }
}
