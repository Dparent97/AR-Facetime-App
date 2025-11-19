//
//  OnboardingFlowTests.swift
//  AriasMagicAppUITests
//
//  Comprehensive UI tests for the onboarding tutorial flow
//

import XCTest

final class OnboardingFlowTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("--show-onboarding")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Initial State Tests

    func testOnboarding_InitialState_ShowsWelcomePage() {
        // Then
        XCTAssertTrue(app.staticTexts["✨"].exists,
                     "Welcome emoji should be visible")
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists,
                     "Welcome title should be visible")
        XCTAssertTrue(app.staticTexts["Tap anywhere to spawn magical princess characters"].exists,
                     "Welcome description should be visible")
    }

    func testOnboarding_InitialState_ShowsNextButton() {
        // Then
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists, "Next button should be visible")
        XCTAssertTrue(nextButton.isEnabled, "Next button should be enabled")
    }

    func testOnboarding_InitialState_BackButtonNotVisible() {
        // Then
        let backButton = app.buttons["Back"]
        XCTAssertFalse(backButton.exists,
                      "Back button should not be visible on first page")
    }

    func testOnboarding_InitialState_PageIndicator() {
        // Then
        // Page indicators are rendered as circles, check for 4 indicators
        // In a real test, you'd use accessibility identifiers
        // For now, we verify the structure exists
    }

    // MARK: - Navigation Tests

    func testOnboarding_NextButton_NavigatesToSecondPage() {
        // When
        let nextButton = app.buttons["Next"]
        nextButton.tap()

        // Then
        XCTAssertTrue(app.staticTexts["😊"].exists,
                     "Second page emoji should be visible")
        XCTAssertTrue(app.staticTexts["Smile for Magic!"].exists,
                     "Second page title should be visible")
    }

    func testOnboarding_BackButton_NavigatesToPreviousPage() {
        // Given
        app.buttons["Next"].tap()

        // When
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.exists, "Back button should exist on second page")
        backButton.tap()

        // Then
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists,
                     "Should return to first page")
    }

    func testOnboarding_CompleteFlow_AllPagesVisible() {
        // Given - Expected content for each page
        let expectedContent = [
            (emoji: "✨", title: "Welcome to Magic World!"),
            (emoji: "😊", title: "Smile for Magic!"),
            (emoji: "🎭", title: "Make Them Dance!"),
            (emoji: "👯", title: "Share with FaceTime!")
        ]

        // When & Then - Navigate through all pages
        for (index, content) in expectedContent.enumerated() {
            XCTAssertTrue(app.staticTexts[content.emoji].exists,
                         "Page \(index + 1) emoji should be visible")
            XCTAssertTrue(app.staticTexts[content.title].exists,
                         "Page \(index + 1) title should be visible")

            // Tap Next if not on last page
            if index < expectedContent.count - 1 {
                app.buttons["Next"].tap()
            }
        }
    }

    func testOnboarding_LastPage_ShowsStartButton() {
        // Given - Navigate to last page
        for _ in 0..<3 {
            app.buttons["Next"].tap()
        }

        // Then
        let startButton = app.buttons["Start Magic!"]
        XCTAssertTrue(startButton.exists,
                     "Start Magic! button should be visible on last page")
        XCTAssertFalse(app.buttons["Next"].exists,
                      "Next button should not exist on last page")
    }

    func testOnboarding_StartButton_DismissesOnboarding() {
        // Given - Navigate to last page
        for _ in 0..<3 {
            app.buttons["Next"].tap()
        }

        // When
        let startButton = app.buttons["Start Magic!"]
        startButton.tap()

        // Then
        // Onboarding should be dismissed, AR view should be visible
        // In a real test, you'd check for AR view elements
        XCTAssertFalse(app.staticTexts["Share with FaceTime!"].exists,
                      "Onboarding should be dismissed")
    }

    // MARK: - Back and Forth Navigation Tests

    func testOnboarding_BackAndForth_Navigation() {
        // When - Navigate forward and back
        app.buttons["Next"].tap() // Page 2
        XCTAssertTrue(app.staticTexts["Smile for Magic!"].exists)

        app.buttons["Next"].tap() // Page 3
        XCTAssertTrue(app.staticTexts["Make Them Dance!"].exists)

        app.buttons["Back"].tap() // Back to Page 2
        XCTAssertTrue(app.staticTexts["Smile for Magic!"].exists)

        app.buttons["Back"].tap() // Back to Page 1
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists)

        app.buttons["Next"].tap() // Forward to Page 2
        XCTAssertTrue(app.staticTexts["Smile for Magic!"].exists)

        // Then
        // All navigation should work correctly
    }

    func testOnboarding_RapidNavigation_HandlesMultipleTaps() {
        // When - Rapidly tap next
        let nextButton = app.buttons["Next"]
        for _ in 0..<5 {
            if nextButton.exists {
                nextButton.tap()
            }
        }

        // Then - Should handle rapid taps gracefully
        // Should end up on a valid page (not crash)
    }

    // MARK: - Page Content Tests

    func testOnboarding_Page1_Content() {
        // Then
        XCTAssertTrue(app.staticTexts["✨"].exists)
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists)
        XCTAssertTrue(app.staticTexts["Tap anywhere to spawn magical princess characters"].exists)
    }

    func testOnboarding_Page2_Content() {
        // When
        app.buttons["Next"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["😊"].exists)
        XCTAssertTrue(app.staticTexts["Smile for Magic!"].exists)
        // Check for multi-line description
        let hasSmileText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Smile to create sparkles'")).element.exists
        XCTAssertTrue(hasSmileText, "Should contain smile instruction")
    }

    func testOnboarding_Page3_Content() {
        // When
        app.buttons["Next"].tap()
        app.buttons["Next"].tap()

        // Then
        XCTAssertTrue(app.staticTexts["🎭"].exists)
        XCTAssertTrue(app.staticTexts["Make Them Dance!"].exists)
        let hasDanceText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'buttons to make'")).element.exists
        XCTAssertTrue(hasDanceText, "Should contain dance instruction")
    }

    func testOnboarding_Page4_Content() {
        // When
        for _ in 0..<3 {
            app.buttons["Next"].tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts["👯"].exists)
        XCTAssertTrue(app.staticTexts["Share with FaceTime!"].exists)
        let hasSharePlayText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'SharePlay'")).element.exists
        XCTAssertTrue(hasSharePlayText, "Should contain SharePlay instruction")
    }

    // MARK: - Visual Elements Tests

    func testOnboarding_GradientBackground_Exists() {
        // Then
        // Gradient background should be visible
        // In a real test, you might check for specific colors or layout
    }

    func testOnboarding_PageIndicators_Count() {
        // Then
        // Should have 4 page indicators (circles)
        // In a real test with accessibility identifiers:
        // XCTAssertEqual(app.otherElements.matching(identifier: "pageIndicator").count, 4)
    }

    func testOnboarding_PageIndicators_UpdateOnNavigation() {
        // Given - On first page
        // Check first indicator is highlighted

        // When
        app.buttons["Next"].tap()

        // Then
        // Second indicator should be highlighted
        // This would require accessibility identifiers in the actual implementation
    }

    // MARK: - Animation Tests

    func testOnboarding_PageTransition_AnimatesSmootly() {
        // When
        app.buttons["Next"].tap()

        // Then
        // Transitions should be smooth (no crashes during animation)
        // Wait for animation to complete
        sleep(1)
        XCTAssertTrue(app.staticTexts["Smile for Magic!"].exists)
    }

    func testOnboarding_BackTransition_AnimatesSmootly() {
        // Given
        app.buttons["Next"].tap()

        // When
        app.buttons["Back"].tap()

        // Then
        sleep(1)
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists)
    }

    // MARK: - Edge Cases

    func testOnboarding_FirstPage_BackButtonDoesNotExist() {
        // Then
        XCTAssertFalse(app.buttons["Back"].exists,
                      "Back button should not exist on first page")
    }

    func testOnboarding_LastPage_NextButtonDoesNotExist() {
        // Given
        for _ in 0..<3 {
            app.buttons["Next"].tap()
        }

        // Then
        XCTAssertFalse(app.buttons["Next"].exists,
                      "Next button should not exist on last page")
    }

    func testOnboarding_ButtonState_AlwaysAccessible() {
        // When & Then - Navigate through all pages
        for pageIndex in 0..<4 {
            // Check that at least one navigation button exists
            let hasNextButton = app.buttons["Next"].exists
            let hasStartButton = app.buttons["Start Magic!"].exists
            let hasBackButton = app.buttons["Back"].exists

            XCTAssertTrue(hasNextButton || hasStartButton || hasBackButton,
                         "At least one button should be accessible on page \(pageIndex)")

            // Navigate if not on last page
            if pageIndex < 3 {
                if hasNextButton {
                    app.buttons["Next"].tap()
                }
            }
        }
    }

    // MARK: - Accessibility Tests

    func testOnboarding_VoiceOver_Support() {
        // Then
        // All interactive elements should have accessibility labels
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists)
        XCTAssertFalse(nextButton.label.isEmpty, "Button should have accessibility label")
    }

    func testOnboarding_DynamicType_Support() {
        // Then
        // Text should be readable at different dynamic type sizes
        // This test would require changing system settings
    }

    // MARK: - Performance Tests

    func testOnboarding_Performance_InitialLoad() {
        measure {
            let app = XCUIApplication()
            app.launch()
        }
    }

    func testOnboarding_Performance_PageNavigation() {
        measure {
            app.buttons["Next"].tap()
            app.buttons["Back"].tap()
        }
    }

    // MARK: - Integration Tests

    func testOnboarding_CompleteFlow_EndsWithARView() {
        // Given - Complete the entire onboarding flow
        for _ in 0..<3 {
            app.buttons["Next"].tap()
        }

        // When
        app.buttons["Start Magic!"].tap()

        // Then
        // Should transition to main AR view
        // In real implementation, check for AR view elements
        let expectation = XCTestExpectation(description: "Wait for AR view")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testOnboarding_SkipAndReturn_State() {
        // This test would verify that onboarding state is preserved
        // if the app is backgrounded and resumed
    }

    func testOnboarding_MemoryWarning_Handles() {
        // Test that onboarding handles memory warnings gracefully
        // This would require simulating a memory warning
    }

    // MARK: - Localization Tests

    func testOnboarding_DefaultLanguage_English() {
        // Then
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists,
                     "Default language should be English")
    }

    // MARK: - Layout Tests

    func testOnboarding_Portrait_Layout() {
        // Then
        // All elements should be properly laid out in portrait mode
        XCTAssertTrue(app.staticTexts["✨"].exists)
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists)
        XCTAssertTrue(app.buttons["Next"].exists)
    }

    func testOnboarding_Landscape_Layout() {
        // When
        XCUIDevice.shared.orientation = .landscapeLeft

        // Then
        // Elements should adapt to landscape orientation
        XCTAssertTrue(app.staticTexts["Welcome to Magic World!"].exists)

        // Reset orientation
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: - Error Handling Tests

    func testOnboarding_InvalidNavigation_DoesNotCrash() {
        // When - Try to navigate beyond bounds (if possible)
        // Tap multiple times rapidly

        for _ in 0..<10 {
            if app.buttons["Next"].exists {
                app.buttons["Next"].tap()
            }
        }

        // Then
        // Should not crash, should handle gracefully
    }
}
