import SwiftUI

/// Multiple choice listening activity.
struct ListeningView: View {
    struct Item: Identifiable { let id: Int; let text: String }
    let prompt: String
    let choices: [String]
    let answer: Int
    @Binding var selection: Int?

    var body: some View {
        let items = choices.enumerated().map { Item(id: $0.offset, text: $0.element) }
        return VStack(alignment: .leading, spacing: 20) {
            Text(prompt).font(.title3)
            ForEach(items) { item in
                Button(item.text) { selection = item.id }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(background(item.id))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityHint(accessibilityHint(item.id))
            }
            if let feedback {
                Text(feedback)
                    .font(.subheadline.bold())
                    .foregroundStyle(selection == answer ? Color.accentColor : .secondary)
            }
            Spacer()
        }
        .padding()
    }

    private var feedback: String? {
        guard let selection else { return nil }
        return selection == answer ? L10n.Lessons.correctChoice : L10n.Lessons.tryAgainChoice
    }

    private func accessibilityHint(_ idx: Int) -> String {
        guard let selection, selection == idx else { return "" }
        return idx == answer ? L10n.Lessons.correctChoice : L10n.Lessons.tryAgainChoice
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
