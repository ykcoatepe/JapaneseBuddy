import SwiftUI

/// Reading comprehension via multiple choice.
struct ReadingView: View {
    struct Item: Identifiable { let id: Int; let text: String }
    let prompt: String
    let items: [String]
    let answer: Int
    @Binding var selection: Int?

    var body: some View {
        let choices = items.enumerated().map { Item(id: $0.offset, text: $0.element) }
        return VStack(alignment: .leading, spacing: 20) {
            Text(prompt).font(.title3)
            ForEach(choices) { item in
                Button(item.text) { selection = item.id }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(background(item.id))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
        }
        .padding()
    }

    private func background(_ idx: Int) -> Color {
        guard let sel = selection else { return Color.blue.opacity(0.1) }
        if idx == sel {
            return sel == answer ? .green.opacity(0.3) : .red.opacity(0.3)
        } else if idx == answer {
            return .green.opacity(0.3)
        } else {
            return Color.blue.opacity(0.1)
        }
    }
}

