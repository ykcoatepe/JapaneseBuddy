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

                Picker(L10n.Home.deck, selection: $store.currentType) {
                    Text(L10n.Common.hiragana).tag(CardType.hiragana)
                    Text(L10n.Common.katakana).tag(CardType.katakana)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Toggle(L10n.Home.pencilOnly, isOn: $store.pencilOnly)
                    .padding(.horizontal)

                DailyGoalCard(progress: progress)
                    .padding(.horizontal)

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
                    HomeSparkline(values: normalized)
                        .frame(height: 36)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal)

                if let lesson = continueLesson {
                    JBCard {
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            Text(L10n.Home.nextLesson)
                                .font(.headline)
                            Text("\(lesson.pathCode) \(lesson.title)")
                                .font(.title3.bold())
                            Text(lesson.canDo)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            NavigationLink {
                                LessonRunnerView(lesson: lesson)
                            } label: {
                                JBButton(L10n.Btn.continueLesson)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(L10n.Home.nextLesson), \(lesson.title), \(lesson.canDo)")
                }

                JBCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Text(L10n.Home.courseProgress)
                            .font(.headline)
                        ForEach(courseLevels, id: \.self) { level in
                            courseProgressRow(level)
                        }
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .contain)

                VStack(spacing: Theme.Spacing.small) {
                    Text(L10n.Home.quickActions).font(.headline).padding(.horizontal)
                    quickActions
                }
                .padding(.bottom, Theme.Spacing.large)
            }
        }
        .background(Color.washi.ignoresSafeArea())
        .navigationTitle(L10n.Nav.home)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .toolbar { }
    }

    private var progress: GoalProgress { store.progressToday() }

    private var quickActionColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 180), spacing: Theme.Spacing.small)
        ]
    }

    private var quickActions: some View {
        LazyVGrid(columns: quickActionColumns, spacing: Theme.Spacing.small) {
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

    private var continueLesson: Lesson? {
        lessonStore.nextLesson()
    }

    private var courseLevels: [Lesson.Level] {
        Lesson.Level.allCases.filter { lessonStore.levelProgress(for: $0).total > 0 }
    }

    private func courseProgressRow(_ level: Lesson.Level) -> some View {
        let levelProgress = lessonStore.levelProgress(for: level)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(level.title)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(levelProgress.completed)/\(levelProgress.total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressBar(value: levelProgress.ratio)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(level.title), \(String(format: L10n.Common.countProgressFmt, levelProgress.completed, levelProgress.total))"
        )
    }
}

private struct HomeSparkline: View {
    let values: [Double]
    private let lineWidth: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let segmentCount = max(1, values.count - 1)
            let points: [CGPoint] = values.enumerated().map { (index, value) in
                let positionX = CGFloat(index) / CGFloat(segmentCount) * width
                let positionY = height - CGFloat(value) * height
                return CGPoint(x: positionX, y: positionY)
            }
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round,
                                       lineJoin: .round))
        }
    }
}
