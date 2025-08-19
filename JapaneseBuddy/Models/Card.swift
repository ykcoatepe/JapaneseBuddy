import Foundation

/// Type of study card. `kana` keeps the test targets compiling.
enum CardType: String, Codable, CaseIterable, Identifiable {
    case hiragana
    case katakana

    var id: String { rawValue }

    /// Compatibility case for early tests; maps to hiragana.
    static var kana: CardType { .hiragana }
}

/// User rating for a review step.
enum Rating: String, Codable { case hard, good, easy }

/// Simple review stats.
struct CardStats: Codable { var reviews = 0 }

/// Flash card model backing SRS and tracing screens.
struct Card: Identifiable, Codable {
    var id = UUID()
    var type: CardType
    var front: String
    var back: String
    var reading: String = ""
    var ease: Double = 2.5
    var interval: Int = 0
    var nextDue: Date = .distantPast
    var stats = CardStats()

    init(id: UUID = UUID(), type: CardType, front: String, back: String, reading: String = "") {
        self.id = id
        self.type = type
        self.front = front
        self.back = back
        self.reading = reading.isEmpty ? back : reading
    }
}

