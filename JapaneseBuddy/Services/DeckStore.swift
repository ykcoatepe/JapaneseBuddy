import Foundation
import Combine

enum ThemeMode: String, Codable, CaseIterable { case system, light, dark }

final class DeckStore: ObservableObject {
    @Published var cards: [Card] = []
    @Published var pencilOnly = true
    @Published var currentType: CardType = .hiragana
    @Published var dailyGoal = DailyGoal()
    @Published var notificationsEnabled = false
    @Published var reminderTime: DateComponents?
    @Published var showStrokeHints = true
    @Published var playSpeechInSilentMode = true
    @Published private(set) var sessionLog: [SessionLogEntry] = []
    @Published var lessonProgress: [String: LessonProgress] = [:]
    @Published var kanjiProgress: [String: KanjiProgress] = [:]
    @Published var displayName: String?
    @Published var hasOnboarded = false
    @Published var themeMode: ThemeMode = .system

    private let url: URL
    private var saveTask: AnyCancellable?
    private var studyStart: Date?

    struct State: Codable {
        var cards: [Card]
        var dailyGoal: DailyGoal = DailyGoal()
        var notificationsEnabled: Bool = false
        var reminderTime: ReminderTime?
        var sessionLog: [SessionLogEntry] = []
        var showStrokeHints: Bool = true
        var playSpeechInSilentMode: Bool = true
        var lessonProgress: [String: LessonProgress] = [:]
        var kanjiProgress: [String: KanjiProgress] = [:]
        var displayName: String?
        var hasOnboarded: Bool = false
        var themeMode: ThemeMode = .system

        struct ReminderTime: Codable {
            var hour: Int
            var minute: Int
            init(_ comps: DateComponents) { hour = comps.hour ?? 0; minute = comps.minute ?? 0 }
            var components: DateComponents { DateComponents(hour: hour, minute: minute) }
        }
    }

    struct KanjiProgress: Codable { var correct: Int = 0; var total: Int = 0 }

    init(stateURL: URL? = nil, saveDebounce: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)) {
        if let stateURL {
            url = stateURL
        } else {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            url = docs.appendingPathComponent("deck.json")
        }
        load()
        // Mirror audio preference to UserDefaults for lightweight access in Speaker
        UserDefaults.standard.set(playSpeechInSilentMode, forKey: "playSpeechInSilentMode")

        saveTask = Publishers.CombineLatest4($cards, $dailyGoal, $notificationsEnabled, $reminderTime)
            .combineLatest($sessionLog)
            .combineLatest($showStrokeHints)
            .combineLatest($playSpeechInSilentMode)
            .combineLatest($lessonProgress)
            .combineLatest($kanjiProgress)
            .combineLatest($displayName)
            .combineLatest($hasOnboarded)
            .combineLatest($themeMode)
            .debounce(for: saveDebounce, scheduler: DispatchQueue.global())
            .sink { [weak self] _ in
                // Keep UserDefaults in sync for the Speaker to read.
                if let self = self {
                    UserDefaults.standard.set(self.playSpeechInSilentMode, forKey: "playSpeechInSilentMode")
                }
                self?.save()
            }
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
            playSpeechInSilentMode = state.playSpeechInSilentMode
            lessonProgress = state.lessonProgress
            kanjiProgress = state.kanjiProgress
            displayName = state.displayName
            hasOnboarded = state.hasOnboarded
            themeMode = state.themeMode
        } else if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
            cards = decoded
        } else {
            cards = SeedData.makeCards()
        }
    }

    func reload() {
        load()
    }

    private func save() {
        let reminder = reminderTime.map { State.ReminderTime($0) }
        let state = State(cards: cards,
                          dailyGoal: dailyGoal,
                          notificationsEnabled: notificationsEnabled,
                          reminderTime: reminder,
                          sessionLog: sessionLog,
                          showStrokeHints: showStrokeHints,
                          playSpeechInSilentMode: playSpeechInSilentMode,
                          lessonProgress: lessonProgress,
                          kanjiProgress: kanjiProgress,
                          displayName: displayName,
                          hasOnboarded: hasOnboarded,
                          themeMode: themeMode)
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
        cards.filter { card in
            guard card.nextDue <= date else { return false }
            if let t = type { return card.type == t }
            return true
        }
    }

    func logNew(for card: Card, date: Date = .now) {
        sessionLog.append(SessionLogEntry(date: date, kind: .new, cardID: card.id, durationSec: nil))
    }

    func logReview(for card: Card, date: Date = .now) {
        sessionLog.append(SessionLogEntry(date: date, kind: .review, cardID: card.id, durationSec: nil))
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

// MARK: - Streak & Weekly Activity
extension DeckStore {
    // Returns 7 counts (oldest → newest) for the last 7 calendar days.
    func weeklyActivity(now: Date = .now, cal: Calendar = .current) -> [Int] {
        let startToday = cal.startOfDay(for: now)
        let days = (0..<7).reversed().compactMap {
            cal.date(byAdding: .day, value: -$0, to: startToday)
        }
        return days.map { day in
            sessionLog.filter { cal.isDate($0.date, inSameDayAs: day) }.count
        }
    }

    // Counts consecutive non-empty days ending today.
    func currentStreak(now: Date = .now, cal: Calendar = .current) -> Int {
        var streak = 0
        var d = cal.startOfDay(for: now)
        while true {
            let c = sessionLog.filter { cal.isDate($0.date, inSameDayAs: d) }.count
            if c > 0 {
                streak += 1
            } else {
                break
            }
            guard let prev = cal.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return streak
    }
}

// MARK: - Stopwatch & Minutes
extension DeckStore {
    func beginStudy(now: Date = .now) {
        if studyStart == nil { studyStart = now }
    }

    func endStudy(kind: SessionKind = .study, now: Date = .now) {
        guard let s = studyStart else { return }
        studyStart = nil
        let dur = max(0, Int(now.timeIntervalSince(s)))
        sessionLog.append(SessionLogEntry(date: now, kind: kind, cardID: nil, durationSec: dur))
    }

    func minutesToday(now: Date = .now, cal: Calendar = .current) -> Int {
        sessionLog
            .filter { cal.isDate($0.date, inSameDayAs: now) }
            .map { ($0.durationSec ?? 0) / 60 }
            .reduce(0, +)
    }

    func weeklyMinutes(now: Date = .now, cal: Calendar = .current) -> [Int] {
        let startToday = cal.startOfDay(for: now)
        let days = (0..<7).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: startToday) }
        return days.map { day in
            sessionLog
                .filter { cal.isDate($0.date, inSameDayAs: day) }
                .map { ($0.durationSec ?? 0) / 60 }
                .reduce(0, +)
        }
    }

    func bestStreak(cal: Calendar = .current) -> Int {
        let days = Set(sessionLog.map { cal.startOfDay(for: $0.date) })
        let sorted = days.sorted()
        var best = 0, cur = 0
        var prev: Date?
        for d in sorted {
            if let p = prev, cal.date(byAdding: .day, value: 1, to: p) == d {
                cur += 1
            } else {
                cur = 1
            }
            best = max(best, cur)
            prev = d
        }
        return best
    }
}
