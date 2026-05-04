import SwiftUI

struct KanjiPracticeView: View {
    let words: [KanjiWord]
    let lessonID: String
    @ObservedObject var store: DeckStore
    @State private var index = 0
    @State private var input = ""
    @State private var state: AnswerState = .idle
    private let speaker = Speaker()

    var body: some View {
        JBCard {
            VStack(spacing: Theme.Spacing.large) {
                header
                Text(currentWord.kanji)
                    .font(.system(size: 132, weight: .bold))
                    .minimumScaleFactor(0.45)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .accessibilityLabel(currentWord.kanji)
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text(currentWord.meaning)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    TextField(L10n.Kanji.readingPlaceholder, text: $input)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit { check() }
                }
                controls
                if state != .idle {
                    Text(feedbackText)
                        .font(.subheadline.bold())
                        .foregroundStyle(state == .correct ? Color.accentColor : .secondary)
                        .accessibilityLabel(feedbackText)
                }
            }
        }
        .onAppear {
            updateTotal()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xsmall) {
                Text(L10n.Kanji.title)
                    .font(.headline)
                Text(String(format: L10n.Kanji.progressFmt, index + 1, words.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(currentWord.reading)
                .font(.caption.bold())
                .padding(.horizontal, Theme.Spacing.small)
                .padding(.vertical, Theme.Spacing.xsmall)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
                .opacity(state == .correct ? 1 : 0)
        }
    }

    private var controls: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: Theme.Spacing.small)], spacing: Theme.Spacing.small) {
            JBButton(L10n.Btn.speak, kind: .secondary) { speaker.speak(currentWord.kanji) }
                .accessibilityLabel(L10n.Kanji.speakKanji)
            JBButton(L10n.Btn.check) { check() }
                .accessibilityLabel(L10n.Kanji.checkReading)
            JBButton(L10n.Kanji.next, kind: .secondary) { next() }
                .disabled(state != .correct)
                .accessibilityLabel(L10n.Kanji.next)
        }
    }

    private var currentWord: KanjiWord {
        words[min(index, max(words.count - 1, 0))]
    }

    private var feedbackText: String {
        switch state {
        case .idle: return ""
        case .correct: return L10n.Kanji.correct
        case .tryAgain: return String(format: L10n.Kanji.tryAgainFmt, currentWord.reading)
        }
    }

    private func check() {
        let expected = currentWord.reading.trimmingCharacters(in: .whitespacesAndNewlines)
        let answer = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if !expected.isEmpty, answer == expected {
            state = .correct
            store.markKanjiCorrect(currentWord, in: lessonID)
        } else {
            state = .tryAgain
        }
    }

    private func next() {
        index = (index + 1) % words.count
        input = ""
        state = .idle
        updateTotal()
    }

    private func updateTotal() {
        var progress = store.kanjiProgress[lessonID] ?? DeckStore.KanjiProgress()
        progress.total = words.count
        store.kanjiProgress[lessonID] = progress
    }

    private enum AnswerState {
        case idle, correct, tryAgain
    }
}
