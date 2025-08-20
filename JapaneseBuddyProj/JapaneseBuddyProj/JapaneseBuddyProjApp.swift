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
        _store = StateObject(wrappedValue: deck)
        _lessonStore = StateObject(wrappedValue: LessonStore(deckStore: deck))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(store)
            .environmentObject(lessonStore)
        }
    }
}
