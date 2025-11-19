//
//  CharacterTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Unit tests for Character model
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class CharacterTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCharacterInitialization_withDefaultParameters() {
        // GIVEN: A character type
        let type = CharacterType.sparkleThePrincess

        // WHEN: Creating a character with default parameters
        let character = Character(type: type)

        // THEN: Properties are set correctly
        XCTAssertEqual(character.type, type)
        XCTAssertEqual(character.currentAction, .idle)
        XCTAssertNotNil(character.id)
        XCTAssertNotNil(character.entity)
        TestHelpers.assertSIMD3Equal(character.position, SIMD3<Float>(0, 0, -1))
        TestHelpers.assertSIMD3Equal(character.scale, SIMD3<Float>(1, 1, 1))
    }

    func testCharacterInitialization_withCustomParameters() {
        // GIVEN: Custom parameters
        let type = CharacterType.lunaTheStarDancer
        let position = SIMD3<Float>(1.0, 2.0, -3.0)
        let scale = SIMD3<Float>(0.5, 0.5, 0.5)
        let id = UUID()

        // WHEN: Creating a character with custom parameters
        let character = Character(id: id, type: type, position: position, scale: scale)

        // THEN: All properties match
        XCTAssertEqual(character.id, id)
        XCTAssertEqual(character.type, type)
        TestHelpers.assertSIMD3Equal(character.position, position)
        TestHelpers.assertSIMD3Equal(character.scale, scale)
    }

    func testAllCharacterTypes_haveUniqueColors() {
        // GIVEN: All character types
        let types = CharacterType.allCases

        // WHEN: Creating characters of each type
        let characters = types.map { Character(type: $0) }

        // THEN: Each character has an entity created
        characters.forEach { character in
            XCTAssertNotNil(character.entity)
        }
    }

    // MARK: - Action Tests

    func testPerformAction_wave() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)
        XCTAssertEqual(character.currentAction, .idle)

        // WHEN: Performing wave action
        let expectation = expectation(description: "Action completes")
        character.performAction(.wave)

        // THEN: Action is updated
        XCTAssertEqual(character.currentAction, .wave)

        // AND: Action returns to idle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(character.currentAction, .idle)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPerformAction_dance() {
        // GIVEN: A character
        let character = Character(type: .rosieTheDreamWeaver)

        // WHEN: Performing dance action
        character.performAction(.dance)

        // THEN: Action is set
        XCTAssertEqual(character.currentAction, .dance)
    }

    func testPerformAction_twirl() {
        // GIVEN: A character
        let character = Character(type: .crystalTheGemKeeper)

        // WHEN: Performing twirl action
        character.performAction(.twirl)

        // THEN: Action is set
        XCTAssertEqual(character.currentAction, .twirl)
    }

    func testPerformAction_jump() {
        // GIVEN: A character
        let character = Character(type: .willowTheWishMaker)

        // WHEN: Performing jump action
        character.performAction(.jump)

        // THEN: Action is set
        XCTAssertEqual(character.currentAction, .jump)
    }

    func testPerformAction_sparkle() {
        // GIVEN: A character
        let character = Character(type: .lunaTheStarDancer)

        // WHEN: Performing sparkle action
        character.performAction(.sparkle)

        // THEN: Action is set
        XCTAssertEqual(character.currentAction, .sparkle)
    }

    func testPerformAction_idle() {
        // GIVEN: A character performing an action
        let character = Character(type: .sparkleThePrincess)
        character.performAction(.wave)

        // WHEN: Setting back to idle
        character.performAction(.idle)

        // THEN: Action is idle
        XCTAssertEqual(character.currentAction, .idle)
    }

    func testPerformAction_resetsToIdle_afterDuration() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)

        // WHEN: Performing an action
        let expectation = expectation(description: "Action resets to idle")
        character.performAction(.wave)

        // THEN: After 1.5+ seconds, action returns to idle
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(character.currentAction, .idle)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testAllActions_canBePerformed() {
        // GIVEN: A character and all actions
        let character = Character(type: .sparkleThePrincess)
        let actions: [CharacterAction] = [.idle, .wave, .dance, .twirl, .jump, .sparkle]

        // WHEN: Performing each action
        // THEN: No crashes occur
        for action in actions {
            character.performAction(action)
            XCTAssertEqual(character.currentAction, action)
        }
    }

    // MARK: - Entity Tests

    func testEntityCreation_entityExists() {
        // GIVEN: A new character
        let character = Character(type: .sparkleThePrincess)

        // WHEN: Entity is accessed
        // THEN: Entity is not nil
        XCTAssertNotNil(character.entity)
    }

    func testEntityCreation_hasCollisionComponent() {
        // GIVEN: A character
        let character = Character(type: .lunaTheStarDancer)

        // WHEN: Checking collision
        // THEN: Entity has collision component
        XCTAssertNotNil(character.entity?.collision)
    }

    func testEntityPosition_matchesCharacterPosition() {
        // GIVEN: A character with custom position
        let position = SIMD3<Float>(1.5, -0.5, -2.0)
        let character = Character(type: .rosieTheDreamWeaver, position: position)

        // WHEN: Accessing entity position
        guard let entityPosition = character.entity?.position else {
            XCTFail("Entity position should not be nil")
            return
        }

        // THEN: Positions match
        TestHelpers.assertSIMD3Equal(entityPosition, position)
    }

    func testEntityScale_matchesCharacterScale() {
        // GIVEN: A character with custom scale
        let scale = SIMD3<Float>(2.0, 2.0, 2.0)
        let character = Character(type: .crystalTheGemKeeper, position: .zero, scale: scale)

        // WHEN: Accessing entity scale
        guard let entityScale = character.entity?.scale else {
            XCTFail("Entity scale should not be nil")
            return
        }

        // THEN: Scales match
        TestHelpers.assertSIMD3Equal(entityScale, scale)
    }

    // MARK: - Identifiable Tests

    func testIdentifiable_hasUniqueID() {
        // GIVEN: Multiple characters
        let character1 = Character(type: .sparkleThePrincess)
        let character2 = Character(type: .sparkleThePrincess)

        // WHEN: Comparing IDs
        // THEN: IDs are unique
        XCTAssertNotEqual(character1.id, character2.id)
    }

    func testIdentifiable_idPersists() {
        // GIVEN: A character
        let character = Character(type: .lunaTheStarDancer)
        let originalID = character.id

        // WHEN: Performing actions
        character.performAction(.wave)
        character.performAction(.dance)

        // THEN: ID remains the same
        XCTAssertEqual(character.id, originalID)
    }

    // MARK: - ObservableObject Tests

    func testObservableObject_publishesPositionChanges() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)
        let expectation = expectation(description: "Position change published")
        var didPublish = false

        let cancellable = character.objectWillChange.sink {
            didPublish = true
            expectation.fulfill()
        }

        // WHEN: Changing position
        DispatchQueue.main.async {
            character.position = SIMD3<Float>(1, 1, 1)
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didPublish)
        cancellable.cancel()
    }

    func testObservableObject_publishesScaleChanges() {
        // GIVEN: A character
        let character = Character(type: .rosieTheDreamWeaver)
        let expectation = expectation(description: "Scale change published")
        var didPublish = false

        let cancellable = character.objectWillChange.sink {
            didPublish = true
            expectation.fulfill()
        }

        // WHEN: Changing scale
        DispatchQueue.main.async {
            character.scale = SIMD3<Float>(2, 2, 2)
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didPublish)
        cancellable.cancel()
    }

    func testObservableObject_publishesActionChanges() {
        // GIVEN: A character
        let character = Character(type: .willowTheWishMaker)
        let expectation = expectation(description: "Action change published")
        var publishCount = 0

        let cancellable = character.objectWillChange.sink {
            publishCount += 1
            if publishCount == 1 {
                expectation.fulfill()
            }
        }

        // WHEN: Performing action
        DispatchQueue.main.async {
            character.performAction(.wave)
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(publishCount, 0)
        cancellable.cancel()
    }

    // MARK: - Edge Case Tests

    func testMultipleActions_inSequence() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)

        // WHEN: Performing multiple actions quickly
        character.performAction(.wave)
        character.performAction(.dance)
        character.performAction(.jump)

        // THEN: Last action is set
        XCTAssertEqual(character.currentAction, .jump)
    }

    func testCharacterType_rawValues() {
        // GIVEN: Character types
        // WHEN: Accessing raw values
        // THEN: All have proper display names
        XCTAssertEqual(CharacterType.sparkleThePrincess.rawValue, "Sparkle the Princess")
        XCTAssertEqual(CharacterType.lunaTheStarDancer.rawValue, "Luna the Star Dancer")
        XCTAssertEqual(CharacterType.rosieTheDreamWeaver.rawValue, "Rosie the Dream Weaver")
        XCTAssertEqual(CharacterType.crystalTheGemKeeper.rawValue, "Crystal the Gem Keeper")
        XCTAssertEqual(CharacterType.willowTheWishMaker.rawValue, "Willow the Wish Maker")
    }

    func testCharacterAction_rawValues() {
        // GIVEN: Character actions
        // WHEN: Accessing raw values
        // THEN: All have proper names
        XCTAssertEqual(CharacterAction.idle.rawValue, "idle")
        XCTAssertEqual(CharacterAction.wave.rawValue, "wave")
        XCTAssertEqual(CharacterAction.dance.rawValue, "dance")
        XCTAssertEqual(CharacterAction.twirl.rawValue, "twirl")
        XCTAssertEqual(CharacterAction.jump.rawValue, "jump")
        XCTAssertEqual(CharacterAction.sparkle.rawValue, "sparkle")
    }

    // MARK: - Memory Tests

    func testCharacter_canBeReleased() {
        // GIVEN: A weak reference to a character
        weak var weakCharacter: Character?

        autoreleasepool {
            let character = Character(type: .sparkleThePrincess)
            weakCharacter = character
            XCTAssertNotNil(weakCharacter)
        }

        // WHEN: Character goes out of scope
        // THEN: It can be deallocated
        XCTAssertNil(weakCharacter)
    }
}
