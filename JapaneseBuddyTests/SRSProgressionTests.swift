import XCTest
@testable import JapaneseBuddyProj

final class SRSProgressionTests: XCTestCase {
    func testSRSProgression() {
        var c = Card(type: .kana, front: "あ", back: "a")
        XCTAssertEqual(c.interval, 0)
        SRS.apply(.good, to: &c, today: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(c.interval, 1)
        let firstDue = c.nextDue
        SRS.apply(.easy, to: &c, today: firstDue)
        XCTAssertGreaterThanOrEqual(c.interval, 3)
        XCTAssertTrue(c.nextDue > firstDue)
    }
}

