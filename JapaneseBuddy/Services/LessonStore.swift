import Foundation

/// Manages lesson packs and per-lesson progress.
final class LessonStore: ObservableObject {
    struct LevelProgress {
        let completed: Int
        let total: Int

        var ratio: Double {
            guard total > 0 else { return 0 }
            return Double(completed) / Double(total)
        }
    }

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
        let folderURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "lessons")
        let rootURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)
#if DEBUG
        if let folderURLs { print("ℹ️ LessonStore: found \(folderURLs.count) json(s) under 'lessons' folder in bundle") }
        if let rootURLs { print("ℹ️ LessonStore: found \(rootURLs.count) json(s) at bundle root") }
#endif
        var urls: [URL] = []
        if let folderURLs { urls.append(contentsOf: folderURLs) }
        if let rootURLs { urls.append(contentsOf: rootURLs) }
        // Filter out non-lesson JSONs (e.g., potential index.json) and de-duplicate by filename
        urls = urls
            .filter { $0.lastPathComponent.lowercased() != "index.json" }
            .reduce(into: [String: URL]()) { dict, url in
                dict[url.lastPathComponent] = dict[url.lastPathComponent] ?? url
            }
            .values.sorted { $0.lastPathComponent < $1.lastPathComponent }
#if DEBUG
        if urls.isEmpty {
            print("⚠️ LessonStore: no JSONs found in bundle (bundlePath=\(Bundle.main.bundlePath)). Check Copy Bundle Resources.")
        }
#endif

        var lessonsByStem: [String: Lesson] = [:]
        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let lesson = try decoder.decode(Lesson.self, from: data)
                lessonsByStem[url.deletingPathExtension().lastPathComponent] = lesson
            } catch {
#if DEBUG
                print("⚠️ Lesson decode error for \(url.lastPathComponent): \(error)")
#endif
            }
        }
        let manifestIDs = loadLessonManifestIDs(decoder: decoder)
        cached = Self.orderedLessons(lessonsByStem: lessonsByStem, manifestIDs: manifestIDs)
#if DEBUG
        print("✅ LessonStore: loaded \(cached.count) / \(urls.count) JSON file(s).")
#endif
    }

    private func loadLessonManifestIDs(decoder: JSONDecoder) -> [String] {
        let urls = [
            Bundle.main.url(forResource: "index", withExtension: "json", subdirectory: "lessons"),
            Bundle.main.url(forResource: "index", withExtension: "json")
        ].compactMap { $0 }

        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let manifest = try decoder.decode([String: [String]].self, from: data)
                return Self.manifestIDs(from: manifest)
            } catch {
#if DEBUG
                print("⚠️ Lesson manifest decode error for \(url.lastPathComponent): \(error)")
#endif
            }
        }
        return []
    }

    static func manifestIDs(from manifest: [String: [String]]) -> [String] {
        let knownLevels = Lesson.Level.allCases
            .filter { $0 != .other }
            .map(\.rawValue)
        let remainingLevels = manifest.keys
            .filter { !knownLevels.contains($0) }
            .sorted()
        return (knownLevels + remainingLevels).flatMap { manifest[$0] ?? [] }
    }

    static func orderedLessons(lessonsByStem: [String: Lesson], manifestIDs: [String]) -> [Lesson] {
        guard !manifestIDs.isEmpty else {
            return Lesson.orderedPath(Array(lessonsByStem.values))
        }
        return manifestIDs.compactMap { lessonsByStem[$0] }
    }

    func lessons() -> [Lesson] { cached }

    func orderedLessons() -> [Lesson] {
        cached
    }

    func pathState(for lesson: Lesson) -> Lesson.PathState {
        guard let index = cached.firstIndex(where: { $0.id == lesson.id }) else { return .locked }
        if progress(for: lesson.id).isCompleted {
            return .completed
        }
        if index == 0 {
            return .next
        }
        let previous = cached[index - 1]
        return progress(for: previous.id).isCompleted ? .next : .locked
    }

    func nextLesson() -> Lesson? {
        cached.first { pathState(for: $0) == .next }
    }

    func levelProgress(for level: Lesson.Level) -> LevelProgress {
        let lessons = cached.filter { $0.level == level }
        let completed = lessons.filter { progress(for: $0.id).isCompleted }.count
        return LevelProgress(completed: completed, total: lessons.count)
    }

    func progress(for id: String) -> LessonProgress {
        deckStore.progress(for: id)
    }

    func updateProgress(_ progress: LessonProgress, for id: String) {
        deckStore.updateProgress(progress, for: id)
    }
}
