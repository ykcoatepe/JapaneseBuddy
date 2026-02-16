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

    @Test func splitsStudyDurationsAcrossMidnight() {
        let stateURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-midnight-\(UUID().uuidString).json")
        try? FileManager.default.removeItem(at: stateURL)
        let store = DeckStore(stateURL: stateURL, saveDebounce: .seconds(999))

        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .minute, value: 23 * 60 + 50, to: dayStart)!
        let end = cal.date(byAdding: .minute, value: 20, to: start)! // crosses midnight

        store.beginStudy(now: start)
        store.endStudy(now: end, cal: cal)

        let nextDay = cal.date(byAdding: .day, value: 1, to: dayStart)!
        #expect(store.minutesToday(now: dayStart, cal: cal) == 10)
        #expect(store.minutesToday(now: nextDay, cal: cal) == 10)

        let studyEntries = store.sessionLog.filter { $0.kind == .study }
        #expect(studyEntries.count == 2)
    }

    @Test func minutesTodayIncludesInFlightStudyTime() {
        let stateURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-live-minutes-\(UUID().uuidString).json")
        try? FileManager.default.removeItem(at: stateURL)
        let store = DeckStore(stateURL: stateURL, saveDebounce: .seconds(999))

        let cal = Calendar.current
        let now = Date()
        let start = cal.date(byAdding: .minute, value: -15, to: now)!
        store.beginStudy(now: start)

        // 15 in-flight minutes should be visible before endStudy is called.
        #expect(store.minutesToday(now: now, cal: cal) >= 15)
    }

    @Test func weeklyTotalMinutesRoundsAfterAggregatingWeekSeconds() {
        let stateURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-week-total-\(UUID().uuidString).json")
        try? FileManager.default.removeItem(at: stateURL)
        let store = DeckStore(stateURL: stateURL, saveDebounce: .seconds(999))

        let cal = Calendar.current
        let startToday = cal.startOfDay(for: Date())
        let now = cal.date(byAdding: .hour, value: 12, to: startToday)!

        for dayOffset in 0..<7 {
            let day = cal.date(byAdding: .day, value: -dayOffset, to: startToday)!
            let start = cal.date(byAdding: .second, value: 1, to: day)!
            let end = cal.date(byAdding: .second, value: 59, to: start)! // 59 seconds
            store.beginStudy(now: start)
            store.endStudy(now: end, cal: cal)
        }

        #expect(store.weeklyMinutes(now: now, cal: cal).reduce(0, +) == 0)
        #expect(store.weeklyTotalMinutes(now: now, cal: cal) == 6)
    }
}

