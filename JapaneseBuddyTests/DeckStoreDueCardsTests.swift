import XCTest
@testable import JapaneseBuddyProj

final class DeckStoreDueCardsTests: XCTestCase {
    func testDueCardsFiltersByTypeAndDate() {
        let store = DeckStore()

        // Build a stable date baseline
        let cal = Calendar.current
        let now = Date()
        let past = cal.date(byAdding: .day, value: -1, to: now)!
        let future = cal.date(byAdding: .day, value: 1, to: now)!

        // Prepare cards: two due (one per type), one not due
        var c1 = Card(type: .hiragana, front: "あ", back: "a")
        c1.nextDue = past
        var c2 = Card(type: .katakana, front: "ア", back: "a")
        c2.nextDue = past
        var c3 = Card(type: .hiragana, front: "い", back: "i")
        c3.nextDue = future

        store.cards = [c1, c2, c3]

        // nil type returns all due cards across types
        let allDue = store.dueCards(type: nil, on: now)
        XCTAssertEqual(allDue.count, 2)

        // Specific type returns only matching due cards
        let hiraDue = store.dueCards(type: .hiragana, on: now)
        XCTAssertEqual(hiraDue.count, 1)
        XCTAssertEqual(hiraDue.first?.front, "あ")

        let kataDue = store.dueCards(type: .katakana, on: now)
        XCTAssertEqual(kataDue.count, 1)
        XCTAssertEqual(kataDue.first?.front, "ア")
    }
}

