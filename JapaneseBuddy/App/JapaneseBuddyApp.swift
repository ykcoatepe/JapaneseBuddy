import SwiftUI

/// Entry point wiring the shared `DeckStore` and initial navigation stack.
@main
struct JapaneseBuddyApp: App {
    @StateObject private var store = DeckStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack { HomeView() }
                .environmentObject(store)
        }
    }
}

