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
                            Text(lesson.canDo).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(repeating: "★", count: progress.stars))
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
        .navigationTitle("Lessons")
    }
}

