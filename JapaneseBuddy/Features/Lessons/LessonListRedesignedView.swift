import SwiftUI

/// Compatibility shim: v4 keeps a single LessonListView.
/// This view exists to satisfy older Xcode target references.
struct LessonListRedesignedView: View {
    var body: some View {
        LessonListView()
    }
}
