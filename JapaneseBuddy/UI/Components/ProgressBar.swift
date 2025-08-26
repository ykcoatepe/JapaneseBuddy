import SwiftUI

struct ProgressBar: View {
    let value: Double // 0...1
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(Color.secondary.opacity(0.2))
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(Color.accentColor)
                    .frame(width: max(0, min(geo.size.width, geo.size.width * value)))
                    .animation(.easeOut(duration: 0.25), value: value)
            }
        }
        .frame(height: 8)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(value * 100)) percent")
    }
}

