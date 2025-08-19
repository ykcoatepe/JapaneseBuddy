import XCTest
@testable import JapaneseBuddyProj

final class GoalProgressTests: XCTestCase {
    func testLoggingIncrementsProgressToday() {
        let store = DeckStore()
        // fixed point in time
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let card = Card(type: .kana, front: "あ", back: "a")

        store.logNew(for: card, date: day)
        store.logReview(for: card, date: day)

        let prog = store.progressToday(now: day)
        XCTAssertEqual(prog.newDone, 1)
        XCTAssertEqual(prog.reviewDone, 1)
    }
}

