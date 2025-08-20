import SwiftUI

struct KanjiPracticeView: View {
    let words: [KanjiWord]
    let lessonID: String
    @ObservedObject var store: DeckStore
    @State private var index = 0
    @State private var input = ""
    @State private var message: String?
    private let speaker = Speaker()

    var body: some View {
        VStack(spacing: 24) {
            Text(words[index].kanji)
                .font(.system(size: 120))
            TextField("reading", text: $input)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
            HStack {
                Button("Check") { check() }
                Button("Speak") { speaker.speak(words[index].kanji) }
            }
            if let message {
                Text(message).foregroundColor(.secondary)
            }
            Button("Next") { next() }
                .disabled(message != "Correct!")
        }
        .padding()
        .onAppear {
            var p = store.kanjiProgress[lessonID] ?? DeckStore.KanjiProgress()
            p.total = words.count
            store.kanjiProgress[lessonID] = p
        }
    }

    private func check() {
        let expected = words[index].reading
        if input.trimmingCharacters(in: .whitespacesAndNewlines) == expected {
            message = "Correct!"
            store.markKanjiCorrect(words[index], in: lessonID)
        } else {
            message = "Try again"
        }
    }

    private func next() {
        index = (index + 1) % words.count
        input = ""
        message = nil
    }
}
