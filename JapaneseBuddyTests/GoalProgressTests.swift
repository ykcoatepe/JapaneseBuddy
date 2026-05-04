import XCTest
@testable import JapaneseBuddyProj

final class GoalProgressTests: XCTestCase {
    func testCompute() {
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let goal = DailyGoal(newTarget: 5, reviewTarget: 5, lessonTarget: 1)
        let entries: [SessionLogEntry] = [
            SessionLogEntry(date: today, kind: .new, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: today, kind: .new, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: today, kind: .review, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: today, kind: .review, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: today, kind: .review, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: today, kind: .lesson, cardID: nil, durationSec: nil),
            SessionLogEntry(date: yesterday, kind: .new, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: yesterday, kind: .review, cardID: UUID(), durationSec: nil),
            SessionLogEntry(date: yesterday, kind: .lesson, cardID: nil, durationSec: nil)
        ]
        let prog = GoalProgress.compute(entries: entries, on: today, goal: goal, cal: cal)
        XCTAssertEqual(prog.newDone, 2)
        XCTAssertEqual(prog.reviewDone, 3)
        XCTAssertEqual(prog.lessonDone, 1)
        XCTAssertEqual(prog.target.newTarget, goal.newTarget)
        XCTAssertEqual(prog.target.reviewTarget, goal.reviewTarget)
        XCTAssertEqual(prog.target.lessonTarget, goal.lessonTarget)
        XCTAssertEqual(prog.totalDone, 6)
        XCTAssertEqual(prog.totalTarget, 11)
        XCTAssertEqual(prog.ratio, 6.0 / 11.0)
    }

    func testGoalProgressRatioCapsAtComplete() {
        let progress = GoalProgress(
            newDone: 10,
            reviewDone: 10,
            lessonDone: 3,
            target: DailyGoal(newTarget: 1, reviewTarget: 1, lessonTarget: 1)
        )

        XCTAssertEqual(progress.totalDone, 23)
        XCTAssertEqual(progress.totalTarget, 3)
        XCTAssertEqual(progress.ratio, 1)
    }

    func testZeroDailyGoalCountsAsComplete() {
        let progress = GoalProgress(
            newDone: 0,
            reviewDone: 0,
            lessonDone: 0,
            target: DailyGoal(newTarget: 0, reviewTarget: 0, lessonTarget: 0)
        )

        XCTAssertEqual(progress.totalDone, 0)
        XCTAssertEqual(progress.totalTarget, 0)
        XCTAssertEqual(progress.ratio, 1)
    }

    func testDailyGoalDecodesOlderPayloadWithoutLessonTarget() throws {
        let json = #"{"newTarget":4,"reviewTarget":6}"#
        let goal = try JSONDecoder().decode(DailyGoal.self, from: Data(json.utf8))

        XCTAssertEqual(goal.newTarget, 4)
        XCTAssertEqual(goal.reviewTarget, 6)
        XCTAssertEqual(goal.lessonTarget, 1)
    }

    func testLessonSessionKindPersistsAsLesson() throws {
        let encoded = try JSONEncoder().encode(SessionKind.lesson)
        let decoded = try JSONDecoder().decode(SessionKind.self, from: encoded)

        XCTAssertEqual(decoded, .lesson)
    }

    func testLessonCompletionCountsTowardDailyGoal() {
        let store = DeckStore(stateURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-lesson-goal-\(UUID().uuidString).json"))
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        store.logLessonCompletion(date: now)
        let progress = store.progressToday(now: now, cal: Calendar(identifier: .gregorian))

        XCTAssertEqual(progress.lessonDone, 1)
        XCTAssertEqual(progress.target.lessonTarget, 1)
    }

    func testLessonStudyDurationDoesNotCountAsLessonCompletion() {
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

        XCTAssertEqual(progress.lessonDone, 1)
    }

    func testStudySessionCountsTowardMinutesAndStreak() {
        let store = DeckStore(stateURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-study-\(UUID().uuidString).json"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(120)

        store.beginStudy(now: start)
        store.endStudy(kind: .study, now: end, cal: calendar)

        XCTAssertEqual(store.minutesToday(now: end, cal: calendar), 2)
        XCTAssertEqual(store.currentStreak(now: end, cal: calendar), 1)
    }
}
