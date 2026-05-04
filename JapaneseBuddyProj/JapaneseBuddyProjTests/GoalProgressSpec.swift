import Foundation
import Testing
@testable import JapaneseBuddyProj

struct GoalProgressSpec {
    @Test func lessonCompletionsCountTowardDailyGoal() {
        let store = DeckStore(stateURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-lesson-goal-\(UUID().uuidString).json"))
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        store.dailyGoal = DailyGoal(newTarget: 0, reviewTarget: 0, lessonTarget: 2)

        store.logLessonCompletion(date: now)
        store.logLessonCompletion(date: now.addingTimeInterval(600))
        let progress = store.progressToday(now: now, cal: Calendar(identifier: .gregorian))

        #expect(progress.lessonDone == 2)
        #expect(progress.target.lessonTarget == 2)
        #expect(progress.totalDone == 2)
        #expect(progress.ratio == 1)
    }

    @Test func lessonStudyDurationDoesNotCountAsLessonCompletion() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let entries = [
            SessionLogEntry(date: now, kind: .lesson, cardID: nil, durationSec: 300),
            SessionLogEntry(date: now, kind: .lesson, cardID: nil, durationSec: nil)
        ]

        let progress = GoalProgress.compute(
            entries: entries,
            on: now,
            goal: DailyGoal(newTarget: 0, reviewTarget: 0, lessonTarget: 1),
            cal: Calendar(identifier: .gregorian)
        )

        #expect(progress.lessonDone == 1)
        #expect(progress.ratio == 1)
    }

    @Test func olderDailyGoalPayloadDefaultsLessonTarget() throws {
        let json = #"{"newTarget":4,"reviewTarget":6}"#
        let goal = try JSONDecoder().decode(DailyGoal.self, from: Data(json.utf8))

        #expect(goal.newTarget == 4)
        #expect(goal.reviewTarget == 6)
        #expect(goal.lessonTarget == 1)
    }
}
