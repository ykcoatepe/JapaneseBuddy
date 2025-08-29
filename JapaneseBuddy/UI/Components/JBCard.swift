import SwiftUI

struct JBCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ c: ()->Content) { content = c() }
    var body: some View {
        content
            .padding(Theme.Spacing.medium)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium).stroke(.quaternary))
            .cardShadow()
    }
}

