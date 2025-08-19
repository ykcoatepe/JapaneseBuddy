import Foundation
import Combine

/// Manages persistence and due card queries.
final class DeckStore: ObservableObject {
    @Published var cards: [Card] = []
    @Published var pencilOnly = true
    @Published var currentType: CardType = .hiragana

    private let url: URL
    private var saveTask: AnyCancellable?

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = docs.appendingPathComponent("deck.json")
        load()
        // save on changes with debounce
        saveTask = $cards
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] _ in self?.save() }
    }

    /// Loads cards from disk or seed data on first launch.
    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Card].self, from: data) else {
            cards = SeedData.makeCards()
            save()
            return
        }
        cards = decoded
    }

    /// Persists cards atomically.
    private func save() {
        guard let data = try? JSONEncoder().encode(cards) else { return }
        do {
            try data.write(to: url, options: .atomic)
        } catch { print("Deck save error: \(error)") }
    }

    /// Updates an existing card in memory and schedules persistence.
    func update(_ card: Card) {
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            cards[idx] = card
        }
    }

    /// Returns cards due on or before the given date filtered by type.
    func dueCards(type: CardType?, on date: Date = Date()) -> [Card] {
        cards.filter { card in
            card.nextDue <= date && (type == nil || card.type == type!)
        }
    }
}

