import SwiftUI

enum JBButtonStyleKind { case primary, secondary }

struct JBButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let kind: JBButtonStyleKind
    let action: (() -> Void)?

    init(_ title: String, kind: JBButtonStyleKind = .primary, action: (() -> Void)? = nil) {
        self.title = title; self.kind = kind; self.action = action
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    private var content: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .foregroundColor(foregroundColor)
            .padding(.horizontal)
            .background(
                Group { if kind == .primary { backgroundColor } else { Color.clear } }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor.opacity(isEnabled ? 1 : 0.45), lineWidth: kind == .secondary ? 1 : 0)
            )
            .cornerRadius(10)
            .accessibilityAddTraits(.isButton)
            .opacity(isEnabled ? 1 : 0.65)
    }

    private var foregroundColor: Color {
        if kind == .primary {
            return Color.white.opacity(isEnabled ? 1 : 0.75)
        }
        return Color.accentColor.opacity(isEnabled ? 1 : 0.45)
    }

    private var backgroundColor: Color {
        Color.accentColor.opacity(isEnabled ? 1 : 0.45)
    }
}
