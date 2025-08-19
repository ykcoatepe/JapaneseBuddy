//
//  ContentView.swift
//  JapaneseBuddyProj
//
//  Created by Yordam Kocatepe on 19.08.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = DeckStore()

    var body: some View {
        NavigationStack {
            HomeView()
                .environmentObject(store)
        }
    }
}

//#Preview {
//    ContentView()
//}
