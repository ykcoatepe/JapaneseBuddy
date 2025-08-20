import Foundation

/// Learning unit backed by a series of activities.
struct Lesson: Codable, Identifiable {
    var id: String
    var title: String
    var canDo: String
    var activities: [Activity]
    var tips: [String]
    var kanjiWords: [String]

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
}

