import SwiftUI

/// Simple SRS review screen with grading buttons.
struct SRSView: View {
    @EnvironmentObject var store: DeckStore
    @State private var current: Card?
    @State private var showBack = false
    private let speaker = Speaker()

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                Text(showBack ? card.back : card.front)
                    .font(.system(size: 80))
                    .padding()
                    .onTapGesture { showBack.toggle() }

                HStack(spacing: 20) {
                    Button("Speak") { speaker.speak(card.front) }
                        .accessibilityLabel("Speak card")
                    Button("Flip") { showBack.toggle() }
                        .accessibilityLabel("Flip card")
                }

                HStack(spacing: 20) {
                    Button("Hard") { grade(.hard) }
                        .accessibilityLabel("Mark hard")
                        .accessibilityHint("Schedules sooner")
                    Button("Good") { grade(.good) }
                        .accessibilityLabel("Mark good")
                        .accessibilityHint("Keeps normal pace")
                    Button("Easy") { grade(.easy) }
                        .accessibilityLabel("Mark easy")
                        .accessibilityHint("Delays longer")
                }
            } else {
                Text("All caught up")
            }
        }
        .onAppear(perform: next)
        .navigationTitle("SRS")
        .dynamicTypeSize(... .xxxLarge)
    }

    private func next() {
        current = store.dueCards(type: store.currentType).first
        showBack = false
    }

    private func grade(_ rating: Rating) {
        guard var card = current else { return }
        SRS.apply(rating, to: &card)
        store.update(card)
        store.logReview(for: card)
        Haptics.light()
        next()
    }
}

