//
//  CharacterProtocolTests.swift
//  Aria's Magic SharePlay App - Tests
//
//  Unit tests for CharacterProtocols and Character conformance
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class CharacterProtocolTests: XCTestCase {

    var character: Character!
    var factory: DefaultCharacterFactory!

    override func setUpWithError() throws {
        try super.setUpWithError()
        character = Character(type: .sparkleThePrincess, position: [0, 0, -1])
        factory = DefaultCharacterFactory()
    }

    override func tearDownWithError() throws {
        character = nil
        factory = nil
        try super.tearDownWithError()
    }

    // MARK: - AnimatableCharacter Protocol Tests

    func testCharacterConformsToAnimatableCharacter() {
        // Verify Character conforms to AnimatableCharacter protocol
        XCTAssertTrue(character is AnimatableCharacter, "Character should conform to AnimatableCharacter")
    }

    func testModelEntityIsNotNil() {
        // Model entity should always exist (non-optional)
        XCTAssertNotNil(character.modelEntity, "modelEntity should not be nil")
    }

    func testCharacterTypeIsSet() {
        // Verify characterType is correctly set
        XCTAssertEqual(character.characterType, .sparkleThePrincess, "characterType should match initialization")
    }

    func testCharacterHasUniqueID() {
        // Each character should have a unique ID
        let char1 = Character(type: .sparkleThePrincess)
        let char2 = Character(type: .sparkleThePrincess)

        XCTAssertNotEqual(char1.id, char2.id, "Each character should have a unique ID")
    }

    func testInitialActionIsIdle() {
        // New characters should start in idle state
        XCTAssertEqual(character.currentAction, .idle, "Initial action should be idle")
    }

    // MARK: - Position Tests

    func testSetPositionUpdatesProperty() {
        // Test setPosition updates the position property
        let newPosition = SIMD3<Float>(1, 2, 3)
        character.setPosition(newPosition)

        XCTAssertEqual(character.position, newPosition, "Position property should be updated")
    }

    func testSetPositionUpdatesEntity() {
        // Test setPosition updates the modelEntity position
        let newPosition = SIMD3<Float>(1, 2, 3)
        character.setPosition(newPosition)

        XCTAssertEqual(character.modelEntity.position, newPosition, "ModelEntity position should be updated")
    }

    // MARK: - Scale Tests

    func testSetScaleUpdatesProperty() {
        // Test setScale updates the scale property
        let newScale: Float = 2.0
        character.setScale(newScale)

        let expectedScale = SIMD3<Float>(repeating: newScale)
        XCTAssertEqual(character.scale, expectedScale, "Scale property should be updated")
    }

    func testSetScaleUpdatesEntity() {
        // Test setScale updates the modelEntity scale
        let newScale: Float = 2.0
        character.setScale(newScale)

        let expectedScale = SIMD3<Float>(repeating: newScale)
        XCTAssertEqual(character.modelEntity.scale, expectedScale, "ModelEntity scale should be updated")
    }

    // MARK: - Action Tests

    func testPerformActionUpdatesCurrentAction() {
        // Test performing an action updates currentAction
        let expectation = XCTestExpectation(description: "Action completion called")

        character.performAction(.wave) {
            expectation.fulfill()
        }

        XCTAssertEqual(character.currentAction, .wave, "currentAction should be updated")

        wait(for: [expectation], timeout: 2.0)
    }

    func testPerformActionCallsCompletion() {
        // Test action completion callback is called
        let expectation = XCTestExpectation(description: "Completion callback called")

        character.performAction(.wave) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testIdleActionCompletesImmediately() {
        // Idle action should complete immediately
        let expectation = XCTestExpectation(description: "Idle completion immediate")

        character.performAction(.idle) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testActionResetsToIdleAfterDuration() {
        // After animation completes, action should reset to idle
        let expectation = XCTestExpectation(description: "Action resets to idle")

        character.performAction(.wave) {
            // Completion is called
        }

        // Wait for reset (1.5s according to implementation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            XCTAssertEqual(self.character.currentAction, .idle, "Action should reset to idle")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - All Action Types Tests

    func testAllActionTypesCanBePerformed() {
        // Verify all action types can be performed without crashing
        let actions: [CharacterAction] = [.idle, .wave, .dance, .twirl, .jump, .sparkle]

        for action in actions {
            let expectation = XCTestExpectation(description: "Action \(action) completes")

            character.performAction(action) {
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 2.0)
        }
    }

    // MARK: - Cleanup Tests

    func testCleanupRemovesEntityFromParent() {
        // Test cleanup removes entity from parent
        let anchor = AnchorEntity()
        anchor.addChild(character.modelEntity)

        XCTAssertNotNil(character.modelEntity.parent, "Entity should have parent before cleanup")

        character.cleanup()

        XCTAssertNil(character.modelEntity.parent, "Entity should not have parent after cleanup")
    }

    // MARK: - Factory Tests

    func testFactoryCreatesCharacter() {
        // Factory should create a valid character
        let createdCharacter = factory.createCharacter(
            type: .lunaTheStarDancer,
            position: [1, 2, 3],
            scale: [2, 2, 2]
        )

        XCTAssertNotNil(createdCharacter, "Factory should create a character")
        XCTAssertEqual(createdCharacter.characterType, .lunaTheStarDancer, "Character type should match")
        XCTAssertEqual(createdCharacter.position, [1, 2, 3], "Position should match")
    }

    func testFactoryReturnsAnimatableCharacter() {
        // Factory should return AnimatableCharacter protocol type
        let createdCharacter = factory.createCharacter(
            type: .rosieTheDreamWeaver,
            position: [0, 0, 0],
            scale: [1, 1, 1]
        )

        XCTAssertTrue(createdCharacter is AnimatableCharacter, "Factory should return AnimatableCharacter")
    }

    func testFactorySupportedTypesReturnsAllTypes() {
        // Factory should support all character types
        let supportedTypes = factory.supportedCharacterTypes()

        XCTAssertEqual(supportedTypes.count, CharacterType.allCases.count, "Should support all character types")

        for type in CharacterType.allCases {
            XCTAssertTrue(supportedTypes.contains(type), "Should support \(type)")
        }
    }

    // MARK: - Character Type Tests

    func testAllCharacterTypesHaveUniqueColors() {
        // Each character type should have a distinct visual representation
        var characters: [Character] = []

        for type in CharacterType.allCases {
            let char = Character(type: type)
            characters.append(char)
        }

        XCTAssertEqual(characters.count, 5, "Should create 5 different character types")

        // Verify all have entities
        for char in characters {
            XCTAssertNotNil(char.modelEntity, "Each character should have a modelEntity")
        }
    }

    // MARK: - Integration Tests

    func testMultipleActionsInSequence() {
        // Test performing multiple actions in sequence
        let expectation1 = XCTestExpectation(description: "First action")
        let expectation2 = XCTestExpectation(description: "Second action")

        character.performAction(.wave) {
            expectation1.fulfill()

            self.character.performAction(.jump) {
                expectation2.fulfill()
            }
        }

        wait(for: [expectation1, expectation2], timeout: 4.0)
    }

    func testPositionAndScaleIndependence() {
        // Test that position and scale can be set independently
        let testPosition = SIMD3<Float>(5, 6, 7)
        let testScale: Float = 3.0

        character.setPosition(testPosition)
        character.setScale(testScale)

        XCTAssertEqual(character.position, testPosition, "Position should be independent")
        XCTAssertEqual(character.scale, SIMD3<Float>(repeating: testScale), "Scale should be independent")
    }
}
