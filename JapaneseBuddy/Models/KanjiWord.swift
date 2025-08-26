import Foundation

struct KanjiWord: Codable, Identifiable, Equatable {
    let id: String   // e.g., "A1-01-名"
    let kanji: String
    let reading: String   // hiragana
    let meaning: String
}
