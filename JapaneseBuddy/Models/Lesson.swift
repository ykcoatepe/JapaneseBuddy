import Foundation

/// Learning unit backed by a series of activities.
struct Lesson: Codable, Identifiable {
    var id: String
    var title: String
    var canDo: String
    var activities: [Activity]
    var tips: [String]
    var kanjiWords: [KanjiWord]?

    enum Activity: Codable {
        case objective(text: String)
        case shadow(segments: [String])
        case listening(prompt: String, choices: [String], answer: Int)
        case reading(prompt: String, items: [String], answer: Int)
        case check

        private enum CodingKeys: String, CodingKey {
            case objective, shadow, listening, reading, check
        }

        private struct Objective: Codable { var text: String }
        private struct Shadow: Codable { var segments: [String] }
        private struct MCQ: Codable {
            var prompt: String
            var choices: [String]
            var answer: Int
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let obj = try container.decodeIfPresent(Objective.self, forKey: .objective) {
                self = .objective(text: obj.text)
            } else if let sh = try container.decodeIfPresent(Shadow.self, forKey: .shadow) {
                self = .shadow(segments: sh.segments)
            } else if let mcq = try container.decodeIfPresent(MCQ.self, forKey: .listening) {
                self = .listening(prompt: mcq.prompt, choices: mcq.choices, answer: mcq.answer)
            } else if let mcq = try container.decodeIfPresent(MCQ.self, forKey: .reading) {
                self = .reading(prompt: mcq.prompt, items: mcq.choices, answer: mcq.answer)
            } else if container.contains(.check) {
                self = .check
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown activity"))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .objective(text):
                try container.encode(Objective(text: text), forKey: .objective)
            case let .shadow(segments):
                try container.encode(Shadow(segments: segments), forKey: .shadow)
            case let .listening(prompt, choices, answer):
                try container.encode(MCQ(prompt: prompt, choices: choices, answer: answer), forKey: .listening)
            case let .reading(prompt, items, answer):
                try container.encode(MCQ(prompt: prompt, choices: items, answer: answer), forKey: .reading)
            case .check:
                try container.encode([String: String](), forKey: .check)
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, canDo, activities, tips, kanjiWords
    }

    init(id: String, title: String, canDo: String, activities: [Activity], tips: [String], kanjiWords: [KanjiWord]? = nil) {
        self.id = id
        self.title = title
        self.canDo = canDo
        self.activities = activities
        self.tips = tips
        self.kanjiWords = kanjiWords
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        canDo = try container.decode(String.self, forKey: .canDo)
        activities = try container.decode([Activity].self, forKey: .activities)
        tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []
        if let words = try container.decodeIfPresent([KanjiWord].self, forKey: .kanjiWords) {
            kanjiWords = words
        } else if let strings = try container.decodeIfPresent([String].self, forKey: .kanjiWords) {
            kanjiWords = strings.map { KanjiWord(id: "\(id)-\($0)", kanji: $0, reading: "", meaning: "") }
        } else {
            kanjiWords = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(canDo, forKey: .canDo)
        try container.encode(activities, forKey: .activities)
        try container.encode(tips, forKey: .tips)
        try container.encodeIfPresent(kanjiWords, forKey: .kanjiWords)
    }
}
