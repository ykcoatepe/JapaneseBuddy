import SwiftUI

/// Displays available lessons with star progress.
struct LessonListView: View {
    @EnvironmentObject var lessons: LessonStore

    var body: some View {
        List {
            ForEach(lessons.lessons()) { lesson in
                let progress = lessons.progress(for: lesson.id)
                NavigationLink {
                    LessonRunnerView(lesson: lesson)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lesson.title).font(.headline)
                            let stars = String(repeating: "★", count: progress.stars)
                            Text("\(stars) \(progress.lastStep)/\(lesson.activities.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Lessons")
    }
}
