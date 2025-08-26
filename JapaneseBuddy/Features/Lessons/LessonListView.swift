import SwiftUI

/// Displays available lessons with star progress.
struct LessonListView: View {
    @EnvironmentObject var lessons: LessonStore

    // Load index ordering from lessons/index.json if present; otherwise nil
    private func loadIndexOrder() -> [String]? {
        let bundle = Bundle.main
        // Prefer lessons folder
        if let url = bundle.url(forResource: "index", withExtension: "json", subdirectory: "lessons") ?? bundle.url(forResource: "index", withExtension: "json") {
            if let data = try? Data(contentsOf: url),
               let ids = try? JSONDecoder().decode([String].self, from: data),
               !ids.isEmpty {
                return ids
            }
        }
        return nil
    }

    private func ordered(_ list: [Lesson]) -> [Lesson] {
        if let order = loadIndexOrder() {
            let position: [String: Int] = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
            return list.sorted { (a, b) in
                let pa = position[a.id] ?? Int.max
                let pb = position[b.id] ?? Int.max
                if pa == pb { return a.id < b.id }
                return pa < pb
            }
        } else {
            // Fallback to id sort (LessonStore already sorts, this is just safety)
            return list.sorted { $0.id < $1.id }
        }
    }

    var body: some View {
        List {
            ForEach(ordered(lessons.lessons())) { lesson in
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
