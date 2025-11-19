<<<<<<< HEAD
//
//  CharacterViewModelTests.swift
//  Aria's Magic SharePlay App - Tests
//
//  Unit tests for CharacterViewModel
//

import XCTest
import Combine
import RealityKit
@testable import AriasMagicApp

class CharacterViewModelTests: XCTestCase {
    var viewModel: CharacterViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = CharacterViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // GIVEN: CharacterViewModel
        // WHEN: ViewModel is initialized
        let viewModel = CharacterViewModel()

        // THEN: ViewModel is created with initial state
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.characters.count, 1) // Starts with one default character
        XCTAssertEqual(viewModel.selectedCharacterType, .sparkleThePrincess)
        XCTAssertNil(viewModel.activeEffect)
    }

    func testInitialization_createsDefaultCharacter() {
        // GIVEN: New ViewModel
        let viewModel = CharacterViewModel()

        // WHEN: Checking initial characters
        // THEN: One character is created by default
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertNotNil(viewModel.characters.first)
    }

    func testInitialization_defaultCharacterType() {
        // GIVEN: New ViewModel
        let viewModel = CharacterViewModel()

        // WHEN: Checking selected character type
        // THEN: Default is Sparkle
        XCTAssertEqual(viewModel.selectedCharacterType, .sparkleThePrincess)
    }

    // MARK: - Spawn Character Tests

    func testSpawnCharacter_addsCharacter() {
        // GIVEN: ViewModel with one character
        let initialCount = viewModel.characters.count

        // WHEN: Spawning a character
        viewModel.spawnCharacter(at: TestData.testPosition)

        // THEN: Character is added
        XCTAssertEqual(viewModel.characters.count, initialCount + 1)
    }

    func testSpawnCharacter_usesSelectedType() {
        // GIVEN: ViewModel with selected type
        viewModel.selectedCharacterType = .lunaTheStarDancer

        // WHEN: Spawning a character
        viewModel.spawnCharacter(at: TestData.testPosition)

        // THEN: New character has selected type
        let lastCharacter = viewModel.characters.last
        XCTAssertEqual(lastCharacter?.type, .lunaTheStarDancer)
    }

    func testSpawnCharacter_atSpecificPosition() {
        // GIVEN: ViewModel and specific position
        let position = SIMD3<Float>(1.0, 0.5, -2.0)

        // WHEN: Spawning character at position
        viewModel.spawnCharacter(at: position)

        // THEN: Character is at specified position
        let lastCharacter = viewModel.characters.last
        XCTAssertEqual(lastCharacter?.position, position)
    }

    func testSpawnCharacter_multipleCharacters() {
        // GIVEN: ViewModel
        let initialCount = viewModel.characters.count

        // WHEN: Spawning multiple characters
        for i in 0..<5 {
            let position = SIMD3<Float>(Float(i), 0, -1)
            viewModel.spawnCharacter(at: position)
        }

        // THEN: All characters are added
        XCTAssertEqual(viewModel.characters.count, initialCount + 5)
    }

    func testSpawnCharacter_differentTypes() {
        // GIVEN: ViewModel
        let types: [CharacterType] = [.sparkleThePrincess, .lunaTheStarDancer, .rosieTheDreamWeaver]

        // WHEN: Spawning characters of different types
        for type in types {
            viewModel.selectedCharacterType = type
            viewModel.spawnCharacter(at: TestData.testPosition)
        }

        // THEN: Characters have correct types
        let spawnedTypes = viewModel.characters.suffix(types.count).map { $0.type }
        XCTAssertEqual(Set(spawnedTypes), Set(types))
    }

    // MARK: - Remove Character Tests

    func testRemoveCharacter_removesSpecificCharacter() {
        // GIVEN: ViewModel with multiple characters
        viewModel.spawnCharacter(at: TestData.testPosition)
        viewModel.spawnCharacter(at: TestData.testPositionNear)
        let characterToRemove = viewModel.characters[1]
        let initialCount = viewModel.characters.count

        // WHEN: Removing a specific character
        viewModel.removeCharacter(characterToRemove)

        // THEN: Character is removed
        XCTAssertEqual(viewModel.characters.count, initialCount - 1)
        XCTAssertFalse(viewModel.characters.contains { $0.id == characterToRemove.id })
    }

    func testRemoveCharacter_byID() {
        // GIVEN: ViewModel with characters
        viewModel.spawnCharacter(at: TestData.testPosition)
        let characterToRemove = viewModel.characters.last!
        let characterID = characterToRemove.id

        // WHEN: Removing character
        viewModel.removeCharacter(characterToRemove)

        // THEN: Character with matching ID is removed
        XCTAssertFalse(viewModel.characters.contains { $0.id == characterID })
    }

    func testRemoveCharacter_doesNotAffectOthers() {
        // GIVEN: ViewModel with 3 characters
        let char1 = viewModel.characters[0]
        viewModel.spawnCharacter(at: TestData.testPosition)
        let char2 = viewModel.characters[1]
        viewModel.spawnCharacter(at: TestData.testPositionNear)
        let char3 = viewModel.characters[2]

        // WHEN: Removing middle character
        viewModel.removeCharacter(char2)

        // THEN: Other characters remain
        XCTAssertTrue(viewModel.characters.contains { $0.id == char1.id })
        XCTAssertTrue(viewModel.characters.contains { $0.id == char3.id })
        XCTAssertEqual(viewModel.characters.count, 2)
    }

    func testRemoveCharacter_nonexistentCharacter() {
        // GIVEN: ViewModel and a character not in the list
        let externalCharacter = Character(type: .sparkleThePrincess)
        let initialCount = viewModel.characters.count

        // WHEN: Attempting to remove nonexistent character
        viewModel.removeCharacter(externalCharacter)

        // THEN: Character count unchanged
        XCTAssertEqual(viewModel.characters.count, initialCount)
    }

    // MARK: - Perform Action Tests

    func testPerformAction_onAllCharacters() {
        // GIVEN: ViewModel with multiple characters
        viewModel.spawnCharacter(at: TestData.testPosition)
        viewModel.spawnCharacter(at: TestData.testPositionNear)

        // WHEN: Performing action on all characters
        viewModel.performAction(.wave)

        // THEN: All characters have the action
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .wave)
        }
    }

    func testPerformAction_onSpecificCharacter() {
        // GIVEN: ViewModel with multiple characters
        viewModel.spawnCharacter(at: TestData.testPosition)
        let targetCharacter = viewModel.characters[0]
        let otherCharacter = viewModel.characters.last!

        // WHEN: Performing action on specific character
        viewModel.performAction(.dance, on: targetCharacter)

        // THEN: Only target character has the action
        XCTAssertEqual(targetCharacter.currentAction, .dance)

        // Wait a moment to ensure other character isn't affected
        let expectation = expectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testPerformAction_allActionTypes() {
        // GIVEN: ViewModel with character
        // WHEN: Performing each action type
        for action in TestData.allCharacterActions {
            viewModel.performAction(action)

            // THEN: Action is set correctly
            for character in viewModel.characters {
                XCTAssertEqual(character.currentAction, action)
            }
        }
    }

    func testPerformAction_withNilCharacter_affectsAll() {
        // GIVEN: ViewModel with multiple characters
        viewModel.spawnCharacter(at: TestData.testPosition)
        viewModel.spawnCharacter(at: TestData.testPositionNear)

        // WHEN: Performing action with nil character parameter
        viewModel.performAction(.jump, on: nil)

        // THEN: All characters perform the action
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .jump)
        }
    }

    // MARK: - Trigger Effect Tests

    func testTriggerEffect_setsActiveEffect() {
        // GIVEN: ViewModel with no active effect
        XCTAssertNil(viewModel.activeEffect)

        // WHEN: Triggering an effect
        viewModel.triggerEffect(.sparkles)

        // THEN: Active effect is set
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
    }

    func testTriggerEffect_allEffectTypes() {
        // GIVEN: ViewModel
        // WHEN: Triggering each effect type
        for effect in TestData.allMagicEffects {
            viewModel.triggerEffect(effect)

            // THEN: Active effect is set
            XCTAssertEqual(viewModel.activeEffect, effect)

            // Clear for next test
            viewModel.activeEffect = nil
        }
    }

    func testTriggerEffect_autoDismissesAfterDelay() {
        // GIVEN: ViewModel
        // WHEN: Triggering an effect
        viewModel.triggerEffect(.snow)

        XCTAssertEqual(viewModel.activeEffect, .snow)

        // THEN: Effect is cleared after 3 seconds
        let expectation = expectation(description: "Effect auto-dismisses")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            XCTAssertNil(self.viewModel.activeEffect)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 4.0)
    }

    func testTriggerEffect_replacesCurrentEffect() {
        // GIVEN: ViewModel with active effect
        viewModel.triggerEffect(.sparkles)
        XCTAssertEqual(viewModel.activeEffect, .sparkles)

        // WHEN: Triggering a different effect
        viewModel.triggerEffect(.bubbles)

        // THEN: New effect replaces the old one
        XCTAssertEqual(viewModel.activeEffect, .bubbles)
    }

    func testTriggerEffect_sameEffectMultipleTimes() {
        // GIVEN: ViewModel
        // WHEN: Triggering same effect multiple times
        viewModel.triggerEffect(.sparkles)
        viewModel.triggerEffect(.sparkles)
        viewModel.triggerEffect(.sparkles)

        // THEN: Effect is still active
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
    }

    // MARK: - Handle Face Expression Tests

    func testHandleFaceExpression_smile_triggersSparkles() {
        // GIVEN: ViewModel
        // WHEN: Handling smile expression
        viewModel.handleFaceExpression(.smile)

        // THEN: Sparkles effect is triggered
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
    }

    func testHandleFaceExpression_eyebrowsRaised_triggersWave() {
        // GIVEN: ViewModel with characters
        // WHEN: Handling eyebrows raised expression
        viewModel.handleFaceExpression(.eyebrowsRaised)

        // THEN: Characters wave
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .wave)
        }
    }

    func testHandleFaceExpression_mouthOpen_triggersJump() {
        // GIVEN: ViewModel with characters
        // WHEN: Handling mouth open expression
        viewModel.handleFaceExpression(.mouthOpen)

        // THEN: Characters jump
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .jump)
        }
    }

    func testHandleFaceExpression_allExpressions() {
        // GIVEN: ViewModel
        let expressions: [(FaceExpression, MagicEffect?, CharacterAction?)] = [
            (.smile, .sparkles, nil),
            (.eyebrowsRaised, nil, .wave),
            (.mouthOpen, nil, .jump)
        ]

        // WHEN: Handling each expression
        for (expression, expectedEffect, expectedAction) in expressions {
            viewModel.activeEffect = nil // Reset

            viewModel.handleFaceExpression(expression)

            // THEN: Correct effect or action is triggered
            if let expectedEffect = expectedEffect {
                XCTAssertEqual(viewModel.activeEffect, expectedEffect)
            }

            if let expectedAction = expectedAction {
                for character in viewModel.characters {
                    XCTAssertEqual(character.currentAction, expectedAction)
                }
            }
        }
    }

    // MARK: - Observable Tests

    func testViewModel_isObservableObject() {
        // GIVEN: CharacterViewModel
        // WHEN: ViewModel is ObservableObject
        // THEN: ObjectWillChange publisher exists
        XCTAssertNotNil(viewModel.objectWillChange)
    }

    func testViewModel_publishedCharacters() {
        // GIVEN: ViewModel with expectation
        let expectation = expectation(description: "Characters published")
        var updateCount = 0

        viewModel.$characters
            .dropFirst() // Skip initial value
            .sink { _ in
                updateCount += 1
                if updateCount >= 1 {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)

        // WHEN: Spawning a character
        viewModel.spawnCharacter(at: TestData.testPosition)

        // THEN: Published value triggers update
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(updateCount, 0)
    }

    func testViewModel_publishedSelectedCharacterType() {
        // GIVEN: ViewModel with expectation
        let expectation = expectation(description: "SelectedCharacterType published")
        var valueChanged = false

        viewModel.$selectedCharacterType
            .dropFirst()
            .sink { value in
                if value == .lunaTheStarDancer {
                    valueChanged = true
                    expectation.fulfill()
                }
            }.store(in: &cancellables)

        // WHEN: Changing selected type
        viewModel.selectedCharacterType = .lunaTheStarDancer

        // THEN: Published value triggers update
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(valueChanged)
    }

    func testViewModel_publishedActiveEffect() {
        // GIVEN: ViewModel with expectation
        let expectation = expectation(description: "ActiveEffect published")
        var effectSet = false

        viewModel.$activeEffect
            .dropFirst()
            .sink { value in
                if value == .sparkles {
                    effectSet = true
                    expectation.fulfill()
                }
            }.store(in: &cancellables)

        // WHEN: Triggering effect
        viewModel.triggerEffect(.sparkles)

        // THEN: Published value triggers update
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(effectSet)
    }

    // MARK: - Integration Tests

    func testCompleteWorkflow_spawnPerformRemove() {
        // GIVEN: ViewModel
        let initialCount = viewModel.characters.count

        // WHEN: Spawning character
        viewModel.spawnCharacter(at: TestData.testPosition)
        XCTAssertEqual(viewModel.characters.count, initialCount + 1)

        // AND: Performing action
        let character = viewModel.characters.last!
        viewModel.performAction(.dance, on: character)
        XCTAssertEqual(character.currentAction, .dance)

        // AND: Removing character
        viewModel.removeCharacter(character)
        XCTAssertEqual(viewModel.characters.count, initialCount)
    }

    func testMultipleCharactersWithEffects() {
        // GIVEN: ViewModel with multiple characters
        for _ in 0..<5 {
            viewModel.spawnCharacter(at: TestData.testPosition)
        }

        // WHEN: Performing actions and triggering effects
        viewModel.performAction(.wave)
        viewModel.triggerEffect(.sparkles)

        // THEN: All characters perform action and effect is active
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .wave)
        }
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
    }

    // MARK: - Edge Cases

    func testRemoveAllCharacters() {
        // GIVEN: ViewModel with characters
        viewModel.spawnCharacter(at: TestData.testPosition)
        let characters = Array(viewModel.characters)

        // WHEN: Removing all characters
        for character in characters {
            viewModel.removeCharacter(character)
        }

        // THEN: No characters remain
        XCTAssertEqual(viewModel.characters.count, 0)
    }

    func testPerformAction_withNoCharacters() {
        // GIVEN: ViewModel with no characters
        for character in viewModel.characters {
            viewModel.removeCharacter(character)
        }
        XCTAssertEqual(viewModel.characters.count, 0)

        // WHEN: Performing action
        viewModel.performAction(.wave)

        // THEN: No crash occurs
        XCTAssertEqual(viewModel.characters.count, 0)
    }

    func testSpawnCharacter_manyCharacters() {
        // GIVEN: ViewModel
        // WHEN: Spawning many characters
        for i in 0..<100 {
            let position = SIMD3<Float>(Float(i % 10), 0, Float(i / 10))
            viewModel.spawnCharacter(at: position)
        }

        // THEN: All characters are added
        XCTAssertGreaterThanOrEqual(viewModel.characters.count, 100)
    }

    // MARK: - Performance Tests

    func testSpawnCharacter_performance() {
        // WHEN: Measuring spawn performance
        measure {
            for i in 0..<100 {
                let position = SIMD3<Float>(Float(i), 0, -1)
                viewModel.spawnCharacter(at: position)
            }

            // Clean up
            for character in viewModel.characters {
                viewModel.removeCharacter(character)
            }
        }

        // THEN: Performance is measured
    }

    func testPerformAction_performance() {
        // GIVEN: ViewModel with characters
        for _ in 0..<50 {
            viewModel.spawnCharacter(at: TestData.testPosition)
        }

        // WHEN: Measuring action performance
        measure {
            for action in TestData.allCharacterActions {
                viewModel.performAction(action)
            }
        }

        // THEN: Performance is measured
    }
}
||||||| e86307c
=======
//
//  CharacterViewModelTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Unit tests for CharacterViewModel
//

import XCTest
import Combine
import RealityKit
@testable import AriasMagicApp

class CharacterViewModelTests: XCTestCase {

    var viewModel: CharacterViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = CharacterViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testViewModelInitialization() {
        // GIVEN/WHEN: Creating view model
        let viewModel = CharacterViewModel()

        // THEN: View model initializes with default state
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.characters.count, 1) // Starts with one character
        XCTAssertEqual(viewModel.selectedCharacterType, .sparkleThePrincess)
        XCTAssertNil(viewModel.activeEffect)
    }

    func testViewModelInitialization_spawnsDefaultCharacter() {
        // GIVEN/WHEN: Creating view model
        let viewModel = CharacterViewModel()

        // THEN: One character is spawned at initialization
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.characters[0].type, .sparkleThePrincess)
    }

    // MARK: - Spawn Character Tests

    func testSpawnCharacter_addsCharacterToArray() {
        // GIVEN: View model with initial character
        let initialCount = viewModel.characters.count

        // WHEN: Spawning a character
        viewModel.spawnCharacter(at: SIMD3<Float>(1, 0, -1))

        // THEN: Character count increases
        XCTAssertEqual(viewModel.characters.count, initialCount + 1)
    }

    func testSpawnCharacter_usesSelectedType() {
        // GIVEN: View model with selected character type
        viewModel.selectedCharacterType = .lunaTheStarDancer

        // WHEN: Spawning a character
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))

        // THEN: Spawned character has selected type
        let lastCharacter = viewModel.characters.last
        XCTAssertEqual(lastCharacter?.type, .lunaTheStarDancer)
    }

    func testSpawnCharacter_atSpecificPosition() {
        // GIVEN: View model and position
        let position = SIMD3<Float>(2.5, 1.0, -3.0)

        // WHEN: Spawning character at position
        viewModel.spawnCharacter(at: position)

        // THEN: Character has correct position
        let lastCharacter = viewModel.characters.last
        TestHelpers.assertSIMD3Equal(lastCharacter!.position, position)
    }

    func testSpawnCharacter_multipleCharacters() {
        // GIVEN: View model
        let initialCount = viewModel.characters.count

        // WHEN: Spawning multiple characters
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        viewModel.spawnCharacter(at: SIMD3<Float>(1, 0, -1))
        viewModel.spawnCharacter(at: SIMD3<Float>(2, 0, -1))

        // THEN: All characters are added
        XCTAssertEqual(viewModel.characters.count, initialCount + 3)
    }

    // MARK: - Remove Character Tests

    func testRemoveCharacter_removesFromArray() {
        // GIVEN: View model with multiple characters
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        viewModel.spawnCharacter(at: SIMD3<Float>(1, 0, -1))
        let characterToRemove = viewModel.characters[1]
        let initialCount = viewModel.characters.count

        // WHEN: Removing a character
        viewModel.removeCharacter(characterToRemove)

        // THEN: Character count decreases
        XCTAssertEqual(viewModel.characters.count, initialCount - 1)
    }

    func testRemoveCharacter_removesCorrectCharacter() {
        // GIVEN: View model with multiple characters
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        let characterToRemove = viewModel.characters[1]
        let characterToKeep = viewModel.characters[0]

        // WHEN: Removing specific character
        viewModel.removeCharacter(characterToRemove)

        // THEN: Correct character is removed
        XCTAssertFalse(viewModel.characters.contains(where: { $0.id == characterToRemove.id }))
        XCTAssertTrue(viewModel.characters.contains(where: { $0.id == characterToKeep.id }))
    }

    func testRemoveCharacter_removingNonexistentCharacter() {
        // GIVEN: View model with characters
        let initialCount = viewModel.characters.count
        let externalCharacter = Character(type: .rosieTheDreamWeaver)

        // WHEN: Removing non-existent character
        viewModel.removeCharacter(externalCharacter)

        // THEN: No change to character count
        XCTAssertEqual(viewModel.characters.count, initialCount)
    }

    // MARK: - Perform Action Tests

    func testPerformAction_onSpecificCharacter() {
        // GIVEN: View model with a character
        let character = viewModel.characters[0]

        // WHEN: Performing action on specific character
        viewModel.performAction(.wave, on: character)

        // THEN: Character action is updated
        XCTAssertEqual(character.currentAction, .wave)
    }

    func testPerformAction_onAllCharacters() {
        // GIVEN: View model with multiple characters
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        viewModel.spawnCharacter(at: SIMD3<Float>(1, 0, -1))

        // WHEN: Performing action on all characters (nil parameter)
        viewModel.performAction(.dance, on: nil)

        // THEN: All characters perform the action
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .dance)
        }
    }

    func testPerformAction_allActionTypes() {
        // GIVEN: View model with a character
        let character = viewModel.characters[0]
        let actions: [CharacterAction] = [.wave, .dance, .twirl, .jump, .sparkle]

        // WHEN: Performing each action
        for action in actions {
            viewModel.performAction(action, on: character)

            // THEN: Action is set correctly
            XCTAssertEqual(character.currentAction, action)
        }
    }

    func testPerformAction_withMultipleCharacters_onlyAffectsTarget() {
        // GIVEN: Multiple characters
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        let targetCharacter = viewModel.characters[0]
        let otherCharacter = viewModel.characters[1]

        // WHEN: Performing action on one character
        viewModel.performAction(.wave, on: targetCharacter)

        // THEN: Only target character performs action
        XCTAssertEqual(targetCharacter.currentAction, .wave)
        XCTAssertEqual(otherCharacter.currentAction, .idle)
    }

    // MARK: - Trigger Effect Tests

    func testTriggerEffect_setsActiveEffect() {
        // GIVEN: View model
        XCTAssertNil(viewModel.activeEffect)

        // WHEN: Triggering effect
        viewModel.triggerEffect(.sparkles)

        // THEN: Active effect is set
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
    }

    func testTriggerEffect_allEffectTypes() {
        // GIVEN: View model and all effects
        let effects = MagicEffect.allCases

        // WHEN: Triggering each effect
        for effect in effects {
            viewModel.triggerEffect(effect)

            // THEN: Effect is set correctly
            XCTAssertEqual(viewModel.activeEffect, effect)
        }
    }

    func testTriggerEffect_autoDismissesAfterDuration() {
        // GIVEN: View model
        let expectation = expectation(description: "Effect auto-dismisses")

        // WHEN: Triggering effect
        viewModel.triggerEffect(.bubbles)
        XCTAssertEqual(viewModel.activeEffect, .bubbles)

        // THEN: Effect is dismissed after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            XCTAssertNil(self.viewModel.activeEffect)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 4.0)
    }

    func testTriggerEffect_multipleEffects_lastOneWins() {
        // GIVEN: View model
        // WHEN: Triggering multiple effects quickly
        viewModel.triggerEffect(.sparkles)
        viewModel.triggerEffect(.snow)
        viewModel.triggerEffect(.bubbles)

        // THEN: Last effect is active
        XCTAssertEqual(viewModel.activeEffect, .bubbles)
    }

    // MARK: - Handle Face Expression Tests

    func testHandleFaceExpression_smile_triggersSparkles() {
        // GIVEN: View model
        XCTAssertNil(viewModel.activeEffect)

        // WHEN: Handling smile expression
        viewModel.handleFaceExpression(.smile)

        // THEN: Sparkles effect is triggered
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
    }

    func testHandleFaceExpression_eyebrowsRaised_performsWave() {
        // GIVEN: View model with characters
        // WHEN: Handling eyebrows raised expression
        viewModel.handleFaceExpression(.eyebrowsRaised)

        // THEN: Characters perform wave action
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .wave)
        }
    }

    func testHandleFaceExpression_mouthOpen_performsJump() {
        // GIVEN: View model with characters
        // WHEN: Handling mouth open expression
        viewModel.handleFaceExpression(.mouthOpen)

        // THEN: Characters perform jump action
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .jump)
        }
    }

    func testHandleFaceExpression_allExpressions() {
        // GIVEN: View model and all expressions
        let expressions: [(FaceExpression, MagicEffect?, CharacterAction?)] = [
            (.smile, .sparkles, nil),
            (.eyebrowsRaised, nil, .wave),
            (.mouthOpen, nil, .jump)
        ]

        // WHEN/THEN: Handling each expression
        for (expression, expectedEffect, expectedAction) in expressions {
            // Reset state
            viewModel = CharacterViewModel()

            viewModel.handleFaceExpression(expression)

            if let expectedEffect = expectedEffect {
                XCTAssertEqual(viewModel.activeEffect, expectedEffect)
            }

            if let expectedAction = expectedAction {
                for character in viewModel.characters {
                    XCTAssertEqual(character.currentAction, expectedAction)
                }
            }
        }
    }

    // MARK: - Selected Character Type Tests

    func testSelectedCharacterType_canBeChanged() {
        // GIVEN: View model with default type
        XCTAssertEqual(viewModel.selectedCharacterType, .sparkleThePrincess)

        // WHEN: Changing selected type
        viewModel.selectedCharacterType = .lunaTheStarDancer

        // THEN: Selected type is updated
        XCTAssertEqual(viewModel.selectedCharacterType, .lunaTheStarDancer)
    }

    func testSelectedCharacterType_affectsNextSpawn() {
        // GIVEN: View model with changed type
        viewModel.selectedCharacterType = .crystalTheGemKeeper

        // WHEN: Spawning new character
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))

        // THEN: New character has selected type
        let lastCharacter = viewModel.characters.last
        XCTAssertEqual(lastCharacter?.type, .crystalTheGemKeeper)
    }

    // MARK: - ObservableObject Tests

    func testViewModel_publishesCharactersChanges() {
        // GIVEN: View model with observer
        let expectation = expectation(description: "Characters change published")
        var publishedCount = 0

        viewModel.$characters
            .dropFirst() // Skip initial value
            .sink { characters in
                publishedCount = characters.count
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // WHEN: Spawning character
        DispatchQueue.main.async {
            self.viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(publishedCount, 1)
    }

    func testViewModel_publishesSelectedCharacterTypeChanges() {
        // GIVEN: View model with observer
        let expectation = expectation(description: "Selected type change published")
        var publishedType: CharacterType?

        viewModel.$selectedCharacterType
            .dropFirst() // Skip initial value
            .sink { type in
                publishedType = type
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // WHEN: Changing selected type
        DispatchQueue.main.async {
            self.viewModel.selectedCharacterType = .willowTheWishMaker
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedType, .willowTheWishMaker)
    }

    func testViewModel_publishesActiveEffectChanges() {
        // GIVEN: View model with observer
        let expectation = expectation(description: "Active effect change published")
        var publishedEffect: MagicEffect?

        viewModel.$activeEffect
            .dropFirst() // Skip initial value
            .sink { effect in
                publishedEffect = effect
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // WHEN: Triggering effect
        DispatchQueue.main.async {
            self.viewModel.triggerEffect(.snow)
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedEffect, .snow)
    }

    // MARK: - Integration Tests

    func testCompleteWorkflow_spawnMultipleCharactersAndPerformActions() {
        // GIVEN: View model
        viewModel = CharacterViewModel() // Fresh start

        // WHEN: Complete workflow
        viewModel.selectedCharacterType = .lunaTheStarDancer
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))

        viewModel.selectedCharacterType = .rosieTheDreamWeaver
        viewModel.spawnCharacter(at: SIMD3<Float>(1, 0, -1))

        viewModel.performAction(.dance, on: nil)
        viewModel.triggerEffect(.sparkles)

        // THEN: All operations succeed
        XCTAssertEqual(viewModel.characters.count, 3) // 1 initial + 2 spawned
        XCTAssertEqual(viewModel.activeEffect, .sparkles)
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .dance)
        }
    }

    func testFaceExpressionWorkflow_sequentialExpressions() {
        // GIVEN: View model
        // WHEN: Handling sequential expressions
        viewModel.handleFaceExpression(.smile)
        XCTAssertEqual(viewModel.activeEffect, .sparkles)

        viewModel.handleFaceExpression(.eyebrowsRaised)
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .wave)
        }

        viewModel.handleFaceExpression(.mouthOpen)
        for character in viewModel.characters {
            XCTAssertEqual(character.currentAction, .jump)
        }

        // THEN: All expressions handled correctly
        XCTAssertTrue(true)
    }

    // MARK: - Performance Tests

    func testPerformance_spawnManyCharacters() {
        // GIVEN: View model
        let viewModel = CharacterViewModel()

        // WHEN/THEN: Measuring spawn performance
        measure {
            for i in 0..<100 {
                viewModel.spawnCharacter(at: SIMD3<Float>(Float(i), 0, -1))
            }
        }
    }

    func testPerformance_performActionOnManyCharacters() {
        // GIVEN: View model with many characters
        for i in 0..<100 {
            viewModel.spawnCharacter(at: SIMD3<Float>(Float(i), 0, -1))
        }

        // WHEN/THEN: Measuring action performance
        measure {
            viewModel.performAction(.wave, on: nil)
        }
    }

    // MARK: - Memory Tests

    func testViewModel_canBeReleased() {
        // GIVEN: A weak reference to view model
        weak var weakViewModel: CharacterViewModel?

        autoreleasepool {
            let viewModel = CharacterViewModel()
            weakViewModel = viewModel
            XCTAssertNotNil(weakViewModel)
        }

        // WHEN: View model goes out of scope
        // THEN: It can be deallocated
        XCTAssertNil(weakViewModel)
    }

    func testCharactersArray_doesNotRetainCycles() {
        // GIVEN: View model with multiple characters
        weak var weakCharacter: Character?

        autoreleasepool {
            let viewModel = CharacterViewModel()
            viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
            weakCharacter = viewModel.characters.last
            XCTAssertNotNil(weakCharacter)

            // Remove character from array
            if let character = viewModel.characters.last {
                viewModel.removeCharacter(character)
            }
        }

        // WHEN: Character is removed and out of scope
        // THEN: It can be deallocated (no retain cycle)
        XCTAssertNil(weakCharacter)
    }

    // MARK: - Edge Case Tests

    func testRemoveAllCharacters() {
        // GIVEN: View model with multiple characters
        viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
        viewModel.spawnCharacter(at: SIMD3<Float>(1, 0, -1))

        // WHEN: Removing all characters
        let allCharacters = viewModel.characters
        for character in allCharacters {
            viewModel.removeCharacter(character)
        }

        // THEN: Characters array is empty
        XCTAssertTrue(viewModel.characters.isEmpty)
    }

    func testPerformAction_onEmptyCharactersArray() {
        // GIVEN: View model with no characters
        let allCharacters = viewModel.characters
        for character in allCharacters {
            viewModel.removeCharacter(character)
        }

        // WHEN: Performing action on nil (all characters)
        viewModel.performAction(.wave, on: nil)

        // THEN: No crash occurs
        XCTAssertTrue(viewModel.characters.isEmpty)
    }
}
>>>>>>> origin/claude/qa-engineer-setup-018opoWboXZWozhVCKPoChNQ
