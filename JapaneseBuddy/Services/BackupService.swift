import Foundation

enum BackupService {
    static var exportURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("deck.json")
    }

    enum BackupError: Error {
        case invalidFormat
    }

    static func importDeck(from url: URL, into store: DeckStore) throws {
        let data = try Data(contentsOf: url)
        guard (try? JSONDecoder().decode(DeckStore.State.self, from: data)) != nil else {
            throw BackupError.invalidFormat
        }
        try data.write(to: exportURL, options: .atomic)
        store.reload()
    }
}
