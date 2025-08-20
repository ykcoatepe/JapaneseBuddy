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
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "lessons") else { return }
        let decoder = JSONDecoder()
        cached = urls.compactMap { url in
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? decoder.decode(Lesson.self, from: data)
        }.sorted { $0.id < $1.id }
    }

    func lessons() -> [Lesson] { cached }

    func progress(for id: String) -> LessonProgress {
        deckStore.progress(for: id)
    }

    func updateProgress(_ p: LessonProgress, for id: String) {
        deckStore.updateProgress(p, for: id)
    }
}

