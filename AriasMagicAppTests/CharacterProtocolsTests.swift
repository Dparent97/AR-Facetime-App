//
//  CharacterProtocolsTests.swift
//  AriasMagicAppTests
//
//  Unit tests for CharacterProtocols and Character conformance
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class CharacterProtocolsTests: XCTestCase {

    // MARK: - Character Protocol Conformance Tests

    func testCharacterConformsToAnimatableCharacter() {
        // Given
        let character = Character(type: .sparkleThePrincess, position: [0, 0, -1])

        // Then
        XCTAssertNotNil(character as? AnimatableCharacter, "Character should conform to AnimatableCharacter")
    }

    func testCharacterHasValidID() {
        // Given
        let character = Character(type: .lunaTheStarDancer)

        // Then
        XCTAssertNotNil(character.id, "Character should have a valid UUID")
    }

    func testCharacterHasModelEntity() {
        // Given
        let character = Character(type: .rosieTheDreamWeaver)

        // Then
        XCTAssertNotNil(character.entity, "Character should have a ModelEntity")
        XCTAssertNoThrow(character.modelEntity, "ModelEntity should be accessible")
    }

    func testCharacterTypeMatches() {
        // Given
        let expectedType = CharacterType.crystalTheGemKeeper
        let character = Character(type: expectedType)

        // Then
        XCTAssertEqual(character.characterType, expectedType, "CharacterType should match")
        XCTAssertEqual(character.type, expectedType, "Type should match")
    }

    func testCharacterInitialState() {
        // Given
        let position = SIMD3<Float>(0.5, 0.5, -2.0)
        let scale = SIMD3<Float>(2.0, 2.0, 2.0)
        let character = Character(type: .willowTheWishMaker, position: position, scale: scale)

        // Then
        XCTAssertEqual(character.position, position, "Initial position should be set correctly")
        XCTAssertEqual(character.scale, scale, "Initial scale should be set correctly")
        XCTAssertEqual(character.currentAction, .idle, "Initial action should be idle")
    }

    // MARK: - Character Action Tests

    func testPerformActionUpdatesCurrentAction() {
        // Given
        let character = Character(type: .sparkleThePrincess)
        let expectation = XCTestExpectation(description: "Action completes")

        // When
        character.performAction(.wave) {
            expectation.fulfill()
        }

        // Then
        XCTAssertEqual(character.currentAction, .wave, "Current action should be updated")
        wait(for: [expectation], timeout: 2.0)
    }

    func testPerformActionCallsCompletion() {
        // Given
        let character = Character(type: .lunaTheStarDancer)
        let expectation = XCTestExpectation(description: "Completion called")
        var completionCalled = false

        // When
        character.performAction(.jump) {
            completionCalled = true
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(completionCalled, "Completion should be called")
    }

    func testPerformActionIdleCompletesImmediately() {
        // Given
        let character = Character(type: .rosieTheDreamWeaver)
        let expectation = XCTestExpectation(description: "Idle completes immediately")

        // When
        character.performAction(.idle) {
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.1)
    }

    func testAllCharacterActionsExecute() {
        // Given
        let character = Character(type: .crystalTheGemKeeper)
        let actions: [CharacterAction] = [.wave, .dance, .twirl, .jump, .sparkle]

        // When/Then
        for action in actions {
            let expectation = XCTestExpectation(description: "Action \(action.rawValue) completes")
            character.performAction(action) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 3.0)
        }
    }

    // MARK: - Position and Scale Tests

    func testSetPosition() {
        // Given
        let character = Character(type: .willowTheWishMaker)
        let newPosition = SIMD3<Float>(1.0, 2.0, -3.0)

        // When
        character.setPosition(newPosition)

        // Then
        XCTAssertEqual(character.position, newPosition, "Position should be updated")
        XCTAssertEqual(character.entity?.position, newPosition, "Entity position should be updated")
    }

    func testSetScale() {
        // Given
        let character = Character(type: .sparkleThePrincess)
        let newScale: Float = 2.5

        // When
        character.setScale(newScale)

        // Then
        let expectedScale = SIMD3<Float>(repeating: newScale)
        XCTAssertEqual(character.scale, expectedScale, "Scale should be updated")
        XCTAssertEqual(character.entity?.scale, expectedScale, "Entity scale should be updated")
    }

    // MARK: - Cleanup Tests

    func testCleanup() {
        // Given
        let character = Character(type: .lunaTheStarDancer)
        let parentEntity = Entity()
        parentEntity.addChild(character.modelEntity)

        // When
        character.cleanup()

        // Then
        XCTAssertNil(character.modelEntity.parent, "Entity should be removed from parent")
    }

    // MARK: - CharacterFactory Tests

    func testPlaceholderFactoryCreatesCharacter() {
        // Given
        let factory = PlaceholderCharacterFactory.shared

        // When
        let character = factory.createCharacter(type: .sparkleThePrincess, at: [0, 0, -1], scale: [1, 1, 1])

        // Then
        XCTAssertNotNil(character, "Factory should create a character")
        XCTAssertEqual(character.characterType, .sparkleThePrincess, "Character type should match")
    }

    func testPlaceholderFactorySupportedTypes() {
        // Given
        let factory = PlaceholderCharacterFactory.shared

        // When
        let supportedTypes = factory.supportedCharacterTypes()

        // Then
        XCTAssertEqual(supportedTypes.count, CharacterType.allCases.count, "Should support all character types")
        XCTAssertEqual(supportedTypes, CharacterType.allCases, "Should support all character types")
    }

    func testFactoryRegistryDefaultFactory() {
        // Given
        let registry = CharacterFactoryRegistry.shared

        // When
        let factory = registry.getFactory()

        // Then
        XCTAssertTrue(factory is PlaceholderCharacterFactory, "Default factory should be PlaceholderCharacterFactory")
    }

    func testFactoryRegistryCreateCharacter() {
        // Given
        let registry = CharacterFactoryRegistry.shared

        // When
        let character = registry.createCharacter(type: .crystalTheGemKeeper, at: [0, 1, -2], scale: [2, 2, 2])

        // Then
        XCTAssertNotNil(character, "Registry should create character")
        XCTAssertEqual(character.characterType, .crystalTheGemKeeper, "Character type should match")
    }

    // MARK: - Collection Extension Tests

    func testCollectionPerformAction() {
        // Given
        let characters: [AnimatableCharacter] = [
            Character(type: .sparkleThePrincess),
            Character(type: .lunaTheStarDancer),
            Character(type: .rosieTheDreamWeaver)
        ]
        let expectation = XCTestExpectation(description: "All characters complete action")

        // When
        characters.performAction(.wave) {
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 3.0)
        characters.forEach { character in
            XCTAssertEqual(character.currentAction, .wave, "All characters should have performed the action")
        }
    }

    func testCollectionPerformActionWithoutCompletion() {
        // Given
        let characters: [AnimatableCharacter] = [
            Character(type: .crystalTheGemKeeper),
            Character(type: .willowTheWishMaker)
        ]

        // When
        characters.performAction(.jump)

        // Then
        // Should not crash, completion is optional
        characters.forEach { character in
            XCTAssertEqual(character.currentAction, .jump, "All characters should have performed the action")
        }
    }

    // MARK: - Integration Tests

    func testFactoryIntegrationWithViewModel() {
        // Given
        let factory = CharacterFactoryRegistry.shared
        let characterType = CharacterType.sparkleThePrincess
        let position = SIMD3<Float>(0, 0, -1)

        // When
        let character = factory.createCharacter(type: characterType, at: position)

        // Then - Character should be ready to use in ViewModel
        XCTAssertNotNil(character.modelEntity, "Character should have entity")
        XCTAssertEqual(character.position, position, "Position should match")
        XCTAssertEqual(character.characterType, characterType, "Type should match")
    }

    func testMultipleCharactersIndependence() {
        // Given
        let character1 = Character(type: .sparkleThePrincess)
        let character2 = Character(type: .lunaTheStarDancer)
        let expectation1 = XCTestExpectation(description: "Character 1 completes")
        let expectation2 = XCTestExpectation(description: "Character 2 completes")

        // When
        character1.performAction(.wave) {
            expectation1.fulfill()
        }
        character2.performAction(.jump) {
            expectation2.fulfill()
        }

        // Then
        wait(for: [expectation1, expectation2], timeout: 3.0)
        XCTAssertEqual(character1.currentAction, .wave, "Character 1 should have independent action")
        XCTAssertEqual(character2.currentAction, .jump, "Character 2 should have independent action")
    }
}
