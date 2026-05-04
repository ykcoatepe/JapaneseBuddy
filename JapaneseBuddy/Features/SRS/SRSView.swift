import SwiftUI

/// Simple SRS review screen with grading buttons.
struct SRSView: View {
    @EnvironmentObject var store: DeckStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var current: Card?
    @State private var showBack = false
    private let speaker = Speaker()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                if let card = current {
                    JBCard {
                        VStack(spacing: Theme.Spacing.medium) {
                            reviewHeader(card)
                            Text(showBack ? card.back : card.front)
                                .font(.system(size: 88, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 240)
                                .minimumScaleFactor(0.45)
                                .contentShape(Rectangle())
                                .onTapGesture { showBack.toggle() }
                                .accessibilityLabel(showBack ? L10n.Review.cardBack : L10n.Review.cardFront)

                            actionGrid(card)

                            ratingGrid
                        }
                    }
                } else {
                    JBCard {
                        VStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.accentColor)
                                .accessibilityHidden(true)
                            Text(L10n.Review.allCaughtUp)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 220)
                    }
                }
            }
            .frame(maxWidth: 760)
            .padding(Theme.Spacing.large)
            .frame(maxWidth: .infinity)
        }
        .background(Color.washi.ignoresSafeArea())
        .onAppear {
            next()
            if let current {
                store.beginStudy(for: current)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .inactive, .background:
                store.endStudy(kind: .study)
            case .active:
                if let current {
                    store.beginStudy(for: current)
                }
            @unknown default:
                break
            }
        }
        .onDisappear { store.endStudy(kind: .study) }
        .navigationTitle(L10n.Nav.review)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private func reviewHeader(_ card: Card) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xsmall) {
                Text(L10n.Nav.review)
                    .font(.headline)
                Text(showBack ? card.reading : L10n.Review.tapToFlip)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: L10n.Review.dueFmt, dueCount))
                .font(.caption.bold())
                .padding(.horizontal, Theme.Spacing.small)
                .padding(.vertical, Theme.Spacing.xsmall)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
        }
    }

    private func actionGrid(_ card: Card) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: Theme.Spacing.small)], spacing: Theme.Spacing.small) {
            JBButton(L10n.Btn.speak, kind: .secondary) { speaker.speak(card.front) }
                .accessibilityLabel(L10n.Review.speakCard)
            JBButton(L10n.Review.flip, kind: .secondary) { showBack.toggle() }
                .accessibilityLabel(L10n.Review.flipCard)
        }
    }

    private var ratingGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: Theme.Spacing.small)], spacing: Theme.Spacing.small) {
            JBButton(L10n.Btn.hard, kind: .secondary) { grade(.hard) }
                .accessibilityLabel(L10n.Review.markHard)
                .accessibilityHint(L10n.Review.schedulesSooner)
            JBButton(L10n.Btn.good) { grade(.good) }
                .accessibilityLabel(L10n.Review.markGood)
                .accessibilityHint(L10n.Review.keepsNormalPace)
            JBButton(L10n.Btn.easy, kind: .secondary) { grade(.easy) }
                .accessibilityLabel(L10n.Review.markEasy)
                .accessibilityHint(L10n.Review.delaysLonger)
        }
    }

    private var dueCount: Int {
        store.dueCards(type: store.currentType).count
    }

    private func next() {
        current = store.dueCards(type: store.currentType).first
        showBack = false
        if let current {
            store.beginStudy(for: current)
        } else {
            store.endStudy(kind: .study)
        }
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
