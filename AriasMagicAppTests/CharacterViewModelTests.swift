//
//  CharacterViewModelTests.swift
//  AriasMagicAppTests
//
//  Comprehensive unit tests for CharacterViewModel state management
//

import XCTest
import Combine
import RealityKit
@testable import AriasMagicApp

final class CharacterViewModelTests: XCTestCase {

    var sut: CharacterViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = CharacterViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_CreatesDefaultCharacter() {
        // Then
        XCTAssertCount(sut.characters, 1, "Should initialize with one default character")
        XCTAssertEqual(sut.selectedCharacterType, .sparkleThePrincess,
                      "Default character type should be Sparkle the Princess")
    }

    func testInitialization_DefaultCharacterPosition() {
        // Then
        let defaultCharacter = sut.characters.first
        XCTAssertNotNil(defaultCharacter, "Default character should exist")
        XCTAssertEqual(defaultCharacter?.position, [0, 0, -0.5],
                      "Default character should be at position [0, 0, -0.5]")
    }

    func testInitialization_ActiveEffectIsNil() {
        // Then
        XCTAssertNil(sut.activeEffect, "Active effect should be nil on initialization")
    }

    // MARK: - Character Spawning Tests

    func testSpawnCharacter_AddsNewCharacter() {
        // Given
        let initialCount = sut.characters.count
        let position: SIMD3<Float> = [1.0, 0.5, -2.0]

        // When
        sut.spawnCharacter(at: position)

        // Then
        XCTAssertCount(sut.characters, initialCount + 1,
                      "Should add one character to the array")
    }

    func testSpawnCharacter_UsesSelectedCharacterType() {
        // Given
        sut.selectedCharacterType = .lunaTheStarDancer

        // When
        sut.spawnCharacter(at: [0, 0, -1])

        // Then
        let newCharacter = sut.characters.last
        XCTAssertEqual(newCharacter?.type, .lunaTheStarDancer,
                      "New character should use selected character type")
    }

    func testSpawnCharacter_PositionIsSetCorrectly() {
        // Given
        let position: SIMD3<Float> = [2.5, 1.0, -3.0]

        // When
        sut.spawnCharacter(at: position)

        // Then
        let newCharacter = sut.characters.last
        XCTAssertEqual(newCharacter?.position, position,
                      "Character should be spawned at specified position")
    }

    func testSpawnCharacter_MultipleCharacters() {
        // Given
        let positions: [SIMD3<Float>] = [
            [1.0, 0, -1.0],
            [2.0, 0, -2.0],
            [3.0, 0, -3.0]
        ]

        // When
        for position in positions {
            sut.spawnCharacter(at: position)
        }

        // Then
        XCTAssertCount(sut.characters, 1 + positions.count,
                      "Should spawn multiple characters")
    }

    func testSpawnCharacter_TriggersPublishedUpdate() {
        // Given
        let expectation = expectation(description: "Characters array updated")
        var updateCount = 0

        sut.$characters
            .dropFirst() // Skip initial value
            .sink { _ in
                updateCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.spawnCharacter(at: [0, 0, -1])

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(updateCount, 1, "Should trigger one published update")
    }

    // MARK: - Character Removal Tests

    func testRemoveCharacter_RemovesSpecificCharacter() {
        // Given
        sut.spawnCharacter(at: [1, 0, -1])
        sut.spawnCharacter(at: [2, 0, -2])
        let characterToRemove = sut.characters[1]
        let initialCount = sut.characters.count

        // When
        sut.removeCharacter(characterToRemove)

        // Then
        XCTAssertCount(sut.characters, initialCount - 1,
                      "Should remove one character")
        XCTAssertFalse(sut.characters.contains { $0.id == characterToRemove.id },
                      "Removed character should not exist in array")
    }

    func testRemoveCharacter_OnlyRemovesTargetCharacter() {
        // Given
        let character1 = sut.characters.first!
        sut.spawnCharacter(at: [1, 0, -1])
        let character2 = sut.characters.last!

        // When
        sut.removeCharacter(character2)

        // Then
        XCTAssertTrue(sut.characters.contains { $0.id == character1.id },
                     "Other characters should remain")
        XCTAssertFalse(sut.characters.contains { $0.id == character2.id },
                      "Target character should be removed")
    }

    func testRemoveCharacter_NonExistentCharacter_DoesNotCrash() {
        // Given
        let nonExistentCharacter = Character(type: .rosieTheDreamWeaver, position: [0, 0, -1])
        let initialCount = sut.characters.count

        // When
        sut.removeCharacter(nonExistentCharacter)

        // Then
        XCTAssertCount(sut.characters, initialCount,
                      "Count should remain unchanged for non-existent character")
    }

    func testRemoveCharacter_TriggersPublishedUpdate() {
        // Given
        sut.spawnCharacter(at: [1, 0, -1])
        let characterToRemove = sut.characters.last!

        let expectation = expectation(description: "Characters array updated")
        sut.$characters
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.removeCharacter(characterToRemove)

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Character Action Tests

    func testPerformAction_OnSpecificCharacter() {
        // Given
        sut.spawnCharacter(at: [1, 0, -1])
        let targetCharacter = sut.characters.last!
        let action = CharacterAction.wave

        // When
        sut.performAction(action, on: targetCharacter)

        // Then
        XCTAssertEqual(targetCharacter.currentAction, action,
                      "Character should perform the specified action")
    }

    func testPerformAction_OnAllCharacters_WhenNoTargetSpecified() {
        // Given
        sut.spawnCharacter(at: [1, 0, -1])
        sut.spawnCharacter(at: [2, 0, -2])
        let action = CharacterAction.dance

        // When
        sut.performAction(action, on: nil)

        // Then
        for character in sut.characters {
            XCTAssertEqual(character.currentAction, action,
                          "All characters should perform the action")
        }
    }

    func testPerformAction_AllActionTypes() {
        // Given
        let character = sut.characters.first!
        let actions: [CharacterAction] = [.idle, .wave, .dance, .twirl, .jump, .sparkle]

        // When & Then
        for action in actions {
            sut.performAction(action, on: character)
            XCTAssertEqual(character.currentAction, action,
                          "Character should perform \(action)")
        }
    }

    func testPerformAction_OnMultipleCharactersIndependently() {
        // Given
        sut.spawnCharacter(at: [1, 0, -1])
        let character1 = sut.characters[0]
        let character2 = sut.characters[1]

        // When
        sut.performAction(.wave, on: character1)
        sut.performAction(.dance, on: character2)

        // Then
        XCTAssertEqual(character1.currentAction, .wave)
        XCTAssertEqual(character2.currentAction, .dance)
    }

    // MARK: - Effect Trigger Tests

    func testTriggerEffect_SetsActiveEffect() {
        // Given
        let effect = MagicEffect.sparkles

        // When
        sut.triggerEffect(effect)

        // Then
        XCTAssertEqual(sut.activeEffect, effect,
                      "Active effect should be set")
    }

    func testTriggerEffect_TriggersPublishedUpdate() {
        // Given
        let expectation = expectation(description: "Active effect updated")
        sut.$activeEffect
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.triggerEffect(.sparkles)

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testTriggerEffect_AutoDismissesAfter3Seconds() {
        // Given
        let expectation = expectation(description: "Effect auto-dismissed")
        sut.triggerEffect(.sparkles)
        XCTAssertNotNil(sut.activeEffect, "Effect should be active initially")

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 4.0)
        XCTAssertNil(sut.activeEffect,
                    "Effect should be auto-dismissed after 3 seconds")
    }

    func testTriggerEffect_MultipleEffects_LastOneWins() {
        // Given & When
        sut.triggerEffect(.sparkles)
        sut.triggerEffect(.snow)
        sut.triggerEffect(.bubbles)

        // Then
        XCTAssertEqual(sut.activeEffect, .bubbles,
                      "Last triggered effect should be active")
    }

    func testTriggerEffect_AllEffectTypes() {
        // Given
        let effects: [MagicEffect] = [.sparkles, .snow, .bubbles]

        // When & Then
        for effect in effects {
            sut.triggerEffect(effect)
            XCTAssertEqual(sut.activeEffect, effect,
                          "Should trigger \(effect)")
        }
    }

    func testTriggerEffect_RapidTriggering_OnlyLastEffectRemains() {
        // Given
        let expectation = expectation(description: "Final effect check")

        // When
        sut.triggerEffect(.sparkles)
        sut.triggerEffect(.snow)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.triggerEffect(.bubbles)
        }

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.sut.activeEffect, .bubbles)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Face Expression Handling Tests

    func testHandleFaceExpression_SmileTriggersSparkles() {
        // When
        sut.handleFaceExpression(.smile)

        // Then
        XCTAssertEqual(sut.activeEffect, .sparkles,
                      "Smile should trigger sparkles effect")
    }

    func testHandleFaceExpression_EyebrowsRaisedTriggersWave() {
        // Given
        let character = sut.characters.first!

        // When
        sut.handleFaceExpression(.eyebrowsRaised)

        // Then
        XCTAssertEqual(character.currentAction, .wave,
                      "Eyebrows raised should trigger wave action")
    }

    func testHandleFaceExpression_MouthOpenTriggersJump() {
        // Given
        let character = sut.characters.first!

        // When
        sut.handleFaceExpression(.mouthOpen)

        // Then
        XCTAssertEqual(character.currentAction, .jump,
                      "Mouth open should trigger jump action")
    }

    func testHandleFaceExpression_AllExpressions() {
        // Given
        let expressions: [(FaceExpression, CharacterAction?, MagicEffect?)] = [
            (.smile, nil, .sparkles),
            (.eyebrowsRaised, .wave, nil),
            (.mouthOpen, .jump, nil)
        ]

        // When & Then
        for (expression, expectedAction, expectedEffect) in expressions {
            sut.handleFaceExpression(expression)

            if let expectedAction = expectedAction {
                let character = sut.characters.first!
                XCTAssertEqual(character.currentAction, expectedAction,
                              "\(expression) should trigger \(expectedAction)")
            }

            if let expectedEffect = expectedEffect {
                XCTAssertEqual(sut.activeEffect, expectedEffect,
                              "\(expression) should trigger \(expectedEffect)")
            }
        }
    }

    // MARK: - Selected Character Type Tests

    func testSelectedCharacterType_ChangesAffectNewCharacters() {
        // Given
        let characterTypes: [CharacterType] = [
            .lunaTheStarDancer,
            .rosieTheDreamWeaver,
            .crystalTheGemKeeper,
            .willowTheWishMaker
        ]

        // When & Then
        for characterType in characterTypes {
            sut.selectedCharacterType = characterType
            sut.spawnCharacter(at: [0, 0, -1])

            let lastCharacter = sut.characters.last!
            XCTAssertEqual(lastCharacter.type, characterType,
                          "Newly spawned character should be of selected type")
        }
    }

    func testSelectedCharacterType_DoesNotAffectExistingCharacters() {
        // Given
        sut.selectedCharacterType = .sparkleThePrincess
        sut.spawnCharacter(at: [0, 0, -1])
        let character = sut.characters.last!

        // When
        sut.selectedCharacterType = .lunaTheStarDancer

        // Then
        XCTAssertEqual(character.type, .sparkleThePrincess,
                      "Existing characters should not change type")
    }

    func testSelectedCharacterType_TriggersPublishedUpdate() {
        // Given
        let expectation = expectation(description: "Selected type updated")
        sut.$selectedCharacterType
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.selectedCharacterType = .lunaTheStarDancer

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - State Management Tests

    func testStateManagement_MultipleOperations() {
        // Given - Complex sequence of operations
        sut.selectedCharacterType = .lunaTheStarDancer

        // When
        sut.spawnCharacter(at: [1, 0, -1])
        sut.spawnCharacter(at: [2, 0, -2])
        sut.performAction(.dance, on: nil)
        sut.triggerEffect(.sparkles)

        let characterToRemove = sut.characters[1]
        sut.removeCharacter(characterToRemove)

        // Then
        XCTAssertCount(sut.characters, 2, "Should have 2 characters after operations")
        XCTAssertEqual(sut.activeEffect, .sparkles, "Effect should be active")

        for character in sut.characters {
            XCTAssertEqual(character.currentAction, .dance,
                          "All remaining characters should be dancing")
        }
    }

    func testStateManagement_ConcurrentOperations() {
        // Given
        let expectation = expectation(description: "Concurrent operations completed")
        expectation.expectedFulfillmentCount = 3

        // When - Perform operations concurrently
        DispatchQueue.global(qos: .userInitiated).async {
            self.sut.spawnCharacter(at: [1, 0, -1])
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.sut.triggerEffect(.snow)
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.sut.performAction(.wave, on: nil)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)
        // Should handle concurrent operations without crashes
    }

    // MARK: - Memory and Performance Tests

    func testMemoryManagement_CharacterRemoval() {
        // Given
        weak var weakCharacter: Character?

        autoreleasepool {
            sut.spawnCharacter(at: [1, 0, -1])
            let character = sut.characters.last!
            weakCharacter = character
            sut.removeCharacter(character)
        }

        // Then
        // Wait for deallocation
        waitForAsync {
            XCTAssertNil(weakCharacter, "Removed character should be deallocated")
        }
    }

    func testPerformance_SpawningMultipleCharacters() {
        measure {
            for i in 0..<100 {
                let position: SIMD3<Float> = [Float(i), 0, Float(-i)]
                sut.spawnCharacter(at: position)
            }

            // Clean up
            sut.characters.removeAll()
        }
    }

    func testPerformance_PerformingActionsOnAllCharacters() {
        // Given
        for i in 0..<20 {
            sut.spawnCharacter(at: [Float(i), 0, -1])
        }

        // When
        measure {
            sut.performAction(.dance, on: nil)
        }
    }

    // MARK: - Edge Cases

    func testEdgeCase_RemovingAllCharacters() {
        // Given
        sut.spawnCharacter(at: [1, 0, -1])
        sut.spawnCharacter(at: [2, 0, -2])

        // When
        let allCharacters = sut.characters
        for character in allCharacters {
            sut.removeCharacter(character)
        }

        // Then
        XCTAssertEmpty(sut.characters, "All characters should be removed")
    }

    func testEdgeCase_EffectAutoDismiss_WithNewEffect() {
        // Given
        sut.triggerEffect(.sparkles)

        // When - Trigger new effect before first one auto-dismisses
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.sut.triggerEffect(.snow)
        }

        let expectation = expectation(description: "Check final state")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 5.0)
        // Snow effect should have auto-dismissed by now
        XCTAssertNil(sut.activeEffect,
                    "Second effect should also auto-dismiss")
    }

    func testEdgeCase_VeryLargeCharacterCount() {
        // When
        for i in 0..<1000 {
            sut.spawnCharacter(at: [Float(i % 10), 0, Float(-(i % 10))])
        }

        // Then
        XCTAssertCount(sut.characters, 1001, "Should handle large character count")
    }
}
