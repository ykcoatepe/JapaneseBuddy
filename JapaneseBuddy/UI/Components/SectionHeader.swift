import SwiftUI

struct SectionHeader: View {
    let title: String
    var trailing: AnyView? = nil
    init(_ title: String, trailing: AnyView? = nil) { self.title = title; self.trailing = trailing }
    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
            if let t = trailing { t }
        }
        .padding(.horizontal)
        .padding(.top, Theme.Spacing.small)
    }
}

