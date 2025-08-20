import XCTest
@testable import JapaneseBuddy

final class LessonDecodeTests: XCTestCase {
    func testLessonsDecode() {
        let store = LessonStore(deckStore: DeckStore())
        let lessons = store.lessons()
        XCTAssertEqual(lessons.count, 2)
        XCTAssertEqual(lessons.first?.id, "A1-01")
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

