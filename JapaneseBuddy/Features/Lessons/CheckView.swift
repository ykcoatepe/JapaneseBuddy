import SwiftUI

/// Final self assessment with star rating.
struct CheckView: View {
    struct Star: Identifiable { let id: Int }
    let current: Int
    var onFinish: (Int) -> Void
    @State private var rating = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Can-do Check").font(.title2)
            HStack {
                let stars = [Star(id: 1), Star(id: 2), Star(id: 3)]
                ForEach(stars) { star in
                    Image(systemName: star.id <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .font(.largeTitle)
                        .onTapGesture { rating = star.id }
                }
            }
            Button("Done") { onFinish(rating) }
                .disabled(rating == 0)
            Spacer()
        }
        .padding()
        .onAppear { rating = current }
    }
}

