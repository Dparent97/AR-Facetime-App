import Foundation
import XCTest
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

// MARK: - Test Data

struct TestData {
    // Character test data
    static let testCharacterType = CharacterType.sparkleThePrincess

    static let testPosition = SIMD3<Float>(0, 0, -0.5)
    static let testScale: Float = 1.0

    static let allCharacterTypes: [CharacterType] = CharacterType.allCases
    static let allCharacterActions: [CharacterAction] = [
        .idle, .wave, .dance, .twirl, .jump, .sparkle
    ]

    // Magic effect test data
    static let allEffectTypes: [EffectType] = EffectType.allCases

    // Face expression test data
    static let allFaceExpressions: [FaceExpression] = [
        .smile, .eyebrowsRaised, .mouthOpen
    ]
    
    // Factory methods
    static func createCharacterState(
        id: UUID = UUID(),
        type: CharacterType = .sparkleThePrincess,
        position: SIMD3<Float> = testPosition,
        scale: Float = testScale
    ) -> CharacterState {
        return CharacterState(id: id, type: type, position: position, scale: scale)
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
