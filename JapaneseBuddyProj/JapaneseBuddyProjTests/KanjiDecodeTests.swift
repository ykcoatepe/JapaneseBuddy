import Foundation
import Testing
@testable import JapaneseBuddyProj

struct KanjiDecodeTests {
    @Test func decodeAndPersist() async throws {
        // fresh store
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        try? FileManager.default.removeItem(at: docs.appendingPathComponent("deck.json"))
        let store = DeckStore()

        // decode lesson pack
        let bundle = Bundle.module
        let url = bundle.url(forResource: "A1-01-Greetings", withExtension: "json", subdirectory: "lessons")!
        let data = try Data(contentsOf: url)
        let lesson = try JSONDecoder().decode(Lesson.self, from: data)
        #expect(lesson.kanjiWords?.count ?? 0 > 0)

        let lessonID = lesson.id
        let before = store.kanjiProgress[lessonID]?.correct ?? 0
        if let word = lesson.kanjiWords?.first {
            store.markKanjiCorrect(word, in: lessonID)
        }
        // allow debounce save
        try await Task.sleep(nanoseconds: 1_500_000_000)
        let after = store.kanjiProgress[lessonID]?.correct ?? 0
        #expect(after == before + 1)

        let reloaded = DeckStore()
        let persisted = reloaded.kanjiProgress[lessonID]?.correct ?? 0
        #expect(persisted == after)
    }
}
