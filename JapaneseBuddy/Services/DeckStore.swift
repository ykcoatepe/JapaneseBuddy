import Foundation
import Combine

final class DeckStore: ObservableObject {
    @Published var cards: [Card] = []
    @Published var pencilOnly = true
    @Published var currentType: CardType = .hiragana
    @Published var dailyGoal = DailyGoal()
    @Published var notificationsEnabled = false
    @Published var reminderTime: DateComponents?
    @Published var showStrokeHints = true
    @Published private(set) var sessionLog: [SessionLogEntry] = []
    @Published var lessonProgress: [String: LessonProgress] = [:]
    @Published var kanjiProgress: [String: KanjiProgress] = [:]
    @Published var displayName: String?
    @Published var hasOnboarded = false

    private let url: URL
    private var saveTask: AnyCancellable?

    struct State: Codable {
        var cards: [Card]
        var dailyGoal: DailyGoal = DailyGoal()
        var notificationsEnabled: Bool = false
        var reminderTime: ReminderTime?
        var sessionLog: [SessionLogEntry] = []
        var showStrokeHints: Bool = true
        var lessonProgress: [String: LessonProgress] = [:]
        var kanjiProgress: [String: KanjiProgress] = [:]
        var displayName: String?
        var hasOnboarded: Bool = false

        struct ReminderTime: Codable {
            var hour: Int
            var minute: Int
            init(_ comps: DateComponents) { hour = comps.hour ?? 0; minute = comps.minute ?? 0 }
            var components: DateComponents { DateComponents(hour: hour, minute: minute) }
        }
    }

    struct KanjiProgress: Codable { var correct: Int = 0; var total: Int = 0 }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = docs.appendingPathComponent("deck.json")
        load()
        saveTask = Publishers.CombineLatest4($cards, $dailyGoal, $notificationsEnabled, $reminderTime)
            .combineLatest($sessionLog)
            .combineLatest($showStrokeHints)
            .combineLatest($lessonProgress)
            .combineLatest($kanjiProgress)
            .combineLatest($displayName)
            .combineLatest($hasOnboarded)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] _ in self?.save() }
    }

    private func load() {
        guard let data = try? Data(contentsOf: url) else {
            cards = SeedData.makeCards()
            save()
            return
        }
        if let state = try? JSONDecoder().decode(State.self, from: data) {
            cards = state.cards
            dailyGoal = state.dailyGoal
            notificationsEnabled = state.notificationsEnabled
            reminderTime = state.reminderTime?.components
            sessionLog = state.sessionLog
            showStrokeHints = state.showStrokeHints
            lessonProgress = state.lessonProgress
            kanjiProgress = state.kanjiProgress
            displayName = state.displayName
            hasOnboarded = state.hasOnboarded
        } else if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
            cards = decoded
        } else {
            cards = SeedData.makeCards()
        }
    }

    private func save() {
        let reminder = reminderTime.map { State.ReminderTime($0) }
        let state = State(cards: cards, dailyGoal: dailyGoal, notificationsEnabled: notificationsEnabled, reminderTime: reminder, sessionLog: sessionLog, showStrokeHints: showStrokeHints, lessonProgress: lessonProgress, kanjiProgress: kanjiProgress, displayName: displayName, hasOnboarded: hasOnboarded)
        guard let data = try? JSONEncoder().encode(state) else { return }
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            Log.app.error("save failed: \(error.localizedDescription)")
        }
    }

    func update(_ card: Card) {
        if let idx = cards.firstIndex(where: { $0.id == card.id }) { cards[idx] = card }
    }

    func dueCards(type: CardType?, on date: Date = Date()) -> [Card] {
        cards.filter { $0.nextDue <= date && (type == nil || $0.type == type!) }
    }

    func logNew(for card: Card, date: Date = .now) {
        sessionLog.append(SessionLogEntry(date: date, kind: .new, cardID: card.id))
    }

    func logReview(for card: Card, date: Date = .now) {
        sessionLog.append(SessionLogEntry(date: date, kind: .review, cardID: card.id))
    }

    func progressToday(now: Date = .now, cal: Calendar = .current) -> GoalProgress {
        GoalProgress.compute(entries: sessionLog, on: now, goal: dailyGoal, cal: cal)
    }

    // MARK: - Lessons

    func progress(for lessonID: String) -> LessonProgress {
        lessonProgress[lessonID] ?? LessonProgress()
    }

    func updateProgress(_ progress: LessonProgress, for lessonID: String) {
        lessonProgress[lessonID] = progress
    }

    func markKanjiCorrect(_ w: KanjiWord, in lessonID: String) {
        if let idx = cards.firstIndex(where: { $0.type == .vocab && $0.front == w.kanji }) {
            if cards[idx].interval == 0 { SRS.apply(.good, to: &cards[idx]) }
        } else {
            var c = Card(type: .vocab, front: w.kanji, back: w.meaning, reading: w.reading)
            SRS.apply(.good, to: &c)
            cards.append(c)
        }
        var p = kanjiProgress[lessonID] ?? KanjiProgress()
        p.correct += 1
        kanjiProgress[lessonID] = p
    }
}
