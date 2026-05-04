import SwiftUI

/// Drives a lesson through its ordered activities.
struct LessonRunnerView: View {
    @EnvironmentObject var lessons: LessonStore
    @EnvironmentObject var deck: DeckStore
    let lesson: Lesson

    @State private var step = 0
    @State private var selection: Int?
    @State private var tab = 0
    @State private var completedStars: Int?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                if lesson.kanjiWords?.isEmpty == false {
                    Picker(L10n.Lessons.mode, selection: $tab) {
                        Text(L10n.Lessons.lessonMode).tag(0)
                        Text(L10n.Lessons.kanjiMode).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 420)
                }

                if tab == 0 {
                    lessonPanel
                } else if let words = lesson.kanjiWords {
                    KanjiPracticeView(words: words, lessonID: lesson.id, store: deck)
                        .frame(maxWidth: 760)
                }
            }
            .frame(maxWidth: 820)
            .padding(Theme.Spacing.large)
            .frame(maxWidth: .infinity)
        }
        .background(Color.washi.ignoresSafeArea())
        .navigationTitle(lesson.title)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .onAppear {
            let last = lessons.progress(for: lesson.id).lastStep
            step = min(max(0, last), max(lesson.activities.count - 1, 0))
            deck.beginStudy()
        }
        .onDisappear {
            deck.endStudy(kind: .study)
        }
    }

    private var lessonPanel: some View {
        JBCard {
            VStack(spacing: Theme.Spacing.medium) {
                Picker(L10n.Lessons.step, selection: stepBinding) {
                    ForEach(0..<stepLabels.count, id: \.self) { index in
                        Text(stepLabels[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)

                contentView
                    .frame(maxWidth: .infinity, minHeight: 360)

                Divider()

                HStack {
                    if hasPrevStep {
                        JBButton(L10n.Lessons.back, kind: .secondary) { back() }
                            .frame(maxWidth: 180)
                    }
                    Spacer()
                    if !isCheck && hasNextStep {
                        JBButton(L10n.Lessons.next) { next() }
                            .frame(maxWidth: 180)
                            .disabled(disableNext)
                    }
                }
            }
        }
    }

    private var stepLabels: [String] {
        lesson.activities.map { activityLabel($0) }
    }

    private var stepBinding: Binding<Int> {
        Binding(
            get: { step },
            set: { move(to: $0) }
        )
    }

    private func activityLabel(_ activity: Lesson.Activity) -> String {
        switch activity {
        case .objective: return L10n.Lessons.objective
        case .shadow: return L10n.Lessons.shadow
        case .listening: return L10n.Lessons.listening
        case .reading: return L10n.Lessons.reading
        case .check: return L10n.Lessons.check
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if !(step >= 0 && step < lesson.activities.count) {
            Text(L10n.Lessons.completeTitle)
        } else {
            switch lesson.activities[step] {
            case let .objective(text):
                ObjectiveView(text: text)
            case let .shadow(segments):
                ShadowingView(lessonID: lesson.id, segments: segments)
            case let .listening(prompt, choices, answer):
                ListeningView(prompt: prompt, choices: choices, answer: answer, selection: $selection)
            case let .reading(prompt, items, answer):
                ReadingView(prompt: prompt, items: items, answer: answer, selection: $selection)
            case .check:
                if let completedStars {
                    lessonCompleteView(stars: completedStars)
                } else {
                    CheckView(current: lessons.progress(for: lesson.id).stars) { stars in
                        finishLesson(stars: stars)
                    }
                }
            }
        }
    }

    private func lessonCompleteView(stars: Int) -> some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text(L10n.Lessons.completeTitle)
                .font(.title2.bold())
            Text(String(format: L10n.Lessons.completedStarsFmt, stars))
                .font(.headline)
                .foregroundStyle(.secondary)

            if let nextLesson = lessons.nextLesson(), nextLesson.id != lesson.id {
                Text("\(nextLesson.pathCode) \(nextLesson.title)")
                    .font(.headline)
                Text(nextLesson.canDo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                NavigationLink {
                    LessonRunnerView(lesson: nextLesson)
                } label: {
                    JBButton(L10n.Lessons.startNext)
                }
                .padding(.top, Theme.Spacing.small)
            } else {
                NavigationLink {
                    LessonListView()
                } label: {
                    JBButton(L10n.Nav.lessons)
                }
                .padding(.top, Theme.Spacing.small)
            }
        }
        .padding()
        .frame(maxWidth: 520)
        .accessibilityElement(children: .combine)
    }

    private func finishLesson(stars: Int) {
        var progress = lessons.progress(for: lesson.id)
        let wasCompleted = progress.isCompleted
        progress.stars = stars
        progress.completedAt = Date()
        progress.lastStep = step
        lessons.updateProgress(progress, for: lesson.id)
        if !wasCompleted {
            deck.logLessonCompletion()
        }
        completedStars = stars
    }

    private func next() {
        guard hasNextStep else { return }
        move(to: step + 1)
    }

    private func back() {
        guard hasPrevStep else { return }
        move(to: step - 1)
    }

    private func move(to targetStep: Int) {
        let clampedStep = min(max(0, targetStep), max(lesson.activities.count - 1, 0))
        guard clampedStep != step else { return }
        step = clampedStep
        var progress = lessons.progress(for: lesson.id)
        progress.lastStep = step
        lessons.updateProgress(progress, for: lesson.id)
        selection = nil
        completedStars = nil
    }

    private var isCheck: Bool {
        guard step >= 0, step < lesson.activities.count else { return false }
        if case .check = lesson.activities[step] { return true }
        return false
    }

    private var disableNext: Bool {
        guard step >= 0, step < lesson.activities.count else { return true }
        switch lesson.activities[step] {
        case .listening, .reading:
            return selection == nil
        default:
            return false
        }
    }

    private var hasNextStep: Bool {
        step + 1 < lesson.activities.count
    }

    private var hasPrevStep: Bool {
        step > 0
    }
}
