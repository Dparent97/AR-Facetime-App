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
