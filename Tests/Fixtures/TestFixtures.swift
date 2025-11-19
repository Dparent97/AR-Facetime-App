<<<<<<< HEAD
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
||||||| e86307c
=======
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
>>>>>>> origin/claude/qa-engineer-setup-018opoWboXZWozhVCKPoChNQ
