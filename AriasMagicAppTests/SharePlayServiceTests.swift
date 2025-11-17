//
//  SharePlayServiceTests.swift
//  AriasMagicAppTests
//
//  Comprehensive unit tests for SharePlayService and message serialization
//

import XCTest
import GroupActivities
import Combine
@testable import AriasMagicApp

final class SharePlayServiceTests: XCTestCase {

    var sut: SharePlayService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = SharePlayService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(sut, "SharePlayService should initialize")
        XCTAssertFalse(sut.isActive, "Service should not be active on initialization")
        XCTAssertEmpty(sut.participants, "Participants array should be empty on initialization")
    }

    func testInitialization_PublishedPropertiesAreObservable() {
        // Given
        var isActiveUpdates = 0
        var participantUpdates = 0

        // When
        sut.$isActive
            .sink { _ in isActiveUpdates += 1 }
            .store(in: &cancellables)

        sut.$participants
            .sink { _ in participantUpdates += 1 }
            .store(in: &cancellables)

        // Then
        XCTAssertGreaterThan(isActiveUpdates, 0, "isActive should be observable")
        XCTAssertGreaterThan(participantUpdates, 0, "participants should be observable")
    }

    // MARK: - MagicARActivity Tests

    func testMagicARActivity_HasCorrectIdentifier() {
        // Given
        let activity = MagicARActivity()

        // Then
        XCTAssertEqual(MagicARActivity.activityIdentifier, "com.ariasmagic.shareplay",
                      "Activity identifier should match expected value")
    }

    func testMagicARActivity_HasCorrectMetadata() {
        // Given
        let activity = MagicARActivity()
        let metadata = activity.metadata

        // Then
        XCTAssertEqual(metadata.title, "Aria's Magic AR",
                      "Metadata title should be correct")
        XCTAssertEqual(metadata.subtitle, "Share the magic together!",
                      "Metadata subtitle should be correct")
        XCTAssertEqual(metadata.type, .generic,
                      "Metadata type should be generic")
    }

    // MARK: - SyncMessage Serialization Tests

    func testSyncMessage_CharacterSpawned_Serialization() throws {
        // Given
        let characterID = UUID()
        let characterType = CharacterType.sparkleThePrincess
        let position: [Float] = [1.0, 2.0, 3.0]

        let message = SyncMessage(
            type: .characterSpawned,
            characterID: characterID,
            characterType: characterType,
            position: position,
            action: nil,
            effect: nil
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)

        // Then
        XCTAssertNotNil(data, "Message should be encodable")
        XCTAssertGreaterThan(data.count, 0, "Encoded data should not be empty")
    }

    func testSyncMessage_CharacterSpawned_Deserialization() throws {
        // Given
        let characterID = UUID()
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: characterID,
            characterType: .lunaTheStarDancer,
            position: [1.0, 2.0, 3.0],
            action: nil,
            effect: nil
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)

        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(SyncMessage.self, from: data)

        // Then
        XCTAssertEqual(decodedMessage.type, message.type)
        XCTAssertEqual(decodedMessage.characterID, characterID)
        XCTAssertEqual(decodedMessage.characterType, .lunaTheStarDancer)
        XCTAssertEqual(decodedMessage.position, [1.0, 2.0, 3.0])
        XCTAssertNil(decodedMessage.action)
        XCTAssertNil(decodedMessage.effect)
    }

    func testSyncMessage_CharacterAction_Serialization() throws {
        // Given
        let message = SyncMessage(
            type: .characterAction,
            characterID: UUID(),
            characterType: nil,
            position: nil,
            action: .dance,
            effect: nil
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(SyncMessage.self, from: data)

        // Then
        XCTAssertEqual(decodedMessage.type, .characterAction)
        XCTAssertEqual(decodedMessage.action, .dance)
        XCTAssertNil(decodedMessage.position)
    }

    func testSyncMessage_EffectTriggered_Serialization() throws {
        // Given
        let message = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: "sparkles"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(SyncMessage.self, from: data)

        // Then
        XCTAssertEqual(decodedMessage.type, .effectTriggered)
        XCTAssertEqual(decodedMessage.effect, "sparkles")
        XCTAssertNil(decodedMessage.characterID)
        XCTAssertNil(decodedMessage.position)
    }

    func testSyncMessage_AllMessageTypes_RoundTrip() throws {
        // Given
        let messageTypes: [SyncMessage.MessageType] = [
            .characterSpawned,
            .characterAction,
            .effectTriggered
        ]

        // When & Then
        for type in messageTypes {
            let message = SyncMessage(
                type: type,
                characterID: UUID(),
                characterType: .sparkleThePrincess,
                position: [1, 2, 3],
                action: .wave,
                effect: "sparkles"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            let decoder = JSONDecoder()
            let decodedMessage = try decoder.decode(SyncMessage.self, from: data)

            XCTAssertEqual(decodedMessage.type, type,
                          "Message type should survive round-trip")
        }
    }

    func testSyncMessage_AllCharacterTypes_Serialization() throws {
        // Given
        let characterTypes: [CharacterType] = [
            .sparkleThePrincess,
            .lunaTheStarDancer,
            .rosieTheDreamWeaver,
            .crystalTheGemKeeper,
            .willowTheWishMaker
        ]

        // When & Then
        for characterType in characterTypes {
            let message = SyncMessage(
                type: .characterSpawned,
                characterID: UUID(),
                characterType: characterType,
                position: [0, 0, -1],
                action: nil,
                effect: nil
            )

            let data = try JSONEncoder().encode(message)
            let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

            XCTAssertEqual(decoded.characterType, characterType,
                          "\(characterType) should be serializable")
        }
    }

    func testSyncMessage_AllCharacterActions_Serialization() throws {
        // Given
        let actions: [CharacterAction] = [.idle, .wave, .dance, .twirl, .jump, .sparkle]

        // When & Then
        for action in actions {
            let message = SyncMessage(
                type: .characterAction,
                characterID: UUID(),
                characterType: nil,
                position: nil,
                action: action,
                effect: nil
            )

            let data = try JSONEncoder().encode(message)
            let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

            XCTAssertEqual(decoded.action, action,
                          "\(action) should be serializable")
        }
    }

    // MARK: - Message Sending Tests

    func testSendMessage_DoesNotCrashWhenNotActive() {
        // Given
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: .sparkleThePrincess,
            position: [0, 0, -1],
            action: nil,
            effect: nil
        )

        // When
        sut.sendMessage(message)

        // Then
        // Test passes if no crash occurs
        XCTAssertFalse(sut.isActive)
    }

    func testSendMessage_WithValidMessage() {
        // Given
        let message = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: "sparkles"
        )

        // When & Then - Should not crash
        sut.sendMessage(message)
    }

    // MARK: - SharePlay Session Tests

    func testStartSharePlay_UpdatesState() {
        // Note: Testing actual SharePlay functionality requires
        // proper mocking of GroupSession which is complex.
        // This test verifies the method can be called without crashing.

        // When
        sut.startSharePlay()

        // Then
        // Method should be callable without crashes
    }

    func testEndSharePlay_UpdatesIsActive() {
        // When
        sut.endSharePlay()

        // Then
        XCTAssertFalse(sut.isActive, "Service should be inactive after ending")
    }

    func testIsActive_StartsAsFalse() {
        // Then
        XCTAssertFalse(sut.isActive, "isActive should start as false")
    }

    func testParticipants_StartsEmpty() {
        // Then
        XCTAssertEmpty(sut.participants, "Participants should start empty")
    }

    // MARK: - Published Properties Tests

    func testIsActive_TriggersPublishedUpdate() {
        // Given
        let expectation = expectation(description: "isActive updated")
        var updateCount = 0

        sut.$isActive
            .dropFirst()
            .sink { _ in
                updateCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        // Simulate state change (in real scenario, this would happen via session)
        sut.endSharePlay()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(updateCount, 0)
    }

    func testParticipants_IsObservable() {
        // Given
        var observedUpdates = 0

        sut.$participants
            .sink { _ in observedUpdates += 1 }
            .store(in: &cancellables)

        // Then
        XCTAssertGreaterThan(observedUpdates, 0, "Participants should be observable")
    }

    // MARK: - Message Structure Tests

    func testSyncMessage_OptionalFields() throws {
        // Given - Message with minimal fields
        let message = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: "sparkles"
        )

        // When
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

        // Then
        XCTAssertNil(decoded.characterID)
        XCTAssertNil(decoded.characterType)
        XCTAssertNil(decoded.position)
        XCTAssertNil(decoded.action)
        XCTAssertNotNil(decoded.effect)
    }

    func testSyncMessage_Position_ThreeFloats() throws {
        // Given
        let positions: [[Float]] = [
            [0, 0, 0],
            [1.5, 2.5, 3.5],
            [-1, -2, -3],
            [100.123, 200.456, 300.789]
        ]

        // When & Then
        for position in positions {
            let message = SyncMessage(
                type: .characterSpawned,
                characterID: UUID(),
                characterType: .sparkleThePrincess,
                position: position,
                action: nil,
                effect: nil
            )

            let data = try JSONEncoder().encode(message)
            let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

            XCTAssertEqual(decoded.position, position,
                          "Position \(position) should be preserved")
        }
    }

    // MARK: - Edge Cases

    func testEdgeCase_MessageWithAllFieldsPopulated() throws {
        // Given
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: .sparkleThePrincess,
            position: [1, 2, 3],
            action: .dance,
            effect: "sparkles"
        )

        // When
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

        // Then
        XCTAssertNotNil(decoded.characterID)
        XCTAssertNotNil(decoded.characterType)
        XCTAssertNotNil(decoded.position)
        XCTAssertNotNil(decoded.action)
        XCTAssertNotNil(decoded.effect)
    }

    func testEdgeCase_MessageWithNoOptionalFields() throws {
        // Given
        let message = SyncMessage(
            type: .characterAction,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: nil
        )

        // When
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

        // Then
        XCTAssertNil(decoded.characterID)
        XCTAssertNil(decoded.characterType)
        XCTAssertNil(decoded.position)
        XCTAssertNil(decoded.action)
        XCTAssertNil(decoded.effect)
    }

    func testEdgeCase_VeryLargePosition() throws {
        // Given
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: .sparkleThePrincess,
            position: [Float.greatestFiniteMagnitude, 0, -Float.greatestFiniteMagnitude],
            action: nil,
            effect: nil
        )

        // When
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

        // Then
        XCTAssertNotNil(decoded.position)
    }

    func testEdgeCase_EmptyEffect() throws {
        // Given
        let message = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: ""
        )

        // When
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

        // Then
        XCTAssertEqual(decoded.effect, "")
    }

    // MARK: - Performance Tests

    func testPerformance_MessageSerialization() {
        // Given
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: .sparkleThePrincess,
            position: [1, 2, 3],
            action: .wave,
            effect: "sparkles"
        )

        // When
        measure {
            for _ in 0..<1000 {
                _ = try? JSONEncoder().encode(message)
            }
        }
    }

    func testPerformance_MessageDeserialization() throws {
        // Given
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: .sparkleThePrincess,
            position: [1, 2, 3],
            action: nil,
            effect: nil
        )
        let data = try JSONEncoder().encode(message)

        // When
        measure {
            for _ in 0..<1000 {
                _ = try? JSONDecoder().decode(SyncMessage.self, from: data)
            }
        }
    }

    func testPerformance_SendingMultipleMessages() {
        // Given
        let messages = (0..<100).map { _ in
            SyncMessage(
                type: .characterAction,
                characterID: UUID(),
                characterType: nil,
                position: nil,
                action: .dance,
                effect: nil
            )
        }

        // When
        measure {
            for message in messages {
                sut.sendMessage(message)
            }
        }
    }

    // MARK: - Integration Tests

    func testIntegration_CompleteMessageFlow() throws {
        // Given - Create various messages representing a complete flow
        let spawnMessage = SyncMessage(
            type: .characterSpawned,
            characterID: UUID(),
            characterType: .sparkleThePrincess,
            position: [1, 0, -2],
            action: nil,
            effect: nil
        )

        let actionMessage = SyncMessage(
            type: .characterAction,
            characterID: spawnMessage.characterID,
            characterType: nil,
            position: nil,
            action: .wave,
            effect: nil
        )

        let effectMessage = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: "sparkles"
        )

        // When - Serialize all messages
        let messages = [spawnMessage, actionMessage, effectMessage]
        let encodedMessages = try messages.map { try JSONEncoder().encode($0) }
        let decodedMessages = try encodedMessages.map { try JSONDecoder().decode(SyncMessage.self, from: $0) }

        // Then
        XCTAssertCount(decodedMessages, 3)
        XCTAssertEqual(decodedMessages[0].type, .characterSpawned)
        XCTAssertEqual(decodedMessages[1].type, .characterAction)
        XCTAssertEqual(decodedMessages[2].type, .effectTriggered)
    }

    func testIntegration_MessageTypeConsistency() throws {
        // Given
        let messageTypes: [SyncMessage.MessageType] = [
            .characterSpawned,
            .characterAction,
            .effectTriggered
        ]

        // When & Then - Verify each message type can be encoded as string
        for type in messageTypes {
            let message = SyncMessage(
                type: type,
                characterID: nil,
                characterType: nil,
                position: nil,
                action: nil,
                effect: nil
            )

            let data = try JSONEncoder().encode(message)
            let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)

            XCTAssertEqual(decoded.type.rawValue, type.rawValue,
                          "Message type raw value should be consistent")
        }
    }
}
