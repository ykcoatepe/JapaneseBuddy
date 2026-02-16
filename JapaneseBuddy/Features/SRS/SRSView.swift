import SwiftUI

/// Simple SRS review screen with grading buttons.
struct SRSView: View {
    @EnvironmentObject var store: DeckStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var current: Card?
    @State private var showBack = false
    private let speaker = Speaker()

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                JBCard {
                    Text(showBack ? card.back : card.front)
                        .font(.system(size: 80))
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .minimumScaleFactor(0.5)
                        .onTapGesture { showBack.toggle() }
                }

                HStack(spacing: Theme.Spacing.small) {
                    JBButton(L10n.Btn.speak, kind: .secondary) { speaker.speak(card.front) }
                        .accessibilityLabel("Speak card")
                    JBButton("Flip", kind: .secondary) { showBack.toggle() }
                        .accessibilityLabel("Flip card")
                }

                HStack(spacing: Theme.Spacing.small) {
                    JBButton(L10n.Btn.hard, kind: .secondary) { grade(.hard) }
                        .accessibilityLabel("Mark hard")
                        .accessibilityHint("Schedules sooner")
                    JBButton(L10n.Btn.good) { grade(.good) }
                        .accessibilityLabel("Mark good")
                        .accessibilityHint("Keeps normal pace")
                    JBButton(L10n.Btn.easy, kind: .secondary) { grade(.easy) }
                        .accessibilityLabel("Mark easy")
                        .accessibilityHint("Delays longer")
                }
            } else {
                Text("All caught up")
            }
        }
        .onAppear {
            next()
            if current != nil { store.beginStudy() }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .inactive, .background:
                store.endStudy(kind: .study)
            case .active:
                if current != nil { store.beginStudy() }
            @unknown default:
                break
            }
        }
        .onDisappear { store.endStudy(kind: .study) }
        .navigationTitle(L10n.Nav.review)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
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
