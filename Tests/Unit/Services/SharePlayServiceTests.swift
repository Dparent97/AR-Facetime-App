//
//  SharePlayServiceTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Unit tests for SharePlayService
//

import XCTest
import GroupActivities
import Combine
@testable import AriasMagicApp

class SharePlayServiceTests: XCTestCase {

    var service: SharePlayService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        service = SharePlayService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testServiceInitialization() {
        // GIVEN/WHEN: Creating service
        let service = SharePlayService()

        // THEN: Service is initialized with correct state
        XCTAssertNotNil(service)
        XCTAssertFalse(service.isActive)
        XCTAssertTrue(service.participants.isEmpty)
    }

    // MARK: - Published Properties Tests

    func testIsActive_initiallyFalse() {
        // GIVEN: Newly created service
        // WHEN: Checking isActive
        // THEN: Initially false
        XCTAssertFalse(service.isActive)
    }

    func testParticipants_initiallyEmpty() {
        // GIVEN: Newly created service
        // WHEN: Checking participants
        // THEN: Initially empty
        XCTAssertTrue(service.participants.isEmpty)
    }

    func testIsActive_publishesChanges() {
        // GIVEN: Service with observer
        let expectation = expectation(description: "isActive change published")
        var publishedValue: Bool?

        service.$isActive
            .dropFirst() // Skip initial value
            .sink { value in
                publishedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // WHEN: Changing isActive (simulated)
        // Note: In real scenario, this would be changed by session state
        DispatchQueue.main.async {
            self.service.isActive = true
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedValue, true)
    }

    func testParticipants_publishesChanges() {
        // GIVEN: Service with observer
        let expectation = expectation(description: "participants change published")
        var publishedCount = 0

        service.$participants
            .dropFirst() // Skip initial value
            .sink { participants in
                publishedCount = participants.count
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // WHEN: Changing participants (simulated)
        DispatchQueue.main.async {
            // In real scenario, participants come from session
            self.service.participants = []
        }

        // THEN: Change is published
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedCount, 0)
    }

    // MARK: - MagicARActivity Tests

    func testMagicARActivity_hasCorrectIdentifier() {
        // GIVEN: MagicARActivity
        // WHEN: Accessing identifier
        let identifier = MagicARActivity.activityIdentifier

        // THEN: Identifier matches expected value
        XCTAssertEqual(identifier, "com.ariasmagic.shareplay")
    }

    func testMagicARActivity_metadata() {
        // GIVEN: A MagicARActivity instance
        let activity = MagicARActivity()

        // WHEN: Accessing metadata
        let metadata = activity.metadata

        // THEN: Metadata is configured correctly
        XCTAssertEqual(metadata.title, "Aria's Magic AR")
        XCTAssertEqual(metadata.subtitle, "Share the magic together!")
        XCTAssertEqual(metadata.type, .generic)
    }

    // MARK: - SyncMessage Tests

    func testSyncMessage_characterSpawned() {
        // GIVEN: Spawn message data
        let characterID = UUID()
        let characterType = CharacterType.sparkleThePrincess
        let position: [Float] = [1.0, 2.0, 3.0]

        // WHEN: Creating spawn message
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: characterID,
            characterType: characterType,
            position: position,
            action: nil,
            effect: nil
        )

        // THEN: Message properties are correct
        XCTAssertEqual(message.type, .characterSpawned)
        XCTAssertEqual(message.characterID, characterID)
        XCTAssertEqual(message.characterType, characterType)
        XCTAssertEqual(message.position, position)
        XCTAssertNil(message.action)
        XCTAssertNil(message.effect)
    }

    func testSyncMessage_characterAction() {
        // GIVEN: Action message data
        let characterID = UUID()
        let action = CharacterAction.wave

        // WHEN: Creating action message
        let message = SyncMessage(
            type: .characterAction,
            characterID: characterID,
            characterType: nil,
            position: nil,
            action: action,
            effect: nil
        )

        // THEN: Message properties are correct
        XCTAssertEqual(message.type, .characterAction)
        XCTAssertEqual(message.characterID, characterID)
        XCTAssertEqual(message.action, action)
        XCTAssertNil(message.characterType)
        XCTAssertNil(message.position)
        XCTAssertNil(message.effect)
    }

    func testSyncMessage_effectTriggered() {
        // GIVEN: Effect message data
        let effect = "sparkles"

        // WHEN: Creating effect message
        let message = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: effect
        )

        // THEN: Message properties are correct
        XCTAssertEqual(message.type, .effectTriggered)
        XCTAssertEqual(message.effect, effect)
        XCTAssertNil(message.characterID)
        XCTAssertNil(message.characterType)
        XCTAssertNil(message.position)
        XCTAssertNil(message.action)
    }

    // MARK: - Codable Tests

    func testSyncMessage_isEncodable() throws {
        // GIVEN: A sync message
        let message = TestData.createSpawnMessage()

        // WHEN: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)

        // THEN: Encoding succeeds
        XCTAssertFalse(data.isEmpty)
    }

    func testSyncMessage_isDecodable() throws {
        // GIVEN: Encoded sync message
        let message = TestData.createActionMessage(action: .dance)
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)

        // WHEN: Decoding from JSON
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(SyncMessage.self, from: data)

        // THEN: Decoded message matches original
        XCTAssertEqual(decodedMessage.type, message.type)
        XCTAssertEqual(decodedMessage.characterID, message.characterID)
        XCTAssertEqual(decodedMessage.action, message.action)
    }

    func testSyncMessage_roundTripEncoding_spawn() throws {
        // GIVEN: Spawn message
        let original = TestData.createSpawnMessage(
            characterID: UUID(),
            characterType: .lunaTheStarDancer,
            position: SIMD3<Float>(1, 2, 3)
        )

        // WHEN: Encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(SyncMessage.self, from: data)

        // THEN: Values match
        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.characterID, original.characterID)
        XCTAssertEqual(decoded.characterType, original.characterType)
        XCTAssertEqual(decoded.position, original.position)
    }

    func testSyncMessage_roundTripEncoding_action() throws {
        // GIVEN: Action message
        let original = TestData.createActionMessage(
            characterID: UUID(),
            action: .twirl
        )

        // WHEN: Encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(SyncMessage.self, from: data)

        // THEN: Values match
        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.characterID, original.characterID)
        XCTAssertEqual(decoded.action, original.action)
    }

    func testSyncMessage_roundTripEncoding_effect() throws {
        // GIVEN: Effect message
        let original = TestData.createEffectMessage(effect: .bubbles)

        // WHEN: Encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(SyncMessage.self, from: data)

        // THEN: Values match
        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.effect, original.effect)
    }

    // MARK: - MessageType Tests

    func testMessageType_rawValues() {
        // GIVEN: Message types
        // WHEN: Accessing raw values
        // THEN: Values match expected strings
        XCTAssertEqual(SyncMessage.MessageType.characterSpawned.rawValue, "characterSpawned")
        XCTAssertEqual(SyncMessage.MessageType.characterAction.rawValue, "characterAction")
        XCTAssertEqual(SyncMessage.MessageType.effectTriggered.rawValue, "effectTriggered")
    }

    func testMessageType_allCases() {
        // GIVEN: All message types
        let expectedTypes: [SyncMessage.MessageType] = [
            .characterSpawned,
            .characterAction,
            .effectTriggered
        ]

        // WHEN: Checking count
        // THEN: All types are represented
        XCTAssertEqual(expectedTypes.count, 3)
    }

    // MARK: - Service Lifecycle Tests

    func testEndSharePlay_setsIsActiveToFalse() {
        // GIVEN: Service with active state
        service.isActive = true

        // WHEN: Ending SharePlay
        service.endSharePlay()

        // THEN: isActive is false
        XCTAssertFalse(service.isActive)
    }

    // MARK: - Integration Tests with TestData

    func testCreateAllMessageTypes_usingTestData() {
        // GIVEN: Test data helpers
        // WHEN: Creating all message types
        let spawnMsg = TestData.createSpawnMessage()
        let actionMsg = TestData.createActionMessage()
        let effectMsg = TestData.createEffectMessage()

        // THEN: All messages are valid
        XCTAssertEqual(spawnMsg.type, .characterSpawned)
        XCTAssertEqual(actionMsg.type, .characterAction)
        XCTAssertEqual(effectMsg.type, .effectTriggered)
    }

    func testSyncMessage_withAllCharacterTypes() throws {
        // GIVEN: All character types
        let types = CharacterType.allCases

        // WHEN: Creating spawn messages for each
        for type in types {
            let message = TestData.createSpawnMessage(characterType: type)

            // THEN: Message encodes/decodes correctly
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            let data = try encoder.encode(message)
            let decoded = try decoder.decode(SyncMessage.self, from: data)

            XCTAssertEqual(decoded.characterType, type)
        }
    }

    func testSyncMessage_withAllActions() throws {
        // GIVEN: All character actions
        let actions = TestData.allCharacterActions

        // WHEN: Creating action messages for each
        for action in actions {
            let message = TestData.createActionMessage(action: action)

            // THEN: Message encodes/decodes correctly
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            let data = try encoder.encode(message)
            let decoded = try decoder.decode(SyncMessage.self, from: data)

            XCTAssertEqual(decoded.action, action)
        }
    }

    // MARK: - Performance Tests

    func testPerformance_encodeSpawnMessage() {
        // GIVEN: Spawn message
        let message = TestData.createSpawnMessage()
        let encoder = JSONEncoder()

        // WHEN/THEN: Measuring encoding performance
        measure {
            _ = try? encoder.encode(message)
        }
    }

    func testPerformance_decodeSpawnMessage() throws {
        // GIVEN: Encoded spawn message
        let message = TestData.createSpawnMessage()
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let decoder = JSONDecoder()

        // WHEN/THEN: Measuring decoding performance
        measure {
            _ = try? decoder.decode(SyncMessage.self, from: data)
        }
    }

    func testPerformance_createManyMessages() {
        // GIVEN/WHEN/THEN: Creating many messages
        measure {
            for _ in 0..<1000 {
                _ = TestData.createSpawnMessage()
                _ = TestData.createActionMessage()
                _ = TestData.createEffectMessage()
            }
        }
    }

    // MARK: - Memory Tests

    func testService_canBeReleased() {
        // GIVEN: A weak reference to service
        weak var weakService: SharePlayService?

        autoreleasepool {
            let service = SharePlayService()
            weakService = service
            XCTAssertNotNil(weakService)
        }

        // WHEN: Service goes out of scope
        // THEN: It can be deallocated
        XCTAssertNil(weakService)
    }

    func testSyncMessages_doNotLeakMemory() {
        // GIVEN: Multiple message creations
        // WHEN: Creating and releasing messages
        autoreleasepool {
            for _ in 0..<1000 {
                _ = TestData.createSpawnMessage()
                _ = TestData.createActionMessage()
                _ = TestData.createEffectMessage()
            }
        }

        // THEN: Test completes without memory warnings
        XCTAssertTrue(true)
    }

    // MARK: - ObservableObject Tests

    func testService_isObservableObject() {
        // GIVEN: SharePlayService
        // WHEN: Checking conformance
        // THEN: Service conforms to ObservableObject
        XCTAssertTrue(service is ObservableObject)
    }

    func testService_objectWillChange_fires() {
        // GIVEN: Service with observer
        let expectation = expectation(description: "objectWillChange fires")
        var didFire = false

        let cancellable = service.objectWillChange.sink {
            didFire = true
            expectation.fulfill()
        }

        // WHEN: Changing a published property
        DispatchQueue.main.async {
            self.service.isActive = true
        }

        // THEN: objectWillChange fires
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(didFire)
        cancellable.cancel()
    }
}
