//
//  JapaneseBuddyProjApp.swift
//  JapaneseBuddyProj
//
//  Created by Yordam Kocatepe on 19.08.2025.
//

import SwiftUI

@main
struct JapaneseBuddyProjApp: App {
    @StateObject private var store: DeckStore
    @StateObject private var lessonStore: LessonStore

    init() {
        let deck = DeckStore()
        if CommandLine.arguments.contains("UI-TESTING") {
            deck.hasOnboarded = true
        }
        _store = StateObject(wrappedValue: deck)
        _lessonStore = StateObject(wrappedValue: LessonStore(deckStore: deck))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if store.hasOnboarded {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .tint(Color("AccentColor"))
            .environmentObject(store)
            .environmentObject(lessonStore)
        }
    }
}
