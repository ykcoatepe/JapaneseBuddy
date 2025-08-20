import SwiftUI

/// Landing screen with deck toggles and navigation tiles.
struct HomeView: View {
    @EnvironmentObject var store: DeckStore
    @EnvironmentObject var lessonStore: LessonStore

    var body: some View {
        VStack(spacing: 24) {
            if let name = store.displayName, !name.isEmpty {
                Text("こんにちは, \(name)!")
                    .font(.title2)
            }
            Picker("Deck", selection: $store.currentType) {
                Text("Hiragana").tag(CardType.hiragana)
                Text("Katakana").tag(CardType.katakana)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Toggle("Pencil only", isOn: $store.pencilOnly)
                .padding(.horizontal)

            DailyGoalCard(progress: store.progressToday())
                .padding(.horizontal)

            HStack(spacing: 20) {
                NavigationLink {
                    KanaTraceView()
                } label: {
                    tile(title: "Kana Trace", count: traceCount, priority: 3)
                }

                NavigationLink {
                    SRSView()
                } label: {
                    tile(title: "SRS", count: srsCount, priority: 2)
                }

                NavigationLink {
                    LessonListView()
                } label: {
                    tile(title: "Lessons", count: lessonCount, priority: 1)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Home")
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .toolbar {
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gear")
            }
        }
    }

    private var traceCount: Int { store.dueCards(type: store.currentType).count }
    private var srsCount: Int { traceCount }
    private var lessonCount: Int { lessonStore.lessons().count }

    @ViewBuilder
    private func tile(title: String, count: Int, priority: Double) -> some View {
        VStack {
            Text(title).font(.title2)
            Text("\(count) due").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint("\(count) due")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(priority)
    }
}
