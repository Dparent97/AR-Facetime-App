//
//  TestFixtures.swift
//  Aria's Magic SharePlay App - Tests
//
//  Reusable test data and mock objects for testing
//

import Foundation
import XCTest
import ARKit
import GroupActivities
import Combine
@testable import AriasMagicApp

// MARK: - Mock ARFaceAnchor

class MockARFaceAnchor {
    var blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:]

    /// Creates a mock face anchor with a smiling expression
    static func smiling() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: 0.8,
            .mouthSmileRight: 0.8,
            .jawOpen: 0.0,
            .browInnerUp: 0.0
        ]
    }

    /// Creates a mock face anchor with eyebrows raised
    static func eyebrowsRaised() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: 0.0,
            .mouthSmileRight: 0.0,
            .jawOpen: 0.0,
            .browInnerUp: 0.8
        ]
    }

    /// Creates a mock face anchor with mouth open
    static func mouthOpen() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: 0.0,
            .mouthSmileRight: 0.0,
            .jawOpen: 0.7,
            .browInnerUp: 0.0
        ]
    }

    /// Creates a mock face anchor with neutral expression
    static func neutral() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: 0.0,
            .mouthSmileRight: 0.0,
            .jawOpen: 0.0,
            .browInnerUp: 0.0
        ]
    }

    /// Creates a mock face anchor with subtle smile (below threshold)
    static func subtleSmile() -> [ARFaceAnchor.BlendShapeLocation: NSNumber] {
        return [
            .mouthSmileLeft: 0.3,
            .mouthSmileRight: 0.3,
            .jawOpen: 0.0,
            .browInnerUp: 0.0
        ]
    }
}

// MARK: - Mock FaceTrackingDelegate

class MockFaceTrackingDelegate: FaceTrackingDelegate {
    var detectedExpressions: [FaceExpression] = []
    var expressionCount: Int { detectedExpressions.count }
    var lastExpression: FaceExpression? { detectedExpressions.last }

    func didDetectExpression(_ expression: FaceExpression) {
        detectedExpressions.append(expression)
    }

    func reset() {
        detectedExpressions.removeAll()
    }
}

// MARK: - Mock GroupSessionMessenger

class MockGroupSessionMessenger {
    var sentMessages: [SyncMessage] = []
    var mockIncomingMessages: [SyncMessage] = []

    func send(_ message: SyncMessage) async throws {
        sentMessages.append(message)
    }

    func messages<T>(of type: T.Type) -> AsyncStream<(T, MockParticipant)> where T: Codable {
        return AsyncStream { continuation in
            for message in mockIncomingMessages {
                if let typedMessage = message as? T {
                    continuation.yield((typedMessage, MockParticipant()))
                }
            }
            continuation.finish()
        }
    }

    func reset() {
        sentMessages.removeAll()
        mockIncomingMessages.removeAll()
    }
}

// MARK: - Mock Participant

class MockParticipant {
    let id = UUID()
}

// MARK: - Test Data

struct TestData {
    // MARK: Character Test Data

    static let testCharacterSparkle = Character(type: .sparkleThePrincess)
    static let testCharacterLuna = Character(type: .lunaTheStarDancer)
    static let testCharacterRosie = Character(type: .rosieTheDreamWeaver)

    static let testPosition = SIMD3<Float>(0, 0, -0.5)
    static let testPositionNear = SIMD3<Float>(0.1, 0.1, -0.3)
    static let testPositionFar = SIMD3<Float>(0, 0, -1.5)

    static let testScale = SIMD3<Float>(1, 1, 1)
    static let testScaleLarge = SIMD3<Float>(2, 2, 2)
    static let testScaleSmall = SIMD3<Float>(0.5, 0.5, 0.5)

    static let allCharacterTypes: [CharacterType] = [
        .sparkleThePrincess,
        .lunaTheStarDancer,
        .rosieTheDreamWeaver,
        .crystalTheGemKeeper,
        .willowTheWishMaker
    ]

    static let allCharacterActions: [CharacterAction] = [
        .idle,
        .wave,
        .dance,
        .twirl,
        .jump,
        .sparkle
    ]

    // MARK: Magic Effect Test Data

    static let allMagicEffects: [MagicEffect] = [
        .sparkles,
        .snow,
        .bubbles
    ]

    // MARK: Sync Message Test Data

    static func createCharacterSpawnedMessage(
        characterType: CharacterType = .sparkleThePrincess,
        position: SIMD3<Float> = testPosition
    ) -> SyncMessage {
        return SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: characterType,
            position: [position.x, position.y, position.z],
            action: nil,
            effect: nil
        )
    }

    static func createCharacterActionMessage(
        characterID: UUID,
        action: CharacterAction
    ) -> SyncMessage {
        return SyncMessage(
            type: .characterAction,
            characterID: characterID,
            characterType: nil,
            position: nil,
            action: action,
            effect: nil
        )
    }

    static func createEffectTriggeredMessage(
        effect: MagicEffect
    ) -> SyncMessage {
        return SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: effect.rawValue
        )
    }
}

// MARK: - Test Helpers

extension XCTestCase {
    /// Wait for a condition to be true with timeout
    func wait(for condition: @escaping () -> Bool, timeout: TimeInterval = 2.0, description: String = "Condition") {
        let expectation = self.expectation(description: description)

        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if condition() {
                expectation.fulfill()
                timer.invalidate()
            }
        }

        wait(for: [expectation], timeout: timeout)
        timer.invalidate()
    }

    /// Wait for async operation
    func waitAsync(timeout: TimeInterval = 2.0) async {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
    }
}

// MARK: - Performance Test Helpers

struct PerformanceMetrics {
    static func measureMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return result == KERN_SUCCESS ? info.resident_size : 0
    }
}
