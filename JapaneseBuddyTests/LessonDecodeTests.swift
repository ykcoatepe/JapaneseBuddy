import XCTest
@testable import JapaneseBuddy

final class LessonDecodeTests: XCTestCase {
    func testLessonsDecode() {
        let store = LessonStore(deckStore: DeckStore())
        let lessons = store.lessons()
        XCTAssertGreaterThanOrEqual(lessons.count, 5)
        let ids = lessons.map { $0.id }
        XCTAssertTrue(ids.contains("A1-05"))
        XCTAssertTrue(ids.contains("A1-06"))
        XCTAssertTrue(ids.contains("A1-07"))
        XCTAssertTrue(ids.contains("A2-05"))
        XCTAssertTrue(ids.contains("A2-06"))
    }

    func testProgressUpdatePersists() {
        let deck = DeckStore()
        let store = LessonStore(deckStore: deck)
        var progress = store.progress(for: "A1-01")
        progress.lastStep = 2
        progress.stars = 3
        store.updateProgress(progress, for: "A1-01")
        let loaded = store.progress(for: "A1-01")
        XCTAssertEqual(loaded.lastStep, 2)
        XCTAssertEqual(loaded.stars, 3)
    }

    func testKanjiWordsDecodeFromObjects() throws {
        let json = #"""
        {
          "id": "T-1",
          "title": "Test",
          "canDo": "Decode",
          "activities": [{"check": {}}],
          "tips": [],
          "kanjiWords": [
            {"id": "T-1-水", "kanji": "水", "reading": "みず", "meaning": "water"}
          ]
        }
        """#

        let lesson = try JSONDecoder().decode(Lesson.self, from: Data(json.utf8))
        XCTAssertEqual(lesson.kanjiWords?.count, 1)
        XCTAssertEqual(lesson.kanjiWords?.first?.kanji, "水")
        XCTAssertEqual(lesson.kanjiWords?.first?.reading, "みず")
    }

    func testKanjiWordsDecodeFromStringsBackCompat() throws {
        let json = #"""
        {
          "id": "T-2",
          "title": "Test",
          "canDo": "Decode",
          "activities": [{"check": {}}],
          "tips": [],
          "kanjiWords": ["水", "食"]
        }
        """#

        let lesson = try JSONDecoder().decode(Lesson.self, from: Data(json.utf8))
        XCTAssertEqual(lesson.kanjiWords?.count, 2)
        XCTAssertEqual(lesson.kanjiWords?[0].id, "T-2-水")
        XCTAssertEqual(lesson.kanjiWords?[0].kanji, "水")
        XCTAssertEqual(lesson.kanjiWords?[0].reading, "")
        XCTAssertEqual(lesson.kanjiWords?[0].meaning, "")
    }

    func testLessonLevelAndPathNumberSupportIntermediatePath() {
        let a1 = Lesson(id: "A1-05-Prices", title: "Prices", canDo: "Ask prices", activities: [.check], tips: [])
        let a1Second = Lesson(
            id: "A1-02-ClassroomPhrases",
            title: "Classroom Phrases",
            canDo: "Ask for repetition",
            activities: [.check],
            tips: []
        )
        let a1Eighth = Lesson(
            id: "A1-08-AskingDirections",
            title: "Asking Directions",
            canDo: "Ask directions",
            activities: [.check],
            tips: []
        )
        let a2 = Lesson(id: "A2-01-Appointments", title: "Appointments", canDo: "Make appointments", activities: [.check], tips: [])
        let a2Second = Lesson(
            id: "A2-02-ReturnsExchanges",
            title: "Returns and Exchanges",
            canDo: "Ask for an exchange",
            activities: [.check],
            tips: []
        )
        let a2Fourth = Lesson(
            id: "A2-04-ClinicVisit",
            title: "Clinic Visit",
            canDo: "Describe symptoms",
            activities: [.check],
            tips: []
        )
        let a2Sixth = Lesson(
            id: "A2-06-Invitations",
            title: "Invitations",
            canDo: "Accept invitations",
            activities: [.check],
            tips: []
        )
        let b1 = Lesson(id: "B1-03-TravelIssues", title: "Travel Issues", canDo: "Handle travel issues", activities: [.check], tips: [])
        let b1Eighth = Lesson(
            id: "B1-08-FollowingUp",
            title: "Following Up",
            canDo: "Ask for follow-up",
            activities: [.check],
            tips: []
        )

        XCTAssertEqual(a1.level, .foundationA1)
        XCTAssertEqual(a1.pathNumber, 5)
        XCTAssertEqual(a1.pathCode, "A1-05")
        XCTAssertEqual(a1Second.level, .foundationA1)
        XCTAssertEqual(a1Second.pathNumber, 2)
        XCTAssertEqual(a1Second.pathCode, "A1-02")
        XCTAssertEqual(a1Eighth.level, .foundationA1)
        XCTAssertEqual(a1Eighth.pathNumber, 8)
        XCTAssertEqual(a1Eighth.pathCode, "A1-08")
        XCTAssertEqual(a2.level, .bridgeA2)
        XCTAssertEqual(a2.pathNumber, 1)
        XCTAssertEqual(a2.pathCode, "A2-01")
        XCTAssertEqual(a2Second.level, .bridgeA2)
        XCTAssertEqual(a2Second.pathNumber, 2)
        XCTAssertEqual(a2Second.pathCode, "A2-02")
        XCTAssertEqual(a2Fourth.level, .bridgeA2)
        XCTAssertEqual(a2Fourth.pathNumber, 4)
        XCTAssertEqual(a2Fourth.pathCode, "A2-04")
        XCTAssertEqual(a2Sixth.level, .bridgeA2)
        XCTAssertEqual(a2Sixth.pathNumber, 6)
        XCTAssertEqual(a2Sixth.pathCode, "A2-06")
        XCTAssertEqual(b1.level, .intermediateB1)
        XCTAssertEqual(b1.pathNumber, 3)
        XCTAssertEqual(b1.pathCode, "B1-03")
        XCTAssertEqual(b1Eighth.level, .intermediateB1)
        XCTAssertEqual(b1Eighth.pathNumber, 8)
        XCTAssertEqual(b1Eighth.pathCode, "B1-08")

        XCTAssertEqual(
            Lesson.orderedPath([b1Eighth, b1, a2Sixth, a2Fourth, a2Second, a2, a1Eighth, a1, a1Second]).map(\.id),
            [
                "A1-02-ClassroomPhrases",
                "A1-05-Prices",
                "A1-08-AskingDirections",
                "A2-01-Appointments",
                "A2-02-ReturnsExchanges",
                "A2-04-ClinicVisit",
                "A2-06-Invitations",
                "B1-03-TravelIssues",
                "B1-08-FollowingUp"
            ]
        )
    }

    func testLessonPathUnlocksOnlyTheNextIncompleteLesson() {
        let lessons = [
            Lesson(id: "A1-01-Greetings", title: "Greetings", canDo: "Greet people", activities: [.check], tips: []),
            Lesson(
                id: "A1-04-WhereYouLive",
                title: "Where You Live",
                canDo: "Say where you live",
                activities: [.check],
                tips: []
            ),
            Lesson(id: "A2-01-Appointments", title: "Appointments", canDo: "Make appointments", activities: [.check], tips: []),
            Lesson(id: "B1-01-InvitationsPlans", title: "Plans", canDo: "Discuss plans", activities: [.check], tips: [])
        ]
        var progress: [String: LessonProgress] = [:]

        XCTAssertEqual(Lesson.pathState(for: lessons[0], in: lessons) { progress[$0] ?? LessonProgress() }, .next)
        XCTAssertEqual(Lesson.pathState(for: lessons[1], in: lessons) { progress[$0] ?? LessonProgress() }, .locked)
        XCTAssertEqual(Lesson.pathState(for: lessons[2], in: lessons) { progress[$0] ?? LessonProgress() }, .locked)
        XCTAssertEqual(Lesson.pathState(for: lessons[3], in: lessons) { progress[$0] ?? LessonProgress() }, .locked)

        progress["A1-01-Greetings"] = LessonProgress(lastStep: 0, stars: 2, completedAt: Date())

        XCTAssertEqual(Lesson.pathState(for: lessons[0], in: lessons) { progress[$0] ?? LessonProgress() }, .completed)
        XCTAssertEqual(Lesson.pathState(for: lessons[1], in: lessons) { progress[$0] ?? LessonProgress() }, .next)
        XCTAssertEqual(Lesson.pathState(for: lessons[2], in: lessons) { progress[$0] ?? LessonProgress() }, .locked)
        XCTAssertEqual(Lesson.pathState(for: lessons[3], in: lessons) { progress[$0] ?? LessonProgress() }, .locked)
        XCTAssertEqual(Lesson.nextLesson(in: lessons) { progress[$0] ?? LessonProgress() }?.id, "A1-04-WhereYouLive")

        progress["A1-04-WhereYouLive"] = LessonProgress(lastStep: 0, stars: 3, completedAt: Date())

        XCTAssertEqual(Lesson.pathState(for: lessons[1], in: lessons) { progress[$0] ?? LessonProgress() }, .completed)
        XCTAssertEqual(Lesson.pathState(for: lessons[2], in: lessons) { progress[$0] ?? LessonProgress() }, .next)
        XCTAssertEqual(Lesson.pathState(for: lessons[3], in: lessons) { progress[$0] ?? LessonProgress() }, .locked)
        XCTAssertEqual(Lesson.nextLesson(in: lessons) { progress[$0] ?? LessonProgress() }?.id, "A2-01-Appointments")
    }

    func testManifestIDsPreserveKnownLevelOrderAndAppendCustomLevels() {
        let manifest = [
            "B1": ["B1-01-InvitationsPlans"],
            "A1": ["A1-01-Greetings"],
            "C1": ["C1-01-Debate"],
            "A2": ["A2-01-Appointments"],
            "B2": ["B2-01-News"]
        ]

        XCTAssertEqual(
            LessonStore.manifestIDs(from: manifest),
            [
                "A1-01-Greetings",
                "A2-01-Appointments",
                "B1-01-InvitationsPlans",
                "B2-01-News",
                "C1-01-Debate"
            ]
        )
    }

    func testLessonStoreUsesManifestAsAuthoritativeOrder() {
        let lessonsByStem = [
            "A1-01-Greetings": Lesson(id: "A1-01-Greetings", title: "Greetings", canDo: "Greet people", activities: [.check], tips: []),
            "A1-02-ClassroomPhrases": Lesson(
                id: "A1-02-ClassroomPhrases",
                title: "Classroom Phrases",
                canDo: "Ask for repetition",
                activities: [.check],
                tips: []
            ),
            "A2-01-Appointments": Lesson(id: "A2-01-Appointments", title: "Appointments", canDo: "Make appointments", activities: [.check], tips: [])
        ]
        let manifestIDs = ["A2-01-Appointments", "A1-01-Greetings"]

        XCTAssertEqual(
            LessonStore.orderedLessons(lessonsByStem: lessonsByStem, manifestIDs: manifestIDs).map(\.id),
            ["A2-01-Appointments", "A1-01-Greetings"]
        )
    }

    func testLessonStoreFallsBackToPathOrderWhenManifestIsMissing() {
        let lessonsByStem = [
            "B1-01-InvitationsPlans": Lesson(id: "B1-01-InvitationsPlans", title: "Plans", canDo: "Discuss plans", activities: [.check], tips: []),
            "A2-01-Appointments": Lesson(id: "A2-01-Appointments", title: "Appointments", canDo: "Make appointments", activities: [.check], tips: []),
            "A1-01-Greetings": Lesson(id: "A1-01-Greetings", title: "Greetings", canDo: "Greet people", activities: [.check], tips: [])
        ]

        XCTAssertEqual(
            LessonStore.orderedLessons(lessonsByStem: lessonsByStem, manifestIDs: []).map(\.id),
            ["A1-01-Greetings", "A2-01-Appointments", "B1-01-InvitationsPlans"]
        )
    }
}
