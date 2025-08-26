import Foundation

/// Stored state for a lesson run.
struct LessonProgress: Codable {
    var lastStep: Int = 0
    var stars: Int = 0
    var completedAt: Date?
}

