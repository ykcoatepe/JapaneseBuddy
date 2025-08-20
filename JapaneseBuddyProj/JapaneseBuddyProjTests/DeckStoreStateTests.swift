import Foundation
import Testing
@testable import JapaneseBuddyProj

struct DeckStoreStateTests {
    @Test func nameAndGoalPersist() async throws {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        try? FileManager.default.removeItem(at: docs.appendingPathComponent("deck.json"))
        let store = DeckStore()
        store.displayName = "Taro"
        store.dailyGoal.newTarget = 7
        try await Task.sleep(nanoseconds: 1_500_000_000)
        let reload = DeckStore()
        #expect(reload.displayName == "Taro")
        #expect(reload.dailyGoal.newTarget == 7)
    }
}
