import SwiftUI

/// Lessons list with filter chips and progress stars.
struct LessonListView: View {
    @EnvironmentObject var lessons: LessonStore
    @State private var filter = 0 // 0: All, 1:A1, 2:A2

    var body: some View {
        List {
            Picker("Filter", selection: $filter) {
                Text("All").tag(0); Text("A1").tag(1); Text("A2").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)

            ForEach(filtered) { lesson in
                let progress = lessons.progress(for: lesson.id)
                NavigationLink {
                    LessonRunnerView(lesson: lesson)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text(lesson.title).font(.headline)
                            Text("\(String(repeating: "★", count: progress.stars)) \(progress.lastStep)/\(lesson.activities.count)")
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

    private var filtered: [Lesson] {
        let all = lessons.lessons()
        switch filter {
        case 1: return all.filter { $0.id.hasPrefix("A1") }
        case 2: return all.filter { $0.id.hasPrefix("A2") }
        default: return all
        }
    }
}
