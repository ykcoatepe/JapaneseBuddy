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
    @Environment(\.scenePhase) private var scenePhase

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
            Group {
                if store.hasOnboarded {
                    AppSidebar()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .environmentObject(lessons)
            .applyTheme(store.themeMode)
            .tint(Color("AccentColor"))
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    store.beginStudy()
                case .inactive, .background:
                    store.endStudy(kind: .study)
                @unknown default:
                    break
                }
            }
        }
    }
}
