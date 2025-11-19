//
//  TestFixtures.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Reusable test data and mock objects
//

import Foundation
import ARKit
import RealityKit
import Combine
@testable import AriasMagicApp

// MARK: - Mock ARFace Anchor

class MockARFaceAnchor: ARFaceAnchor {
    private var mockBlendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]

    init(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:]) {
        self.mockBlendShapes = blendShapes
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(anchor: ARAnchor) {
        self.mockBlendShapes = [:]
        super.init(anchor: anchor)
    }

    override var blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber] {
        return mockBlendShapes
    }

    // Factory methods for common expressions
    static func smiling() -> MockARFaceAnchor {
        return MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 0.8,
            .mouthSmileRight: 0.8
        ])
    }

    static func eyebrowsRaised() -> MockARFaceAnchor {
        return MockARFaceAnchor(blendShapes: [
            .browInnerUp: 0.7
        ])
    }

    static func mouthOpen() -> MockARFaceAnchor {
        return MockARFaceAnchor(blendShapes: [
            .jawOpen: 0.6
        ])
    }

    static func neutral() -> MockARFaceAnchor {
        return MockARFaceAnchor(blendShapes: [:])
    }

    static func subtleSmile() -> MockARFaceAnchor {
        return MockARFaceAnchor(blendShapes: [
            .mouthSmileLeft: 0.3,
            .mouthSmileRight: 0.3
        ])
    }
}

// MARK: - Mock Face Tracking Delegate

class MockFaceTrackingDelegate: FaceTrackingDelegate {
    var detectedExpressions: [FaceExpression] = []
    var lastExpression: FaceExpression?
    var expressionCallCount: Int = 0

    func didDetectExpression(_ expression: FaceExpression) {
        detectedExpressions.append(expression)
        lastExpression = expression
        expressionCallCount += 1
    }

    func reset() {
        detectedExpressions.removeAll()
        lastExpression = nil
        expressionCallCount = 0
    }
}

// MARK: - Mock GroupSessionMessenger

class MockGroupSessionMessenger {
    var sentMessages: [SyncMessage] = []
    var mockIncomingMessages: [SyncMessage] = []

    func send(_ message: SyncMessage) async throws {
        sentMessages.append(message)
    }

    func simulateIncomingMessage(_ message: SyncMessage) {
        mockIncomingMessages.append(message)
    }

    func reset() {
        sentMessages.removeAll()
        mockIncomingMessages.removeAll()
    }
}

// MARK: - Test Data

struct TestData {
    // Character test data
    static let testCharacter = Character(type: .sparkleThePrincess)

    static let testPosition = SIMD3<Float>(0, 0, -0.5)
    static let testScale = SIMD3<Float>(1, 1, 1)

    static let allCharacterTypes: [CharacterType] = CharacterType.allCases
    static let allCharacterActions: [CharacterAction] = [
        .idle, .wave, .dance, .twirl, .jump, .sparkle
    ]

    // Magic effect test data
    static let allMagicEffects: [MagicEffect] = MagicEffect.allCases

    // Face expression test data
    static let allFaceExpressions: [FaceExpression] = [
        .smile, .eyebrowsRaised, .mouthOpen
    ]

    // Sync message test data
    static func createSpawnMessage(
        characterID: UUID = UUID(),
        characterType: CharacterType = .sparkleThePrincess,
        position: SIMD3<Float> = SIMD3<Float>(0, 0, -0.5)
    ) -> SyncMessage {
        return SyncMessage(
            type: .characterSpawned,
            characterID: characterID,
            characterType: characterType,
            position: [position.x, position.y, position.z],
            action: nil,
            effect: nil
        )
    }

    static func createActionMessage(
        characterID: UUID = UUID(),
        action: CharacterAction = .wave
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

    static func createEffectMessage(
        effect: MagicEffect = .sparkles
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

class TestHelpers {
    /// Wait for async operation to complete
    static func wait(seconds: TimeInterval) {
        let expectation = XCTestExpectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: seconds + 1.0)
    }

    /// Create a test character with custom properties
    static func createTestCharacter(
        type: CharacterType = .sparkleThePrincess,
        position: SIMD3<Float> = SIMD3<Float>(0, 0, -0.5),
        scale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)
    ) -> Character {
        return Character(type: type, position: position, scale: scale)
    }

    /// Verify that two SIMD3 values are approximately equal
    static func assertSIMD3Equal(
        _ lhs: SIMD3<Float>,
        _ rhs: SIMD3<Float>,
        accuracy: Float = 0.001,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs.x, rhs.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.y, rhs.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.z, rhs.z, accuracy: accuracy, file: file, line: line)
    }
}

// MARK: - Performance Test Helpers

class PerformanceTestHelpers {
    /// Measure memory usage
    static func measureMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        return 0
    }

    /// Generate load test characters
    static func generateCharacters(count: Int) -> [Character] {
        var characters: [Character] = []
        for i in 0..<count {
            let type = CharacterType.allCases[i % CharacterType.allCases.count]
            let position = SIMD3<Float>(
                Float.random(in: -1.0...1.0),
                Float.random(in: -1.0...1.0),
                Float.random(in: -2.0...0)
            )
            characters.append(Character(type: type, position: position))
        }
        return characters
    }
}
