import Foundation
import Testing
@testable import JapaneseBuddyProj

struct LessonPathSpec {
    @Test func pathStateUnlocksOnlyTheNextIncompleteLesson() {
        let lessons = [
            Lesson(id: "A1-01-Greetings", title: "Greetings", canDo: "Greet people", activities: [.check], tips: []),
            Lesson(id: "A1-04-WhereYouLive", title: "Where You Live", canDo: "Say where you live", activities: [.check], tips: []),
            Lesson(id: "A2-01-Appointments", title: "Appointments", canDo: "Make appointments", activities: [.check], tips: []),
            Lesson(id: "B1-01-InvitationsPlans", title: "Plans", canDo: "Discuss plans", activities: [.check], tips: [])
        ]
        var progress: [String: LessonProgress] = [:]

        #expect(Lesson.pathState(for: lessons[0], in: lessons) { progress[$0] ?? LessonProgress() } == .next)
        #expect(Lesson.pathState(for: lessons[1], in: lessons) { progress[$0] ?? LessonProgress() } == .locked)

        progress["A1-01-Greetings"] = LessonProgress(lastStep: 0, stars: 2, completedAt: Date())

        #expect(Lesson.pathState(for: lessons[0], in: lessons) { progress[$0] ?? LessonProgress() } == .completed)
        #expect(Lesson.pathState(for: lessons[1], in: lessons) { progress[$0] ?? LessonProgress() } == .next)
        #expect(Lesson.pathState(for: lessons[2], in: lessons) { progress[$0] ?? LessonProgress() } == .locked)
        #expect(Lesson.nextLesson(in: lessons) { progress[$0] ?? LessonProgress() }?.id == "A1-04-WhereYouLive")
    }

    @Test func manifestIDsPreserveKnownLevelOrderAndAppendCustomLevels() {
        let manifest = [
            "B1": ["B1-01-InvitationsPlans"],
            "A1": ["A1-01-Greetings"],
            "C1": ["C1-01-Debate"],
            "A2": ["A2-01-Appointments"],
            "B2": ["B2-01-News"]
        ]

        #expect(LessonStore.manifestIDs(from: manifest) == [
            "A1-01-Greetings",
            "A2-01-Appointments",
            "B1-01-InvitationsPlans",
            "B2-01-News",
            "C1-01-Debate"
        ])
    }

    @Test func lessonStoreFallsBackToPathOrderWhenManifestIsMissing() {
        let lessonsByStem = [
            "B1-01-InvitationsPlans": Lesson(
                id: "B1-01-InvitationsPlans",
                title: "Plans",
                canDo: "Discuss plans",
                activities: [.check],
                tips: []
            ),
            "A2-01-Appointments": Lesson(
                id: "A2-01-Appointments",
                title: "Appointments",
                canDo: "Make appointments",
                activities: [.check],
                tips: []
            ),
            "A1-01-Greetings": Lesson(id: "A1-01-Greetings", title: "Greetings", canDo: "Greet people", activities: [.check], tips: [])
        ]

        #expect(LessonStore.orderedLessons(lessonsByStem: lessonsByStem, manifestIDs: []).map(\.id) == [
            "A1-01-Greetings",
            "A2-01-Appointments",
            "B1-01-InvitationsPlans"
        ])
    }
}
