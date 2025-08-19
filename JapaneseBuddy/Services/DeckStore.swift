import Foundation
import Combine

final class DeckStore: ObservableObject {
    @Published var cards: [Card] = []
    @Published var pencilOnly = true
    @Published var currentType: CardType = .hiragana
    @Published var dailyGoal = DailyGoal()
    @Published var notificationsEnabled = false
    @Published var reminderTime: DateComponents?
    @Published private(set) var sessionLog: [SessionLogEntry] = []

    private let url: URL
    private var saveTask: AnyCancellable?

    struct State: Codable {
        var cards: [Card]
        var dailyGoal: DailyGoal = DailyGoal()
        var notificationsEnabled: Bool = false
        var reminderTime: ReminderTime?
        var sessionLog: [SessionLogEntry] = []

        struct ReminderTime: Codable {
            var hour: Int
            var minute: Int
            init(_ comps: DateComponents) { hour = comps.hour ?? 0; minute = comps.minute ?? 0 }
            var components: DateComponents { DateComponents(hour: hour, minute: minute) }
        }
    }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = docs.appendingPathComponent("deck.json")
        load()
        saveTask = Publishers.CombineLatest4($cards, $dailyGoal, $notificationsEnabled, $reminderTime)
            .combineLatest($sessionLog)
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
        } else if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
            cards = decoded
        } else {
            cards = SeedData.makeCards()
        }
    }

    private func save() {
        let reminder = reminderTime.map { State.ReminderTime($0) }
        let state = State(cards: cards, dailyGoal: dailyGoal, notificationsEnabled: notificationsEnabled, reminderTime: reminder, sessionLog: sessionLog)
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: url, options: .atomic)
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
}
