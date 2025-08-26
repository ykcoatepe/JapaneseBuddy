import SwiftUI

/// Drives a lesson through its ordered activities.
struct LessonRunnerView: View {
    @EnvironmentObject var lessons: LessonStore
    @EnvironmentObject var deck: DeckStore
    let lesson: Lesson

    @State private var step = 0
    @State private var selection: Int?
    @State private var tab = 0

    var body: some View {
        VStack {
            if lesson.kanjiWords?.isEmpty == false {
                Picker("Mode", selection: $tab) {
                    Text("Lesson").tag(0)
                    Text("Kanji").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
            }
            if tab == 0 {
                VStack {
                    contentView
                    if !isCheck && hasNextStep {
                        Button("Next") { next() }
                            .padding()
                            .disabled(disableNext)
                    }
                }
            } else if let words = lesson.kanjiWords {
                KanjiPracticeView(words: words, lessonID: lesson.id, store: deck)
            }
        }
        .navigationTitle(lesson.title)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .onAppear {
            let last = lessons.progress(for: lesson.id).lastStep
            step = min(max(0, last), max(lesson.activities.count - 1, 0))
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if !(step >= 0 && step < lesson.activities.count) {
            Text("Lesson complete")
        } else {
            switch lesson.activities[step] {
            case let .objective(text):
                ObjectiveView(text: text)
            case let .shadow(segments):
                ShadowingView(segments: segments)
            case let .listening(prompt, choices, answer):
                ListeningView(prompt: prompt, choices: choices, answer: answer, selection: $selection)
            case let .reading(prompt, items, answer):
                ReadingView(prompt: prompt, items: items, answer: answer, selection: $selection)
            case .check:
                CheckView(current: lessons.progress(for: lesson.id).stars) { stars in
                    var p = lessons.progress(for: lesson.id)
                    p.stars = stars
                    p.completedAt = Date()
                    p.lastStep = step
                    lessons.updateProgress(p, for: lesson.id)
                }
            }
        }
    }

    private func next() {
        guard hasNextStep else { return }
        step += 1
        var p = lessons.progress(for: lesson.id)
        p.lastStep = step
        lessons.updateProgress(p, for: lesson.id)
        selection = nil
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
}
