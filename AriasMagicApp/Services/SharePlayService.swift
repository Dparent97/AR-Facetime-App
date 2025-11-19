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
        case characterUpdated
        case characterRemoved
        case characterAction
        case effectTriggered
    }

    let type: MessageType
    let timestamp: TimeInterval

    // Character data
    let characterState: CharacterSyncState?

    // Effect data
    let effectType: String?

    init(type: MessageType, characterState: CharacterSyncState? = nil, effectType: String? = nil) {
        self.type = type
        self.timestamp = Date().timeIntervalSince1970
        self.characterState = characterState
        self.effectType = effectType
    }
}

// Delegate protocol for sync callbacks
protocol SharePlaySyncDelegate: AnyObject {
    func sharePlayDidSpawnCharacter(_ state: CharacterSyncState)
    func sharePlayDidUpdateCharacter(_ state: CharacterSyncState)
    func sharePlayDidRemoveCharacter(id: UUID)
    func sharePlayDidTriggerAction(_ action: CharacterAction, characterID: UUID)
    func sharePlayDidTriggerEffect(_ effect: String)
}

class SharePlayService: ObservableObject {
    @Published var isActive = false
    @Published var participants: [Participant] = []

    weak var delegate: SharePlaySyncDelegate?

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()

    // Message throttling
    private var lastSyncTime: [UUID: TimeInterval] = [:]
    private let syncThrottleInterval: TimeInterval = 0.1 // 10 updates per second max

    // Local participant ID
    private var localParticipantID: String?

    init() {
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
        Task {
            let activity = MagicARActivity()
            self.activity = activity

            switch await activity.prepareForActivation() {
            case .activationPreferred:
                try? await activity.activate()
            case .activationDisabled:
                print("SharePlay activation disabled")
            case .cancelled:
                print("SharePlay cancelled")
            @unknown default:
                break
            }
        }
    }

    private func configureSession(_ session: GroupSession<MagicARActivity>) {
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)

        // Capture local participant ID
        self.localParticipantID = session.localParticipant.id.uuidString

        session.$activeParticipants
            .sink { [weak self] participants in
                self?.participants = Array(participants)
                self?.isActive = !participants.isEmpty
            }
            .store(in: &cancellables)

        session.$state
            .sink { [weak self] state in
                if state == .invalidated {
                    self?.session = nil
                    self?.messenger = nil
                    self?.isActive = false
                    self?.localParticipantID = nil
                }
            }
            .store(in: &cancellables)

        // Listen for messages
        Task {
            guard let messenger = messenger else { return }

            for await (message, _) in messenger.messages(of: SyncMessage.self) {
                await handleReceivedMessage(message)
            }
        }

        session.join()
    }

    // MARK: - Public API for Sending Updates

    /// Send character spawn notification to all participants
    func sendCharacterSpawned(_ character: AnimatableCharacter) {
        guard isActive else { return }

        let state = CharacterSyncState.from(character, ownerID: localParticipantID)
        let message = SyncMessage(type: .characterSpawned, characterState: state)

        sendMessage(message)
    }

    /// Send character update (position/scale) with throttling
    func sendCharacterUpdated(_ character: AnimatableCharacter) {
        guard isActive else { return }

        // Throttle updates to prevent network spam
        let now = Date().timeIntervalSince1970
        if let lastSync = lastSyncTime[character.id],
           now - lastSync < syncThrottleInterval {
            return
        }

        lastSyncTime[character.id] = now

        let state = CharacterSyncState.from(character, ownerID: localParticipantID)
        let message = SyncMessage(type: .characterUpdated, characterState: state)

        sendMessage(message)
    }

    /// Send character removal notification
    func sendCharacterRemoved(id: UUID) {
        guard isActive else { return }

        let state = CharacterSyncState(
            id: id,
            type: .sparkleThePrincess, // Type doesn't matter for removal
            position: [0, 0, 0],
            scale: 1.0,
            action: .idle,
            ownerID: localParticipantID
        )
        let message = SyncMessage(type: .characterRemoved, characterState: state)

        sendMessage(message)
    }

    /// Send character action notification
    func sendCharacterAction(_ action: CharacterAction, characterID: UUID) {
        guard isActive else { return }

        let state = CharacterSyncState(
            id: characterID,
            type: .sparkleThePrincess, // Type doesn't matter for action
            position: [0, 0, 0],
            scale: 1.0,
            action: action,
            ownerID: localParticipantID
        )
        let message = SyncMessage(type: .characterAction, characterState: state)

        sendMessage(message)
    }

    /// Send effect trigger notification
    func sendEffectTriggered(_ effect: MagicEffect) {
        guard isActive else { return }

        let message = SyncMessage(type: .effectTriggered, effectType: effect.rawValue)
        sendMessage(message)
    }

    // MARK: - Private Message Handling

    private func sendMessage(_ message: SyncMessage) {
        Task {
            do {
                try await messenger?.send(message)
            } catch {
                print("⚠️ SharePlay: Failed to send message: \(error.localizedDescription)")
            }
        }
    }

    private func handleReceivedMessage(_ message: SyncMessage) async {
        // Handle sync messages from other participants
        print("📨 SharePlay: Received \(message.type.rawValue)")

        // Dispatch to main thread for UI updates
        await MainActor.run {
            switch message.type {
            case .characterSpawned:
                if let state = message.characterState {
                    delegate?.sharePlayDidSpawnCharacter(state)
                }

            case .characterUpdated:
                if let state = message.characterState {
                    delegate?.sharePlayDidUpdateCharacter(state)
                }

            case .characterRemoved:
                if let state = message.characterState {
                    delegate?.sharePlayDidRemoveCharacter(id: state.id)
                }

            case .characterAction:
                if let state = message.characterState {
                    delegate?.sharePlayDidTriggerAction(state.action, characterID: state.id)
                }

            case .effectTriggered:
                if let effectType = message.effectType {
                    delegate?.sharePlayDidTriggerEffect(effectType)
                }
            }
        }
    }

    func endSharePlay() {
        session?.end()
        isActive = false
    }
}
