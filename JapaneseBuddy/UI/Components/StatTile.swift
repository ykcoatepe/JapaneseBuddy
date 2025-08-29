import SwiftUI

struct StatTile: View {
    let title: String
    let value: String
    var body: some View {
        JBCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Text(value).font(.system(size: 34, weight: .bold))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value)")
    }
}

