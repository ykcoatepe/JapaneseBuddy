//
//  JapaneseBuddyProjApp.swift
//  JapaneseBuddyProj
//
//  Created by Yordam Kocatepe on 19.08.2025.
//

import SwiftUI

@main
struct JapaneseBuddyProjApp: App {
    @StateObject private var store = DeckStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(store)
        }
    }
}
