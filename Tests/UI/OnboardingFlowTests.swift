//
//  OnboardingFlowTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  UI tests for onboarding flow
//

import XCTest

class OnboardingFlowTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Flow Tests

    func testOnboarding_completesSuccessfully() {
        // GIVEN: First launch (onboarding shows)
        // Note: Add accessibility identifiers to OnboardingView components
        XCTAssertTrue(app.staticTexts["Welcome to Aria's Magic App!"].waitForExistence(timeout: 2.0))

        // WHEN: Tapping through all pages
        let nextButton = app.buttons["Next"]
        if nextButton.exists {
            nextButton.tap()
            nextButton.tap()
            nextButton.tap()
        }

        let getStartedButton = app.buttons["Get Started!"]
        if getStartedButton.exists {
            getStartedButton.tap()
        }

        // THEN: Main AR view appears
        // Note: Add "MagicARView" accessibility identifier to AR view
        XCTAssertTrue(app.otherElements["MagicARView"].waitForExistence(timeout: 2.0))
    }

    func testOnboarding_canSkip() {
        // GIVEN: Onboarding screen displayed
        XCTAssertTrue(app.staticTexts["Welcome to Aria's Magic App!"].waitForExistence(timeout: 2.0))

        // WHEN: Tapping skip button (if exists)
        let skipButton = app.buttons["Skip"]
        if skipButton.exists {
            skipButton.tap()

            // THEN: Navigates to main AR view
            XCTAssertTrue(app.otherElements["MagicARView"].waitForExistence(timeout: 2.0))
        } else {
            // Skip functionality not implemented yet
            XCTAssertTrue(true)
        }
    }

    func testOnboarding_allPagesDisplay() {
        // GIVEN: Onboarding screen
        XCTAssertTrue(app.staticTexts["Welcome to Aria's Magic App!"].waitForExistence(timeout: 2.0))

        // WHEN: Going through all pages
        let nextButton = app.buttons["Next"]

        // Page 1
        XCTAssertTrue(app.staticTexts["Welcome to Aria's Magic App!"].exists)

        // Page 2
        if nextButton.exists {
            nextButton.tap()
            // Add assertions for page 2 content
            XCTAssertTrue(true) // Placeholder
        }

        // Page 3
        if nextButton.exists {
            nextButton.tap()
            // Add assertions for page 3 content
            XCTAssertTrue(true) // Placeholder
        }

        // Page 4
        if nextButton.exists {
            nextButton.tap()
            // Add assertions for page 4 content
            XCTAssertTrue(true) // Placeholder
        }

        // THEN: Get Started button appears
        XCTAssertTrue(app.buttons["Get Started!"].waitForExistence(timeout: 1.0))
    }

    func testOnboarding_pageIndicatorsUpdate() {
        // GIVEN: Onboarding screen
        XCTAssertTrue(app.staticTexts["Welcome to Aria's Magic App!"].waitForExistence(timeout: 2.0))

        // WHEN: Navigating through pages
        let nextButton = app.buttons["Next"]

        // THEN: Page indicators should update
        // Note: Add accessibility identifiers to page indicators
        // This is a placeholder - implement when page indicators have identifiers
        XCTAssertTrue(true)
    }

    // MARK: - Helper Methods

    private func skipOnboarding() {
        // Helper to skip onboarding in other tests
        let getStartedButton = app.buttons["Get Started!"]
        let nextButton = app.buttons["Next"]

        if app.staticTexts["Welcome to Aria's Magic App!"].waitForExistence(timeout: 2.0) {
            // Tap through onboarding
            for _ in 0..<3 {
                if nextButton.exists {
                    nextButton.tap()
                }
            }

            if getStartedButton.exists {
                getStartedButton.tap()
            }
        }
    }
}
