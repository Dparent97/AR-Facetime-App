//
//  SharePlayService.swift
//  Aria's Magic SharePlay App
//
//  Handles SharePlay synchronization
//

import Foundation
import GroupActivities
import Combine

struct MagicARActivity: GroupActivity {
    static let activityIdentifier = "com.ariasmagic.shareplay"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Aria's Magic AR"
        metadata.subtitle = "Share the magic together!"
        metadata.type = .generic
        return metadata
    }
}

// Sync message for SharePlay
struct SyncMessage: Codable {
    enum MessageType: String, Codable {
        case characterSpawned
        case characterRemoved
        case characterAction
        case characterPositionUpdate
        case characterScaleUpdate
        case effectTriggered
        case fullStateSync
    }

    let type: MessageType
    let timestamp: Date
    let senderID: String

    // Character data
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let scale: [Float]?
    let action: CharacterAction?

    // Effect data
    let effect: String?

    // Full state sync
    let fullState: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case type, timestamp, senderID
        case characterID, characterType, position, scale, action
        case effect, fullState
    }

    init(
        type: MessageType,
        timestamp: Date = Date(),
        senderID: String,
        characterID: UUID? = nil,
        characterType: CharacterType? = nil,
        position: [Float]? = nil,
        scale: [Float]? = nil,
        action: CharacterAction? = nil,
        effect: String? = nil,
        fullState: [String: Any]? = nil
    ) {
        self.type = type
        self.timestamp = timestamp
        self.senderID = senderID
        self.characterID = characterID
        self.characterType = characterType
        self.position = position
        self.scale = scale
        self.action = action
        self.effect = effect
        self.fullState = fullState
    }

    // Custom encoding for fullState dictionary
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(senderID, forKey: .senderID)
        try container.encodeIfPresent(characterID, forKey: .characterID)
        try container.encodeIfPresent(characterType, forKey: .characterType)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encodeIfPresent(scale, forKey: .scale)
        try container.encodeIfPresent(action, forKey: .action)
        try container.encodeIfPresent(effect, forKey: .effect)
        // fullState is complex, skip for now or encode as JSON string
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(MessageType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        senderID = try container.decode(String.self, forKey: .senderID)
        characterID = try container.decodeIfPresent(UUID.self, forKey: .characterID)
        characterType = try container.decodeIfPresent(CharacterType.self, forKey: .characterType)
        position = try container.decodeIfPresent([Float].self, forKey: .position)
        scale = try container.decodeIfPresent([Float].self, forKey: .scale)
        action = try container.decodeIfPresent(CharacterAction.self, forKey: .action)
        effect = try container.decodeIfPresent(String.self, forKey: .effect)
        fullState = nil  // Skip for now
    }
}

// Protocol for SharePlay sync delegate
protocol SharePlaySyncDelegate: AnyObject {
    func sharePlayDidReceiveCharacterSpawn(id: UUID, type: CharacterType, position: SIMD3<Float>, scale: SIMD3<Float>)
    func sharePlayDidReceiveCharacterRemoved(id: UUID)
    func sharePlayDidReceiveCharacterAction(id: UUID, action: CharacterAction)
    func sharePlayDidReceiveCharacterPositionUpdate(id: UUID, position: SIMD3<Float>)
    func sharePlayDidReceiveCharacterScaleUpdate(id: UUID, scale: SIMD3<Float>)
    func sharePlayDidReceiveEffect(effect: MagicEffect)
}

class SharePlayService: ObservableObject {
    @Published var isActive = false
    @Published var participants: [Participant] = []
    @Published var isConnecting = false

    weak var delegate: SharePlaySyncDelegate?

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()

    // Throttling
    private var lastSyncTime: [String: Date] = [:]
    private let syncThrottleInterval: TimeInterval = 0.1  // Max 10 updates per second

    // Unique identifier for this device
    private let deviceID = UUID().uuidString

    // Singleton
    static let shared = SharePlayService()

    private init() {
        setupGroupSession()
    }

    private func setupGroupSession() {
        Task {
            for await session in MagicARActivity.sessions() {
                configureSession(session)
            }
        }
    }

    func startSharePlay() {
        Task { @MainActor in
            isConnecting = true
            let activity = MagicARActivity()
            self.activity = activity

            switch await activity.prepareForActivation() {
            case .activationPreferred:
                do {
                    try await activity.activate()
                } catch {
                    print("SharePlayService: Failed to activate: \(error)")
                    isConnecting = false
                }
            case .activationDisabled:
                print("SharePlayService: Activation disabled")
                isConnecting = false
            case .cancelled:
                print("SharePlayService: Cancelled")
                isConnecting = false
            @unknown default:
                isConnecting = false
                break
            }
        }
    }

    private func configureSession(_ session: GroupSession<MagicARActivity>) {
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)

        Task { @MainActor in
            isConnecting = false
        }

        session.$activeParticipants
            .sink { [weak self] participants in
                Task { @MainActor in
                    self?.participants = Array(participants)
                    self?.isActive = !participants.isEmpty
                    print("SharePlayService: Active participants: \(participants.count)")
                }
            }
            .store(in: &cancellables)

        session.$state
            .sink { [weak self] state in
                Task { @MainActor in
                    if state == .invalidated {
                        self?.session = nil
                        self?.messenger = nil
                        self?.isActive = false
                        self?.isConnecting = false
                        print("SharePlayService: Session invalidated")
                    } else {
                        print("SharePlayService: Session state: \(state)")
                    }
                }
            }
            .store(in: &cancellables)

        // Listen for messages
        Task {
            guard let messenger = messenger else { return }

            for await (message, sender) in messenger.messages(of: SyncMessage.self) {
                await handleReceivedMessage(message, from: sender)
            }
        }

        session.join()
    }

    // MARK: - Send Messages

    func sendCharacterSpawned(id: UUID, type: CharacterType, position: SIMD3<Float>, scale: SIMD3<Float>) {
        let message = SyncMessage(
            type: .characterSpawned,
            senderID: deviceID,
            characterID: id,
            characterType: type,
            position: [position.x, position.y, position.z],
            scale: [scale.x, scale.y, scale.z]
        )
        sendMessage(message)
    }

    func sendCharacterRemoved(id: UUID) {
        let message = SyncMessage(
            type: .characterRemoved,
            senderID: deviceID,
            characterID: id
        )
        sendMessage(message)
    }

    func sendCharacterAction(id: UUID, action: CharacterAction) {
        guard shouldSync(key: "action_\(id.uuidString)") else { return }

        let message = SyncMessage(
            type: .characterAction,
            senderID: deviceID,
            characterID: id,
            action: action
        )
        sendMessage(message)
    }

    func sendCharacterPosition(id: UUID, position: SIMD3<Float>) {
        guard shouldSync(key: "position_\(id.uuidString)") else { return }

        let message = SyncMessage(
            type: .characterPositionUpdate,
            senderID: deviceID,
            characterID: id,
            position: [position.x, position.y, position.z]
        )
        sendMessage(message)
    }

    func sendCharacterScale(id: UUID, scale: SIMD3<Float>) {
        guard shouldSync(key: "scale_\(id.uuidString)") else { return }

        let message = SyncMessage(
            type: .characterScaleUpdate,
            senderID: deviceID,
            characterID: id,
            scale: [scale.x, scale.y, scale.z]
        )
        sendMessage(message)
    }

    func sendEffect(_ effect: MagicEffect) {
        let message = SyncMessage(
            type: .effectTriggered,
            senderID: deviceID,
            effect: effect.rawValue
        )
        sendMessage(message)
    }

    private func sendMessage(_ message: SyncMessage) {
        guard isActive else {
            print("SharePlayService: Cannot send message - not active")
            return
        }

        Task {
            do {
                try await messenger?.send(message)
                print("SharePlayService: Sent message: \(message.type)")
            } catch {
                print("SharePlayService: Failed to send message: \(error)")
            }
        }
    }

    // MARK: - Receive Messages

    private func handleReceivedMessage(_ message: SyncMessage, from sender: Participant) async {
        // Ignore messages from self
        guard message.senderID != deviceID else {
            return
        }

        print("SharePlayService: Received \(message.type) from \(sender.id)")

        await MainActor.run {
            switch message.type {
            case .characterSpawned:
                handleCharacterSpawned(message)

            case .characterRemoved:
                handleCharacterRemoved(message)

            case .characterAction:
                handleCharacterAction(message)

            case .characterPositionUpdate:
                handleCharacterPositionUpdate(message)

            case .characterScaleUpdate:
                handleCharacterScaleUpdate(message)

            case .effectTriggered:
                handleEffectTriggered(message)

            case .fullStateSync:
                handleFullStateSync(message)
            }
        }
    }

    private func handleCharacterSpawned(_ message: SyncMessage) {
        guard let id = message.characterID,
              let type = message.characterType,
              let posArray = message.position, posArray.count == 3,
              let scaleArray = message.scale, scaleArray.count == 3 else {
            print("SharePlayService: Invalid character spawn message")
            return
        }

        let position = SIMD3<Float>(posArray[0], posArray[1], posArray[2])
        let scale = SIMD3<Float>(scaleArray[0], scaleArray[1], scaleArray[2])

        delegate?.sharePlayDidReceiveCharacterSpawn(id: id, type: type, position: position, scale: scale)
    }

    private func handleCharacterRemoved(_ message: SyncMessage) {
        guard let id = message.characterID else {
            print("SharePlayService: Invalid character removed message")
            return
        }

        delegate?.sharePlayDidReceiveCharacterRemoved(id: id)
    }

    private func handleCharacterAction(_ message: SyncMessage) {
        guard let id = message.characterID,
              let action = message.action else {
            print("SharePlayService: Invalid character action message")
            return
        }

        delegate?.sharePlayDidReceiveCharacterAction(id: id, action: action)
    }

    private func handleCharacterPositionUpdate(_ message: SyncMessage) {
        guard let id = message.characterID,
              let posArray = message.position, posArray.count == 3 else {
            print("SharePlayService: Invalid position update message")
            return
        }

        let position = SIMD3<Float>(posArray[0], posArray[1], posArray[2])
        delegate?.sharePlayDidReceiveCharacterPositionUpdate(id: id, position: position)
    }

    private func handleCharacterScaleUpdate(_ message: SyncMessage) {
        guard let id = message.characterID,
              let scaleArray = message.scale, scaleArray.count == 3 else {
            print("SharePlayService: Invalid scale update message")
            return
        }

        let scale = SIMD3<Float>(scaleArray[0], scaleArray[1], scaleArray[2])
        delegate?.sharePlayDidReceiveCharacterScaleUpdate(id: id, scale: scale)
    }

    private func handleEffectTriggered(_ message: SyncMessage) {
        guard let effectString = message.effect,
              let effect = MagicEffect(rawValue: effectString) else {
            print("SharePlayService: Invalid effect message")
            return
        }

        delegate?.sharePlayDidReceiveEffect(effect: effect)
    }

    private func handleFullStateSync(_ message: SyncMessage) {
        // TODO: Implement full state sync in Phase 2
        print("SharePlayService: Full state sync not yet implemented")
    }

    // MARK: - Throttling

    private func shouldSync(key: String) -> Bool {
        let now = Date()

        if let lastTime = lastSyncTime[key],
           now.timeIntervalSince(lastTime) < syncThrottleInterval {
            return false
        }

        lastSyncTime[key] = now
        return true
    }

    func endSharePlay() {
        session?.end()
        Task { @MainActor in
            isActive = false
            isConnecting = false
            participants.removeAll()
        }
        print("SharePlayService: Ended SharePlay session")
    }

    // MARK: - Diagnostics

    func getConnectionStatus() -> String {
        if isConnecting {
            return "Connecting..."
        } else if isActive {
            return "Active (\(participants.count) participants)"
        } else {
            return "Inactive"
        }
    }
}
