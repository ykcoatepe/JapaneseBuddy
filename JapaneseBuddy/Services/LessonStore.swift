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
        // Discover lesson JSONs both under a bundled "lessons" folder (blue folder reference)
        // and at the bundle root, then merge. This is resilient to mixed project setups.
        let fromFolder = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "lessons")
        let fromRoot = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)
#if DEBUG
        if let u1 = fromFolder { print("ℹ️ LessonStore: found \(u1.count) json(s) under 'lessons' folder in bundle") }
        if let u2 = fromRoot { print("ℹ️ LessonStore: found \(u2.count) json(s) at bundle root") }
#endif
        var urls: [URL] = []
        if let u1 = fromFolder { urls.append(contentsOf: u1) }
        if let u2 = fromRoot { urls.append(contentsOf: u2) }
        // Filter out non-lesson JSONs (e.g., potential index.json) and de-duplicate by filename
        urls = urls
            .filter { $0.lastPathComponent.lowercased() != "index.json" }
            .reduce(into: [String: URL]()) { dict, url in dict[url.lastPathComponent] = url }
            .values.sorted { $0.lastPathComponent < $1.lastPathComponent }
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
