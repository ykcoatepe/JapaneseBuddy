import XCTest
@testable import JapaneseBuddy

final class LessonDecodeTests: XCTestCase {
    func testLessonsDecode() {
        let store = LessonStore(deckStore: DeckStore())
        let lessons = store.lessons()
        XCTAssertGreaterThanOrEqual(lessons.count, 5)
        let ids = lessons.map { $0.id }
        XCTAssertTrue(ids.contains("A1-05"))
        XCTAssertTrue(ids.contains("A1-06"))
        XCTAssertTrue(ids.contains("A1-07"))
    }

    func testProgressUpdatePersists() {
        let deck = DeckStore()
        let store = LessonStore(deckStore: deck)
        var progress = store.progress(for: "A1-01")
        progress.lastStep = 2
        progress.stars = 3
        store.updateProgress(progress, for: "A1-01")
        let loaded = store.progress(for: "A1-01")
        XCTAssertEqual(loaded.lastStep, 2)
        XCTAssertEqual(loaded.stars, 3)
    }
}

