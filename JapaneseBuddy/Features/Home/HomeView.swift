import SwiftUI

/// Landing screen redesigned with design system components.
struct HomeView: View {
    @EnvironmentObject var store: DeckStore
    @EnvironmentObject var lessonStore: LessonStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                if let name = store.displayName, !name.isEmpty {
                    Typography.title("こんにちは, \(name)!")
                        .padding(.horizontal)
                }

                Picker("Deck", selection: $store.currentType) {
                    Text("Hiragana").tag(CardType.hiragana)
                    Text("Katakana").tag(CardType.katakana)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Toggle("Pencil only", isOn: $store.pencilOnly)
                    .padding(.horizontal)

                JBCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Goal").font(.headline)
                        HStack {
                            Label("New \(progress.newDone)/\(progress.target.newTarget)", systemImage: "sparkles")
                            Spacer()
                            Label("Review \(progress.reviewDone)/\(progress.target.reviewTarget)", systemImage: "arrow.triangle.2.circlepath")
                        }.font(.subheadline)
                        ProgressBar(value: ratio(progress))
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Daily goal progress")

                VStack(spacing: Theme.Spacing.small) {
                    Text("Quick Actions").font(.headline).padding(.horizontal)
                    HStack(spacing: Theme.Spacing.small) {
                        NavigationLink { LessonListView() } label: { JBButton("Continue Lesson") }
                        NavigationLink { KanaTraceView() } label: { JBButton("Trace", kind: .secondary) }
                        NavigationLink { SRSView() } label: { JBButton("Review", kind: .secondary) }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, Theme.Spacing.large)
            }
        }
        .background(Color.washi.ignoresSafeArea())
        .navigationTitle("Home")
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .toolbar { }
    }

    private var traceCount: Int { store.dueCards(type: store.currentType).count }
    private var srsCount: Int { traceCount }
    private var lessonCount: Int { lessonStore.lessons().count }
    private var progress: GoalProgress { store.progressToday() }
    private func ratio(_ p: GoalProgress) -> Double {
        let done = p.newDone + p.reviewDone
        let total = max(1, p.target.newTarget + p.target.reviewTarget)
        return Double(done) / Double(total)
    }
}
