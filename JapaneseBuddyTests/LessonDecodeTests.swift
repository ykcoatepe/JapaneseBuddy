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

    func testKanjiWordsDecodeFromObjects() throws {
        let json = #"""
        {
          "id": "T-1",
          "title": "Test",
          "canDo": "Decode",
          "activities": [{"check": {}}],
          "tips": [],
          "kanjiWords": [
            {"id": "T-1-水", "kanji": "水", "reading": "みず", "meaning": "water"}
          ]
        }
        """#

        let lesson = try JSONDecoder().decode(Lesson.self, from: Data(json.utf8))
        XCTAssertEqual(lesson.kanjiWords?.count, 1)
        XCTAssertEqual(lesson.kanjiWords?.first?.kanji, "水")
        XCTAssertEqual(lesson.kanjiWords?.first?.reading, "みず")
    }

    func testKanjiWordsDecodeFromStringsBackCompat() throws {
        let json = #"""
        {
          "id": "T-2",
          "title": "Test",
          "canDo": "Decode",
          "activities": [{"check": {}}],
          "tips": [],
          "kanjiWords": ["水", "食"]
        }
        """#

        let lesson = try JSONDecoder().decode(Lesson.self, from: Data(json.utf8))
        XCTAssertEqual(lesson.kanjiWords?.count, 2)
        XCTAssertEqual(lesson.kanjiWords?[0].id, "T-2-水")
        XCTAssertEqual(lesson.kanjiWords?[0].kanji, "水")
        XCTAssertEqual(lesson.kanjiWords?[0].reading, "")
        XCTAssertEqual(lesson.kanjiWords?[0].meaning, "")
    }
}


