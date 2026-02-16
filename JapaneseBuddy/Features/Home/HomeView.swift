import SwiftUI

/// Landing screen redesigned with design system components.
struct HomeView: View {
    @EnvironmentObject var store: DeckStore
    @EnvironmentObject var lessonStore: LessonStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                if let name = store.displayName, !name.isEmpty {
                    Typography.title(String(format: L10n.Home.greeting, name))
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
                        Text(L10n.Home.dailyGoal).font(.headline)
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

                // Streak row + 7‑day sparkline
                let counts = store.weeklyActivity()
                let maxVal = max(1, counts.max() ?? 1)
                let normalized = counts.map { Double($0) / Double(maxVal) }

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(format: L10n.Stats.todayMinutesFmt, store.minutesToday()))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(String(format: L10n.Stats.todayMinutesFmt, store.minutesToday()))
                    Text(String(format: L10n.Stats.streakFmt, store.currentStreak()))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(String(format: L10n.Stats.streakFmt, store.currentStreak()))
                    Sparkline(values: normalized)
                        .frame(height: 36)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal)

                VStack(spacing: Theme.Spacing.small) {
                    Text("Quick Actions").font(.headline).padding(.horizontal)
                    HStack(spacing: Theme.Spacing.small) {
                        NavigationLink {
                            if let lesson = continueLesson {
                                LessonRunnerView(lesson: lesson)
                            } else {
                                LessonListView()
                            }
                        } label: { JBButton(L10n.Btn.continueLesson) }
                        NavigationLink { KanaTraceView() } label: { JBButton(L10n.Btn.startTrace, kind: .secondary) }
                        NavigationLink { SRSView() } label: { JBButton(L10n.Btn.startReview, kind: .secondary) }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, Theme.Spacing.large)
            }
        }
        .background(Color.washi.ignoresSafeArea())
        .navigationTitle(L10n.Nav.home)
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

    private var continueLesson: Lesson? {
        lessonStore.lessons().first { lessonStore.progress(for: $0.id).lastStep < $0.activities.count - 1 }
    }
}
