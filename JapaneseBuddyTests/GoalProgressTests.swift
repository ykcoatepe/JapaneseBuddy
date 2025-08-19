import XCTest
@testable import JapaneseBuddyProj

final class GoalProgressTests: XCTestCase {
    func testCompute() {
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let goal = DailyGoal(newTarget: 5, reviewTarget: 5)
        let entries: [SessionLogEntry] = [
            SessionLogEntry(date: today, kind: .new, cardID: UUID()),
            SessionLogEntry(date: today, kind: .new, cardID: UUID()),
            SessionLogEntry(date: today, kind: .review, cardID: UUID()),
            SessionLogEntry(date: today, kind: .review, cardID: UUID()),
            SessionLogEntry(date: today, kind: .review, cardID: UUID()),
            SessionLogEntry(date: yesterday, kind: .new, cardID: UUID()),
            SessionLogEntry(date: yesterday, kind: .review, cardID: UUID())
        ]
        let prog = GoalProgress.compute(entries: entries, on: today, goal: goal, cal: cal)
        XCTAssertEqual(prog.newDone, 2)
        XCTAssertEqual(prog.reviewDone, 3)
        XCTAssertEqual(prog.target.newTarget, goal.newTarget)
        XCTAssertEqual(prog.target.reviewTarget, goal.reviewTarget)
    }
}
