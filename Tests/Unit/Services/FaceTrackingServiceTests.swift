<<<<<<< HEAD
//
//  FaceTrackingServiceTests.swift
//  Aria's Magic SharePlay App - Tests
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

    func testInitialization_withDelegate() {
        // GIVEN: A delegate
        let delegate = MockFaceTrackingDelegate()

        // WHEN: Creating service with delegate
        let service = FaceTrackingService(delegate: delegate)

        // THEN: Delegate is set
        XCTAssertNotNil(service.delegate)
    }

    func testInitialization_withoutDelegate() {
        // GIVEN: No delegate
        // WHEN: Creating service without delegate
        let service = FaceTrackingService()

        // THEN: Service is created successfully
        XCTAssertNotNil(service)
        XCTAssertNil(service.delegate)
    }

    // MARK: - Smile Detection Tests

    func testDetectSmile_withStrongSmile() {
        // GIVEN: Face with strong smile
        let blendShapes = MockARFaceAnchor.smiling()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // Wait for async delegate call
        let expectation = expectation(description: "Smile detected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Smile is detected
        XCTAssertEqual(mockDelegate.expressionCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .smile)
    }

    func testDetectSmile_withSubtleSmile_belowThreshold() {
        // GIVEN: Face with subtle smile (below threshold)
        let blendShapes = MockARFaceAnchor.subtleSmile()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // Wait briefly
        let expectation = expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Smile is NOT detected (below threshold)
        XCTAssertEqual(mockDelegate.expressionCount, 0)
    }

    func testDetectSmile_averagesLeftAndRightSmile() {
        // GIVEN: Face with asymmetric smile
        var blendShapes = MockARFaceAnchor.neutral()
        blendShapes[.mouthSmileLeft] = 0.6
        blendShapes[.mouthSmileRight] = 0.8  // Average = 0.7, above threshold of 0.5

        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Smile detected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Smile is detected based on average
        XCTAssertEqual(mockDelegate.expressionCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .smile)
    }

    // MARK: - Eyebrows Raised Detection Tests

    func testDetectEyebrowsRaised_withRaisedEyebrows() {
        // GIVEN: Face with raised eyebrows
        let blendShapes = MockARFaceAnchor.eyebrowsRaised()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Eyebrows detected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Eyebrows raised is detected
        XCTAssertEqual(mockDelegate.expressionCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .eyebrowsRaised)
    }

    func testDetectEyebrowsRaised_belowThreshold() {
        // GIVEN: Face with slightly raised eyebrows (below threshold)
        var blendShapes = MockARFaceAnchor.neutral()
        blendShapes[.browInnerUp] = 0.3  // Below threshold of 0.5

        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Eyebrows raised is NOT detected
        XCTAssertEqual(mockDelegate.expressionCount, 0)
    }

    // MARK: - Mouth Open Detection Tests

    func testDetectMouthOpen_withOpenMouth() {
        // GIVEN: Face with open mouth
        let blendShapes = MockARFaceAnchor.mouthOpen()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Mouth open detected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Mouth open is detected
        XCTAssertEqual(mockDelegate.expressionCount, 1)
        XCTAssertEqual(mockDelegate.lastExpression, .mouthOpen)
    }

    func testDetectMouthOpen_belowThreshold() {
        // GIVEN: Face with slightly open mouth (below threshold)
        var blendShapes = MockARFaceAnchor.neutral()
        blendShapes[.jawOpen] = 0.2  // Below threshold of 0.4

        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Mouth open is NOT detected
        XCTAssertEqual(mockDelegate.expressionCount, 0)
    }

    // MARK: - Debouncing Tests

    func testDebouncing_preventsDuplicateTriggers() {
        // GIVEN: Face with smile
        let blendShapes = MockARFaceAnchor.smiling()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing same expression multiple times quickly
        service.processFaceAnchor(faceAnchor)
        service.processFaceAnchor(faceAnchor)
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Wait for processing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Only one expression is detected (debounced)
        XCTAssertEqual(mockDelegate.expressionCount, 1)
    }

    func testDebouncing_allowsAfterInterval() {
        // GIVEN: Face with smile
        let blendShapes = MockARFaceAnchor.smiling()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing expression, waiting, then processing again
        service.processFaceAnchor(faceAnchor)

        let expectation1 = expectation(description: "First detection")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        XCTAssertEqual(mockDelegate.expressionCount, 1)

        // Wait for debounce interval (1.0 second)
        let expectation2 = expectation(description: "Wait for debounce")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            // Process again after debounce interval
            self.service.processFaceAnchor(faceAnchor)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation2.fulfill()
            }
        }
        wait(for: [expectation2], timeout: 3.0)

        // THEN: Second expression is detected after debounce interval
        XCTAssertEqual(mockDelegate.expressionCount, 2)
    }

    func testDebouncing_independentForDifferentExpressions() {
        // GIVEN: Different expressions
        let smileBlendShapes = MockARFaceAnchor.smiling()
        let smileAnchor = createMockFaceAnchor(blendShapes: smileBlendShapes)

        let browBlendShapes = MockARFaceAnchor.eyebrowsRaised()
        let browAnchor = createMockFaceAnchor(blendShapes: browBlendShapes)

        // WHEN: Processing different expressions quickly
        service.processFaceAnchor(smileAnchor)
        service.processFaceAnchor(browAnchor)

        let expectation = expectation(description: "Wait for processing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: Both expressions are detected (independent debouncing)
        XCTAssertEqual(mockDelegate.expressionCount, 2)
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.smile))
        XCTAssertTrue(mockDelegate.detectedExpressions.contains(.eyebrowsRaised))
    }

    // MARK: - Multiple Expression Tests

    func testProcessFaceAnchor_withNeutralExpression() {
        // GIVEN: Neutral face
        let blendShapes = MockARFaceAnchor.neutral()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing neutral expression
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: No expressions are detected
        XCTAssertEqual(mockDelegate.expressionCount, 0)
    }

    func testProcessFaceAnchor_sequentialDifferentExpressions() {
        // GIVEN: Different expressions in sequence
        mockDelegate.reset()

        // WHEN: Processing smile
        let smileBlendShapes = MockARFaceAnchor.smiling()
        service.processFaceAnchor(createMockFaceAnchor(blendShapes: smileBlendShapes))

        let expectation1 = expectation(description: "Smile detected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)

        XCTAssertEqual(mockDelegate.lastExpression, .smile)

        // Wait for debounce, then process eyebrows
        let expectation2 = expectation(description: "Eyebrows detected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            let browBlendShapes = MockARFaceAnchor.eyebrowsRaised()
            self.service.processFaceAnchor(self.createMockFaceAnchor(blendShapes: browBlendShapes))

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation2.fulfill()
            }
        }
        wait(for: [expectation2], timeout: 3.0)

        // THEN: Both expressions are detected
        XCTAssertEqual(mockDelegate.expressionCount, 2)
        XCTAssertEqual(mockDelegate.lastExpression, .eyebrowsRaised)
    }

    // MARK: - Delegate Tests

    func testDelegate_canBeSet() {
        // GIVEN: A new service
        let service = FaceTrackingService()
        let delegate = MockFaceTrackingDelegate()

        // WHEN: Setting delegate
        service.delegate = delegate

        // THEN: Delegate is set
        XCTAssertNotNil(service.delegate)
    }

    func testDelegate_canBeNil() {
        // GIVEN: Service with delegate
        let service = FaceTrackingService(delegate: mockDelegate)

        // WHEN: Setting delegate to nil
        service.delegate = nil

        // THEN: Delegate is nil and service doesn't crash
        XCTAssertNil(service.delegate)

        let blendShapes = MockARFaceAnchor.smiling()
        service.processFaceAnchor(createMockFaceAnchor(blendShapes: blendShapes))
        // No crash expected
    }

    func testDelegate_receivesCallbackOnMainThread() {
        // GIVEN: Face with smile
        let blendShapes = MockARFaceAnchor.smiling()
        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        var isMainThread = false
        let expectation = expectation(description: "Callback on main thread")

        // Create a custom delegate to check thread
        class ThreadCheckDelegate: FaceTrackingDelegate {
            var onDetect: ((Bool) -> Void)?

            func didDetectExpression(_ expression: FaceExpression) {
                let isMain = Thread.isMainThread
                onDetect?(isMain)
            }
        }

        let threadDelegate = ThreadCheckDelegate()
        threadDelegate.onDetect = { isMain in
            isMainThread = isMain
            expectation.fulfill()
        }

        service.delegate = threadDelegate

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        wait(for: [expectation], timeout: 1.0)

        // THEN: Callback is on main thread
        XCTAssertTrue(isMainThread)
    }

    // MARK: - Edge Cases

    func testProcessFaceAnchor_withMissingBlendShapes() {
        // GIVEN: Face anchor with incomplete blend shapes
        var blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:]
        blendShapes[.mouthSmileLeft] = 0.8
        // Missing mouthSmileRight

        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        // THEN: Service handles gracefully without crash
        // (No assertion needed, test passes if no crash)
    }

    func testProcessFaceAnchor_withExtremeValues() {
        // GIVEN: Face with extreme blend shape values
        var blendShapes = MockARFaceAnchor.neutral()
        blendShapes[.mouthSmileLeft] = 1.0
        blendShapes[.mouthSmileRight] = 1.0
        blendShapes[.jawOpen] = 1.0
        blendShapes[.browInnerUp] = 1.0

        let faceAnchor = createMockFaceAnchor(blendShapes: blendShapes)

        // WHEN: Processing face anchor
        service.processFaceAnchor(faceAnchor)

        let expectation = expectation(description: "Processing complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // THEN: All applicable expressions are detected
        XCTAssertGreaterThan(mockDelegate.expressionCount, 0)
    }

    // MARK: - Helper Methods

    private func createMockFaceAnchor(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> ARFaceAnchor {
        // Create a mock ARFaceAnchor
        // Note: ARFaceAnchor is a class from ARKit that we can't easily instantiate in tests
        // For real implementation, you would need to use a protocol or wrapper
        // For now, we'll create a test-friendly version

        // This is a simplified mock - in production, you'd use dependency injection
        return MockARFaceAnchorWrapper(blendShapes: blendShapes)
    }
}

// MARK: - Mock ARFaceAnchor Wrapper

class MockARFaceAnchorWrapper: ARFaceAnchor {
    private let _blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]

    init(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        self._blendShapes = blendShapes
        let transform = simd_float4x4(1.0)
        super.init(name: "MockFaceAnchor", transform: transform)
    }

    required init(anchor: ARAnchor) {
        self._blendShapes = [:]
        super.init(anchor: anchor)
    }

    required init?(coder: NSCoder) {
        self._blendShapes = [:]
        super.init(coder: coder)
    }

    override var blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber] {
        return _blendShapes
    }
}
||||||| e86307c
=======
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
>>>>>>> origin/claude/qa-engineer-setup-018opoWboXZWozhVCKPoChNQ
