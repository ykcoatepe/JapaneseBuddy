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
    @StateObject private var lessons: LessonStore

    init() {
        let deck = DeckStore()
        if CommandLine.arguments.contains("UI-TESTING") {
            deck.hasOnboarded = true
        }
        _store = StateObject(wrappedValue: deck)
        _lessons = StateObject(wrappedValue: LessonStore(deckStore: deck))
    }

    var body: some Scene {
        WindowGroup {
            AppSidebar()
                .environmentObject(store)
                .environmentObject(lessons)
                .tint(Color("AccentColor"))
        }
    }
}
