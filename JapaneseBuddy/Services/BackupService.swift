import Foundation

struct BackupService {
    private var deckURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("deck.json")
    }

    func exportURL() -> URL { deckURL }

    func importDeck(from url: URL, into store: DeckStore) throws {
        let data = try Data(contentsOf: url)
        let state: DeckStore.State
        if let s = try? JSONDecoder().decode(DeckStore.State.self, from: data) {
            state = s
        } else if let cards = try? JSONDecoder().decode([Card].self, from: data) {
            state = DeckStore.State(cards: cards)
        } else {
            throw BackupError.invalidSchema
        }
        try data.write(to: deckURL, options: [.atomic])
        DispatchQueue.main.async { store.replace(with: state) }
    }

    enum BackupError: LocalizedError {
        case invalidSchema
        var errorDescription: String? { "Invalid deck.json format." }
    }
}
