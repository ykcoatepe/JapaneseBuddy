import Foundation

/// Simplified SM‑2 spaced repetition algorithm.
enum SRS {
    /// Applies a rating to mutate card scheduling values.
    static func apply(_ rating: Rating, to card: inout Card, today: Date = Date()) {
        // ease adjustments
        switch rating {
        case .hard: card.ease = max(1.3, card.ease - 0.2)
        case .good: break
        case .easy: card.ease += 0.15
        }

        // interval progression: 0→1→3→round(prev*ease)
        if card.interval == 0 {
            card.interval = 1
        } else if card.interval == 1 {
            card.interval = 3
        } else {
            card.interval = max(1, Int((Double(card.interval) * card.ease).rounded()))
        }

        let next = Calendar.current.date(byAdding: .day, value: card.interval, to: today) ?? today
        card.nextDue = next
        card.stats.reviews += 1
    }
}

