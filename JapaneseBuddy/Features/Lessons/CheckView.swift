import SwiftUI

/// Final self assessment with star rating.
struct CheckView: View {
    struct Star: Identifiable { let id: Int }
    let current: Int
    var onFinish: (Int) -> Void
    @State private var rating = 0

    var body: some View {
        VStack(spacing: 24) {
            Text(L10n.Lessons.canDoCheck).font(.title2.bold())
            HStack {
                let stars = [Star(id: 1), Star(id: 2), Star(id: 3)]
                ForEach(stars) { star in
                    Image(systemName: star.id <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .font(.largeTitle)
                        .onTapGesture { rating = clampedRating(star.id) }
                        .accessibilityLabel(String(format: L10n.Lessons.starRatingFmt, star.id))
                        .accessibilityAddTraits(star.id == rating ? [.isSelected, .isButton] : .isButton)
                }
            }
            JBButton(L10n.Lessons.done) { onFinish(rating) }
                .disabled(rating == 0)
                .frame(maxWidth: 280)
            Spacer()
        }
        .padding()
        .onAppear { rating = clampedRating(current) }
    }

    private func clampedRating(_ value: Int) -> Int {
        min(max(0, value), 3)
    }
}
