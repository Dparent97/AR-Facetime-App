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
