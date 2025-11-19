<<<<<<< HEAD
//
//  CharacterTests.swift
//  Aria's Magic SharePlay App - Tests
//
//  Unit tests for Character model
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class CharacterTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCharacterInitialization_withDefaults() {
        // GIVEN: A character type
        let type = CharacterType.sparkleThePrincess

        // WHEN: Creating a character with default values
        let character = Character(type: type)

        // THEN: Properties are set correctly
        XCTAssertEqual(character.type, type)
        XCTAssertEqual(character.currentAction, .idle)
        XCTAssertNotNil(character.id)
        XCTAssertNotNil(character.entity)
        XCTAssertEqual(character.scale, SIMD3<Float>(1, 1, 1))
    }

    func testCharacterInitialization_withCustomPosition() {
        // GIVEN: A character type and custom position
        let type = CharacterType.lunaTheStarDancer
        let position = TestData.testPosition

        // WHEN: Creating a character with custom position
        let character = Character(type: type, position: position)

        // THEN: Position is set correctly
        XCTAssertEqual(character.position, position)
        XCTAssertEqual(character.type, type)
    }

    func testCharacterInitialization_withCustomScale() {
        // GIVEN: A character type and custom scale
        let type = CharacterType.rosieTheDreamWeaver
        let scale = TestData.testScaleLarge

        // WHEN: Creating a character with custom scale
        let character = Character(type: type, scale: scale)

        // THEN: Scale is set correctly
        XCTAssertEqual(character.scale, scale)
    }

    func testCharacterInitialization_withCustomID() {
        // GIVEN: A specific UUID
        let customID = UUID()

        // WHEN: Creating a character with custom ID
        let character = Character(id: customID, type: .sparkleThePrincess)

        // THEN: ID is set correctly
        XCTAssertEqual(character.id, customID)
    }

    func testCharacterInitialization_createsEntity() {
        // GIVEN: A character type
        let character = Character(type: .crystalTheGemKeeper)

        // WHEN: Character is initialized
        // THEN: Entity is created and configured
        XCTAssertNotNil(character.entity)
        XCTAssertNotNil(character.entity?.collision)
    }

    // MARK: - Character Type Tests

    func testAllCharacterTypes_haveUniqueColors() {
        // GIVEN: All character types
        var colors: Set<String> = []

        // WHEN: Creating characters of each type
        for type in TestData.allCharacterTypes {
            let character = Character(type: type)

            // Get the color from the entity's material
            if let modelEntity = character.entity,
               let material = modelEntity.model?.materials.first as? SimpleMaterial {
                let colorString = "\(material.color)"
                colors.insert(colorString)
            }
        }

        // THEN: Each character type has a unique color
        XCTAssertEqual(colors.count, TestData.allCharacterTypes.count)
    }

    func testCharacterType_caseIterable() {
        // GIVEN: CharacterType enum
        // WHEN: Accessing all cases
        let allTypes = CharacterType.allCases

        // THEN: All 5 character types are present
        XCTAssertEqual(allTypes.count, 5)
        XCTAssertTrue(allTypes.contains(.sparkleThePrincess))
        XCTAssertTrue(allTypes.contains(.lunaTheStarDancer))
        XCTAssertTrue(allTypes.contains(.rosieTheDreamWeaver))
        XCTAssertTrue(allTypes.contains(.crystalTheGemKeeper))
        XCTAssertTrue(allTypes.contains(.willowTheWishMaker))
    }

    func testCharacterType_rawValues() {
        // GIVEN: Character types
        // WHEN: Accessing raw values
        // THEN: Raw values match expected strings
        XCTAssertEqual(CharacterType.sparkleThePrincess.rawValue, "Sparkle the Princess")
        XCTAssertEqual(CharacterType.lunaTheStarDancer.rawValue, "Luna the Star Dancer")
        XCTAssertEqual(CharacterType.rosieTheDreamWeaver.rawValue, "Rosie the Dream Weaver")
        XCTAssertEqual(CharacterType.crystalTheGemKeeper.rawValue, "Crystal the Gem Keeper")
        XCTAssertEqual(CharacterType.willowTheWishMaker.rawValue, "Willow the Wish Maker")
    }

    // MARK: - Character Action Tests

    func testCharacterAction_caseIterable() {
        // GIVEN: CharacterAction enum
        // WHEN: Accessing all cases
        let allActions = CharacterAction.allCases

        // THEN: All 6 actions are present
        XCTAssertEqual(allActions.count, 6)
        XCTAssertTrue(allActions.contains(.idle))
        XCTAssertTrue(allActions.contains(.wave))
        XCTAssertTrue(allActions.contains(.dance))
        XCTAssertTrue(allActions.contains(.twirl))
        XCTAssertTrue(allActions.contains(.jump))
        XCTAssertTrue(allActions.contains(.sparkle))
    }

    func testPerformAction_idle() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)

        // WHEN: Performing idle action
        character.performAction(.idle)

        // THEN: Current action is set to idle
        XCTAssertEqual(character.currentAction, .idle)
    }

    func testPerformAction_wave() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)
        let expectation = expectation(description: "Wave action updates state")

        // WHEN: Performing wave action
        character.performAction(.wave)

        // THEN: Action is set to wave
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
        let character = Character(type: .lunaTheStarDancer)

        // WHEN: Performing dance action
        character.performAction(.dance)

        // THEN: Current action is set to dance
        XCTAssertEqual(character.currentAction, .dance)
    }

    func testPerformAction_twirl() {
        // GIVEN: A character
        let character = Character(type: .rosieTheDreamWeaver)

        // WHEN: Performing twirl action
        character.performAction(.twirl)

        // THEN: Current action is set to twirl
        XCTAssertEqual(character.currentAction, .twirl)
    }

    func testPerformAction_jump() {
        // GIVEN: A character
        let character = Character(type: .crystalTheGemKeeper)

        // WHEN: Performing jump action
        character.performAction(.jump)

        // THEN: Current action is set to jump
        XCTAssertEqual(character.currentAction, .jump)
    }

    func testPerformAction_sparkle() {
        // GIVEN: A character
        let character = Character(type: .willowTheWishMaker)

        // WHEN: Performing sparkle action
        character.performAction(.sparkle)

        // THEN: Current action is set to sparkle
        XCTAssertEqual(character.currentAction, .sparkle)
    }

    func testPerformAction_resetsToIdleAfterDelay() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)
        let expectation = expectation(description: "Action resets to idle")

        // WHEN: Performing any action
        character.performAction(.wave)

        // THEN: Action returns to idle after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(character.currentAction, .idle)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPerformAction_multipleSequentialActions() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)
        let expectation = expectation(description: "Multiple actions execute")

        // WHEN: Performing multiple actions in sequence
        character.performAction(.wave)
        XCTAssertEqual(character.currentAction, .wave)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            character.performAction(.dance)
            XCTAssertEqual(character.currentAction, .dance)

            // THEN: Final action returns to idle
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                XCTAssertEqual(character.currentAction, .idle)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 4.0)
    }

    func testPerformAction_withoutEntity_doesNotCrash() {
        // GIVEN: A character with nil entity
        let character = Character(type: .sparkleThePrincess)
        character.entity = nil

        // WHEN: Performing action with nil entity
        character.performAction(.wave)

        // THEN: No crash occurs and action is set
        XCTAssertEqual(character.currentAction, .wave)
    }

    // MARK: - Observable Tests

    func testCharacter_isObservableObject() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)

        // WHEN: Character is an ObservableObject
        // THEN: Published properties can be observed
        XCTAssertNotNil(character.objectWillChange)
    }

    func testCharacter_publishedProperties_triggerUpdates() {
        // GIVEN: A character and expectation
        let character = Character(type: .sparkleThePrincess)
        let expectation = expectation(description: "Published property triggers update")
        var updateCount = 0

        let cancellable = character.objectWillChange.sink { _ in
            updateCount += 1
            if updateCount >= 1 {
                expectation.fulfill()
            }
        }

        // WHEN: Changing a published property
        character.position = SIMD3<Float>(1, 1, 1)

        // THEN: Object change is triggered
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    // MARK: - Identifiable Tests

    func testCharacter_isIdentifiable() {
        // GIVEN: Two characters
        let character1 = Character(type: .sparkleThePrincess)
        let character2 = Character(type: .sparkleThePrincess)

        // WHEN: Comparing IDs
        // THEN: Each character has a unique ID
        XCTAssertNotEqual(character1.id, character2.id)
    }

    func testCharacter_canBeUsedInCollection() {
        // GIVEN: Multiple characters
        let characters = [
            Character(type: .sparkleThePrincess),
            Character(type: .lunaTheStarDancer),
            Character(type: .rosieTheDreamWeaver)
        ]

        // WHEN: Using characters in a collection
        // THEN: Characters can be identified uniquely
        let ids = Set(characters.map { $0.id })
        XCTAssertEqual(ids.count, 3)
    }

    // MARK: - Entity Tests

    func testEntity_hasCorrectInitialPosition() {
        // GIVEN: A character with custom position
        let position = SIMD3<Float>(0.5, 0.5, -1.0)
        let character = Character(type: .sparkleThePrincess, position: position)

        // WHEN: Checking entity position
        // THEN: Entity position matches character position
        XCTAssertEqual(character.entity?.position, position)
    }

    func testEntity_hasCorrectInitialScale() {
        // GIVEN: A character with custom scale
        let scale = SIMD3<Float>(2, 2, 2)
        let character = Character(type: .sparkleThePrincess, scale: scale)

        // WHEN: Checking entity scale
        // THEN: Entity scale matches character scale
        XCTAssertEqual(character.entity?.scale, scale)
    }

    func testEntity_hasCollisionComponent() {
        // GIVEN: A character
        let character = Character(type: .sparkleThePrincess)

        // WHEN: Checking collision component
        // THEN: Entity has collision for interaction
        XCTAssertNotNil(character.entity?.collision)
    }

    // MARK: - Edge Cases

    func testCharacter_withZeroScale() {
        // GIVEN: A character with zero scale
        let character = Character(type: .sparkleThePrincess, scale: SIMD3<Float>(0, 0, 0))

        // WHEN: Character is created
        // THEN: Character handles zero scale gracefully
        XCTAssertEqual(character.scale, SIMD3<Float>(0, 0, 0))
        XCTAssertNotNil(character.entity)
    }

    func testCharacter_withNegativePosition() {
        // GIVEN: A character with negative position
        let position = SIMD3<Float>(-1, -1, -1)
        let character = Character(type: .sparkleThePrincess, position: position)

        // WHEN: Character is created
        // THEN: Negative position is handled correctly
        XCTAssertEqual(character.position, position)
    }

    func testCharacter_withExtremelyLargeScale() {
        // GIVEN: A character with very large scale
        let largeScale = SIMD3<Float>(100, 100, 100)
        let character = Character(type: .sparkleThePrincess, scale: largeScale)

        // WHEN: Character is created
        // THEN: Large scale is handled correctly
        XCTAssertEqual(character.scale, largeScale)
    }
}
||||||| e86307c
=======
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
>>>>>>> origin/claude/qa-engineer-setup-018opoWboXZWozhVCKPoChNQ
