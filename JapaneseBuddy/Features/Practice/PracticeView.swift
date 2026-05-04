import SwiftUI

/// Daily practice hub that routes learners into the next useful exercise.
struct PracticeView: View {
    @EnvironmentObject var store: DeckStore
    @EnvironmentObject var lessons: LessonStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                header

                Picker(L10n.Home.deck, selection: $store.currentType) {
                    Text(L10n.Common.hiragana).tag(CardType.hiragana)
                    Text(L10n.Common.katakana).tag(CardType.katakana)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 420)

                LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                    practiceTile(
                        title: L10n.Practice.lesson,
                        detail: lessonDetail,
                        systemImage: "book.fill",
                        destination: .lesson
                    )
                    practiceTile(
                        title: L10n.Practice.trace,
                        detail: String(format: L10n.Practice.dueFmt, dueCount),
                        systemImage: "pencil.tip",
                        destination: .trace
                    )
                    practiceTile(
                        title: L10n.Practice.review,
                        detail: String(format: L10n.Practice.dueFmt, reviewCount),
                        systemImage: "rectangle.on.rectangle",
                        destination: .review
                    )
                }

                DailyGoalCard(progress: progress)
            }
            .frame(maxWidth: 980)
            .padding(Theme.Spacing.large)
            .frame(maxWidth: .infinity)
        }
        .background(Color.washi.ignoresSafeArea())
        .navigationTitle(L10n.Nav.practice)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Typography.title(L10n.Practice.title)
            Typography.label(L10n.Practice.subtitle)
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 240), spacing: Theme.Spacing.medium)]
    }

    private func practiceTile(title: String, detail: String, systemImage: String, destination: PracticeDestination) -> some View {
        NavigationLink {
            destinationView(destination)
        } label: {
            JBCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    Image(systemName: systemImage)
                        .font(.title2.bold())
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: Theme.Spacing.xsmall) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                    Text(L10n.Practice.start)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.accentColor)
                }
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(detail)")
    }

    private var progress: GoalProgress { store.progressToday() }
    private var dueCount: Int { store.dueCards(type: store.currentType).count }
    private var reviewCount: Int { store.dueCards(type: store.currentType).count }

    private var nextLesson: Lesson? {
        lessons.nextLesson()
    }

    private var lessonDetail: String {
        guard let lesson = nextLesson else { return L10n.Practice.noLesson }
        return "\(lesson.pathCode) \(lesson.title)"
    }

    @ViewBuilder
    private func destinationView(_ destination: PracticeDestination) -> some View {
        switch destination {
        case .lesson:
            if let nextLesson {
                LessonRunnerView(lesson: nextLesson)
            } else {
                LessonListView()
            }
        case .trace:
            KanaTraceView()
        case .review:
            SRSView()
        }
    }
}

private enum PracticeDestination {
    case lesson, trace, review
}
