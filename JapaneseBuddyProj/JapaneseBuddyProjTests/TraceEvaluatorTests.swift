import Testing
@testable import JapaneseBuddyProj

struct TraceEvaluatorTests {
    @Test func scoreGate() async throws {
        func pass(_ score: Double, _ strokes: Int, _ expected: Int) -> Bool {
            score >= 0.6 && strokes >= expected && strokes <= expected + 1
        }
        #expect(pass(0.6, 3, 3))
        #expect(!pass(0.5, 3, 3))
        #expect(!pass(0.7, 5, 3))
    }
}
