import SwiftUI

enum JBButtonStyleKind { case primary, secondary }

struct JBButton: View {
    let title: String
    let kind: JBButtonStyleKind
    let action: (() -> Void)?
    init(_ title: String, kind: JBButtonStyleKind = .primary, action: (() -> Void)? = nil) {
        self.title = title; self.kind = kind; self.action = action
    }
    var body: some View {
        let content = Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .foregroundColor(kind == .primary ? .white : .accentColor)
            .padding(.horizontal)
            .background(
                Group { if kind == .primary { Color.accentColor } else { Color.clear } }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: kind == .secondary ? 1 : 0)
            )
            .cornerRadius(10)
            .accessibilityAddTraits(.isButton)

        return Group {
            if let action {
                content.onTapGesture(perform: action)
            } else {
                content
            }
        }
    }
}
