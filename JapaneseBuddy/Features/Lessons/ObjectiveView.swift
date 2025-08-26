import SwiftUI

/// Displays the lesson objective text.
struct ObjectiveView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(text).font(.title2)
            Spacer()
        }
        .padding()
    }
}

