//
//  JapaneseBuddyProjUITests.swift
//  JapaneseBuddyProjUITests
//
//  Created by Yordam Kocatepe on 19.08.2025.
//

import XCTest

final class JapaneseBuddyProjUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testNavigateLessons() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UI-TESTING")
        app.launch()
        app.buttons["Lessons"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
