//
//  TestUtilities.swift
//  AriasMagicAppTests
//
//  Test utilities and mocks for ARKit and SharePlay testing
//

import XCTest
import ARKit
import GroupActivities
import Combine
@testable import AriasMagicApp

// MARK: - Mock Face Tracking Delegate

class MockFaceTrackingDelegate: FaceTrackingDelegate {
    var detectedExpressions: [FaceExpression] = []
    var expressionExpectation: XCTestExpectation?

    func didDetectExpression(_ expression: FaceExpression) {
        detectedExpressions.append(expression)
        expressionExpectation?.fulfill()
    }

    func reset() {
        detectedExpressions.removeAll()
    }
}

// MARK: - Mock ARFaceAnchor Builder

class MockARFaceAnchor {
    static func create(withBlendShapes blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> ARFaceAnchor {
        // Create a mock face anchor with custom blend shapes
        // Note: This is a simplified version for testing purposes
        // In real implementation, ARFaceAnchor would be properly mocked
        let anchor = ARFaceAnchor(name: "test")
        return anchor
    }

    static func createSmiling() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: NSNumber(value: 0.8),
            .mouthSmileRight: NSNumber(value: 0.8)
        ]
    }

    static func createEyebrowsRaised() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .browInnerUp: NSNumber(value: 0.7)
        ]
    }

    static func createMouthOpen() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .jawOpen: NSNumber(value: 0.6)
        ]
    }

    static func createNeutral() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: NSNumber(value: 0.1),
            .mouthSmileRight: NSNumber(value: 0.1),
            .browInnerUp: NSNumber(value: 0.1),
            .jawOpen: NSNumber(value: 0.1)
        ]
    }
}

// MARK: - Test Helpers

extension XCTestCase {
    /// Wait for async operations with a timeout
    func waitForAsync(timeout: TimeInterval = 2.0, _ block: @escaping () -> Void) {
        let expectation = self.expectation(description: "Async operation")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            block()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    /// Wait for published value to change
    func waitForPublisher<T: Equatable>(
        _ publisher: Published<T>.Publisher,
        toEqual expectedValue: T,
        timeout: TimeInterval = 2.0
    ) -> Bool {
        let expectation = self.expectation(description: "Publisher value change")
        var cancellable: AnyCancellable?

        cancellable = publisher
            .filter { $0 == expectedValue }
            .sink { _ in
                expectation.fulfill()
                cancellable?.cancel()
            }

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}

// MARK: - Mock Participant for SharePlay Testing

extension GroupActivities.Participant {
    static func createMock(id: UUID = UUID()) -> Participant? {
        // Note: GroupActivities.Participant cannot be easily mocked
        // In production tests, you would use XCTest frameworks or dependency injection
        // This is a placeholder to show testing structure
        return nil
    }
}

// MARK: - Assertion Helpers

func XCTAssertContains<T: Equatable>(_ array: [T], _ element: T, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(array.contains(element), message.isEmpty ? "Array does not contain \(element)" : message, file: file, line: line)
}

func XCTAssertEmpty<T>(_ collection: [T], _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(collection.isEmpty, message.isEmpty ? "Collection is not empty" : message, file: file, line: line)
}

func XCTAssertNotEmpty<T>(_ collection: [T], _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertFalse(collection.isEmpty, message.isEmpty ? "Collection is empty" : message, file: file, line: line)
}

func XCTAssertCount<T>(_ collection: [T], _ expectedCount: Int, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(collection.count, expectedCount, message.isEmpty ? "Collection count (\(collection.count)) does not match expected (\(expectedCount))" : message, file: file, line: line)
}

// MARK: - Performance Testing Helpers

extension XCTestCase {
    func measurePerformance(iterations: Int = 100, _ block: () -> Void) {
        measure {
            for _ in 0..<iterations {
                block()
            }
        }
    }
}
