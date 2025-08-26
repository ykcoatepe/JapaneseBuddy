import Foundation

/// Manages lesson packs and per-lesson progress.
final class LessonStore: ObservableObject {
    private let deckStore: DeckStore
    private var cached: [Lesson] = []

    init(deckStore: DeckStore) {
        self.deckStore = deckStore
        loadLessons()
    }

    private func loadLessons() {
        let decoder = JSONDecoder()
        // Prefer bundled "lessons" folder (blue folder reference). Fallback to flat bundle files.
        let fromFolder = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "lessons")
        let fromRoot = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)
#if DEBUG
        if let u1 = fromFolder { print("ℹ️ LessonStore: found \(u1.count) json(s) under 'lessons' folder in bundle") }
        if let u2 = fromRoot { print("ℹ️ LessonStore: found \(u2.count) json(s) at bundle root") }
#endif
        let urls = (fromFolder ?? fromRoot) ?? []
#if DEBUG
        if urls.isEmpty {
            print("⚠️ LessonStore: no JSONs found in bundle (bundlePath=\(Bundle.main.bundlePath)). Check Copy Bundle Resources.")
        }
#endif

        var loaded: [Lesson] = []
        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let lesson = try decoder.decode(Lesson.self, from: data)
                loaded.append(lesson)
            } catch {
#if DEBUG
                print("⚠️ Lesson decode error for \(url.lastPathComponent): \(error)")
#endif
            }
        }
        cached = loaded.sorted { $0.id < $1.id }
#if DEBUG
        print("✅ LessonStore: loaded \(cached.count) / \(urls.count) JSON file(s).")
#endif
    }

    func lessons() -> [Lesson] { cached }

    func progress(for id: String) -> LessonProgress {
        deckStore.progress(for: id)
    }

    func updateProgress(_ p: LessonProgress, for id: String) {
        deckStore.updateProgress(p, for: id)
    }
}
