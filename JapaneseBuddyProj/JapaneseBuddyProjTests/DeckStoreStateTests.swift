import Foundation
import Testing
@testable import JapaneseBuddyProj

struct DeckStoreStateTests {
    @Test func nameAndGoalPersist() async throws {
        let stateURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("deck-state-\(UUID().uuidString).json")
        try? FileManager.default.removeItem(at: stateURL)

        let store = DeckStore(stateURL: stateURL, saveDebounce: .milliseconds(50))
        store.displayName = "Taro"
        var goal = store.dailyGoal
        goal.newTarget = 7
        store.dailyGoal = goal

        // Short debounce (50 ms) + small buffer
        try await Task.sleep(nanoseconds: 200_000_000)

        let reload = DeckStore(stateURL: stateURL)
        #expect(reload.displayName == "Taro")
        #expect(reload.dailyGoal.newTarget == 7)
    }
}
