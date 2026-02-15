import Foundation
import Testing
@testable import JapaneseBuddyProj

struct KanjiDecodeTests {
    @Test func decodeAndPersist() async throws {
        // fresh store
        let stateURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-kanji-\(UUID().uuidString).json")
        try? FileManager.default.removeItem(at: stateURL)
        let store = DeckStore(stateURL: stateURL, saveDebounce: .milliseconds(50))

        // decode lesson pack
        final class BundleProbe {}
        let candidates = [Bundle.main, Bundle(for: BundleProbe.self)]
        let url = candidates
            .compactMap { $0.url(forResource: "A1-01-Greetings", withExtension: "json", subdirectory: "lessons")
                ?? $0.url(forResource: "A1-01-Greetings", withExtension: "json", subdirectory: nil) }
            .first
        #expect(url != nil)
        let data = try Data(contentsOf: url!)
        let lesson = try JSONDecoder().decode(Lesson.self, from: data)
        #expect(lesson.kanjiWords?.count ?? 0 > 0)

        let lessonID = lesson.id
        let before = store.kanjiProgress[lessonID]?.correct ?? 0
        if let word = lesson.kanjiWords?.first {
            store.markKanjiCorrect(word, in: lessonID)
        }
        // allow debounce save (50 ms debounce + buffer)
        try await Task.sleep(nanoseconds: 200_000_000)
        let after = store.kanjiProgress[lessonID]?.correct ?? 0
        #expect(after == before + 1)

        let reloaded = DeckStore(stateURL: stateURL)
        let persisted = reloaded.kanjiProgress[lessonID]?.correct ?? 0
        #expect(persisted == after)
    }
}
