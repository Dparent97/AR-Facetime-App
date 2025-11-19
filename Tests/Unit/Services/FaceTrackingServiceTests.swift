//
//  FaceTrackingServiceTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Unit tests for FaceTrackingService
//

import XCTest
import ARKit
@testable import AriasMagicApp

class FaceTrackingServiceTests: XCTestCase {

    var service: FaceTrackingService!
    var mockDelegate: MockFaceTrackingDelegate!

    override func setUp() {
        super.setUp()
        mockDelegate = MockFaceTrackingDelegate()
        service = FaceTrackingService(delegate: mockDelegate)
    }

    override func tearDown() {
        service = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testServiceInitialization_withDelegate() {
        // GIVEN: A delegate
        let delegate = MockFaceTrackingDelegate()

        // WHEN: Creating service with delegate
        let service = FaceTrackingService(delegate: delegate)

        // THEN: Delegate is set
        XCTAssertNotNil(service.delegate)
    }

    func testServiceInitialization_withoutDelegate() {
        // GIVEN: No delegate
        // WHEN: Creating service without delegate
        let service = FaceTrackingService()

        // THEN: Service is created
        XCTAssertNotNil(service)
        XCTAssertNil(service.delegate)
    }

    // MARK: - Smile Detection Tests

    func testDetectSmile_withStrongSmile() {
        // GIVEN: Face with strong smile
        let faceAnchor = MockARFaceAnchor.smiling()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Smile detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .smile)
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.smile))
    }

    func testDetectSmile_withSubtleSmile() {
        // GIVEN: Face with subtle smile (below threshold)
        let faceAnchor = MockARFaceAnchor.subtleSmile()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Smile not detected (below threshold)
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
        XCTAssertNil(mockDelegate.lastExpression)
    }

    func testDetectSmile_withNeutralFace() {
        // GIVEN: Neutral face
        let faceAnchor = MockARFaceAnchor.neutral()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: No smile detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
        XCTAssertNil(mockDelegate.lastExpression)
    }

    // MARK: - Eyebrows Raised Detection Tests

    func testDetectEyebrowsRaised_withRaisedBrows() {
        // GIVEN: Face with raised eyebrows
        let faceAnchor = MockARFaceAnchor.eyebrowsRaised()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Eyebrows raised detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .eyebrowsRaised)
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.eyebrowsRaised))
    }

    func testDetectEyebrowsRaised_withNeutralBrows() {
        // GIVEN: Neutral face
        let faceAnchor = MockARFaceAnchor.neutral()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: No eyebrow raise detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
    }

    // MARK: - Mouth Open Detection Tests

    func testDetectMouthOpen_withOpenMouth() {
        // GIVEN: Face with open mouth
        let faceAnchor = MockARFaceAnchor.mouthOpen()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Mouth open detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .mouthOpen)
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.mouthOpen))
    }

    func testDetectMouthOpen_withClosedMouth() {
        // GIVEN: Neutral face
        let faceAnchor = MockARFaceAnchor.neutral()

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: No mouth open detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
    }

    // MARK: - Debouncing Tests

    func testDebouncing_preventsRapidSmileTriggers() {
        // GIVEN: Multiple smile frames in quick succession
        let faceAnchor = MockARFaceAnchor.smiling()

        // WHEN: Processing multiple times quickly
        service.processFaceAnchor(faceAnchor)
        service.processFaceAnchor(faceAnchor)
        service.processFaceAnchor(faceAnchor)

        // THEN: Only triggered once due to debouncing
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
    }

    func testDebouncing_allowsTriggerAfterInterval() {
        // GIVEN: Smile frames with time gap
        let faceAnchor = MockARFaceAnchor.smiling()
        let expectation = expectation(description: "Debounce interval passed")

        // WHEN: Processing first time
        service.processFaceAnchor(faceAnchor)
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)

        // AND: Waiting for debounce interval (1+ seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // AND: Processing again
            self.service.processFaceAnchor(faceAnchor)

            // THEN: Triggered again
            XCTAssertEqual(self.mockDelegate.expressionCallCount, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testDebouncing_eachExpressionIndependent() {
        // GIVEN: Different expressions
        let smileFace = MockARFaceAnchor.smiling()
        let browsFace = MockARFaceAnchor.eyebrowsRaised()
        let mouthFace = MockARFaceAnchor.mouthOpen()

        // WHEN: Processing different expressions quickly
        service.processFaceAnchor(smileFace)
        service.processFaceAnchor(browsFace)
        service.processFaceAnchor(mouthFace)

        // THEN: Each expression triggers independently
        XCTAssertEqual(mockDelegate.expressionCallCount, 3)
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.smile))
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.eyebrowsRaised))
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.mouthOpen))
    }

    func testDebouncing_sameExpressionBlocked() {
        // GIVEN: Same expression multiple times
        let faceAnchor = MockARFaceAnchor.eyebrowsRaised()

        // WHEN: Processing same expression 5 times quickly
        for _ in 0..<5 {
            service.processFaceAnchor(faceAnchor)
        }

        // THEN: Only first one triggers
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
    }

    // MARK: - Delegate Tests

    func testDelegate_receivesCallbackOnMainThread() {
        // GIVEN: Face with smile
        let faceAnchor = MockARFaceAnchor.smiling()
        let expectation = expectation(description: "Callback on main thread")

        // Create custom delegate to check thread
        class ThreadCheckDelegate: FaceTrackingDelegate {
            var isMainThread = false
            let expectation: XCTestExpectation

            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            func didDetectExpression(_ expression: FaceExpression) {
                isMainThread = Thread.isMainThread
                expectation.fulfill()
            }
        }

        let threadDelegate = ThreadCheckDelegate(expectation: expectation)
        let threadService = FaceTrackingService(delegate: threadDelegate)

        // WHEN: Processing face anchor
        threadService.processFaceAnchor(faceAnchor)

        // THEN: Callback happens on main thread
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(threadDelegate.isMainThread)
    }

    func testDelegate_weakReference() {
        // GIVEN: A service and delegate
        var delegate: MockFaceTrackingDelegate? = MockFaceTrackingDelegate()
        weak var weakDelegate = delegate

        let service = FaceTrackingService(delegate: delegate)

        // WHEN: Releasing delegate
        delegate = nil

        // THEN: Delegate is deallocated (weak reference)
        XCTAssertNil(weakDelegate)
        XCTAssertNil(service.delegate)
    }

    // MARK: - Multiple Expressions Tests

    func testMultipleExpressions_detectedSequentially() {
        // GIVEN: Different expression anchors
        let smileFace = MockARFaceAnchor.smiling()
        let browsFace = MockARFaceAnchor.eyebrowsRaised()

        // WHEN: Processing in sequence
        service.processFaceAnchor(smileFace)
        service.processFaceAnchor(browsFace)

        // THEN: Both detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 2)
        XCTAssertEqual(mockDelegate.detectedExpressions[0], .smile)
        XCTAssertEqual(mockDelegate.detectedExpressions[1], .eyebrowsRaised)
    }

    // MARK: - Edge Cases

    func testProcessFaceAnchor_withMissingBlendShapes() {
        // GIVEN: Face anchor with empty blend shapes
        let faceAnchor = MockARFaceAnchor(blendShapes: [:])

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: No expressions detected, no crash
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
    }

    func testProcessFaceAnchor_withPartialBlendShapes() {
        // GIVEN: Face anchor with only left smile
        let faceAnchor = MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 0.9
        ])

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: No expression detected (needs both left and right)
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
    }

    func testProcessFaceAnchor_withExtremeValues() {
        // GIVEN: Face anchor with extreme blend shape values
        let faceAnchor = MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 1.0,
            .mouthSmileRight: 1.0
        ])

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Expression detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .smile)
    }

    func testProcessFaceAnchor_withZeroValues() {
        // GIVEN: Face anchor with zero blend shapes
        let faceAnchor = MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 0.0,
            .mouthSmileRight: 0.0,
            .browInnerUp: 0.0,
            .jawOpen: 0.0
        ])

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: No expressions detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
    }

    // MARK: - Threshold Tests

    func testThresholds_smileAtBoundary() {
        // GIVEN: Face with smile exactly at threshold (0.5)
        let faceAnchor = MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 0.5,
            .mouthSmileRight: 0.5
        ])

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Expression not detected (needs to be > threshold)
        XCTAssertEqual(mockDelegate.expressionCallCount, 0)
    }

    func testThresholds_smileAboveThreshold() {
        // GIVEN: Face with smile just above threshold
        let faceAnchor = MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 0.51,
            .mouthSmileRight: 0.51
        ])

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Expression detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .smile)
    }

    // MARK: - Performance Tests

    func testPerformance_processingMultipleFrames() {
        // GIVEN: A face anchor
        let faceAnchor = MockARFaceAnchor.neutral()

        // WHEN/THEN: Measuring processing performance
        measure {
            for _ in 0..<100 {
                service.processFaceAnchor(faceAnchor)
            }
        }
    }

    func testPerformance_smileDetection() {
        // GIVEN: A smiling face
        let faceAnchor = MockARFaceAnchor.smiling()
        mockDelegate.reset()

        // Wait for debounce to reset
        Thread.sleep(forTimeInterval: 1.5)

        // WHEN/THEN: Measuring smile detection performance
        measure {
            let delegate = MockFaceTrackingDelegate()
            let service = FaceTrackingService(delegate: delegate)
            service.processFaceAnchor(faceAnchor)
        }
    }

    // MARK: - Integration Tests

    func testRealWorldScenario_smilingSequence() {
        // GIVEN: A sequence of facial expressions
        let neutral = MockARFaceAnchor.neutral()
        let subtle = MockARFaceAnchor.subtleSmile()
        let smile = MockARFaceAnchor.smiling()

        // WHEN: Processing realistic sequence
        service.processFaceAnchor(neutral)   // No trigger
        service.processFaceAnchor(subtle)    // No trigger (below threshold)
        service.processFaceAnchor(smile)     // Trigger!

        // THEN: Only strong smile triggers
        XCTAssertEqual(mockDelegate.expressionCallCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .smile)
    }

    func testRealWorldScenario_expressionTransition() {
        // GIVEN: Transition between expressions
        let smile = MockARFaceAnchor.smiling()
        let neutral = MockARFaceAnchor.neutral()
        let brows = MockARFaceAnchor.eyebrowsRaised()

        // WHEN: Processing transition
        service.processFaceAnchor(smile)    // Trigger smile
        service.processFaceAnchor(neutral)  // No trigger
        service.processFaceAnchor(brows)    // Trigger eyebrows

        // THEN: Two expressions detected
        XCTAssertEqual(mockDelegate.expressionCallCount, 2)
        XCTAssertEqual(mockDelegate.detectedExpressions[0], .smile)
        XCTAssertEqual(mockDelegate.detectedExpressions[1], .eyebrowsRaised)
    }
}
