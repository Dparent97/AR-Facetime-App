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

// Delegate protocol for SharePlay updates
protocol SharePlayServiceDelegate: AnyObject {
    func sharePlayService(_ service: SharePlayService, didReceiveCharacterSpawn characterID: UUID, type: CharacterType, position: SIMD3<Float>)
    func sharePlayService(_ service: SharePlayService, didReceiveAction action: CharacterAction, for characterID: UUID?)
    func sharePlayService(_ service: SharePlayService, didReceiveEffect effect: MagicEffect)
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
<<<<<<< HEAD
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let action: CharacterAction?
    let effect: MagicEffect?
    let timestamp: Date
||||||| e86307c
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let action: CharacterAction?
    let effect: String?
=======
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
>>>>>>> origin/claude/ios-core-engineer-setup-01CQsHe6EEGEBmrWYTBrySe8
}

class SharePlayService: ObservableObject {
    @Published var isActive = false
    @Published var participants: [Participant] = []
    @Published var lastError: AppError?

    weak var delegate: SharePlaySyncDelegate?

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()
    private var pendingSpawns: Set<UUID> = []  // Track spawns to prevent duplicates
    var onError: ((AppError) -> Void)?

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

            do {
                let result = await activity.prepareForActivation()

                switch result {
                case .activationPreferred:
                    do {
                        try await activity.activate()
                        ErrorLoggingService.shared.logger.info("SharePlay activated successfully")
                    } catch {
                        let appError = AppError.sharePlayActivationFailed("Activation failed: \(error.localizedDescription)")
                        ErrorLoggingService.shared.logError(appError)
                        await handleError(appError)
                    }

                case .activationDisabled:
                    let appError = AppError.sharePlayNotAvailable
                    ErrorLoggingService.shared.logError(appError)
                    await handleError(appError)

                case .cancelled:
                    ErrorLoggingService.shared.logger.info("SharePlay activation cancelled by user")
                    // Not an error, just user cancellation

                @unknown default:
                    let appError = AppError.sharePlayActivationFailed("Unknown activation result")
                    ErrorLoggingService.shared.logError(appError)
                    await handleError(appError)
                }
            }
        }
    }

    @MainActor
    private func handleError(_ error: AppError) {
        self.lastError = error
        self.onError?(error)
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
            guard let messenger = messenger else {
                ErrorLoggingService.shared.logger.error("No messenger available for listening to messages")
                return
            }

            do {
                for await (message, _) in messenger.messages(of: SyncMessage.self) {
                    await handleReceivedMessage(message)
                }
            } catch {
                let appError = AppError.sharePlayMessageFailed("Message receiving failed: \(error.localizedDescription)")
                ErrorLoggingService.shared.logError(appError)
                await handleError(appError)
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
            guard let messenger = messenger else {
                let error = AppError.sharePlayMessageFailed("No active SharePlay session")
                ErrorLoggingService.shared.logError(error)
                await handleError(error)
                return
            }

            do {
                try await messenger.send(message)
                // ErrorLoggingService.shared.logger.debug("SharePlay message sent: \(message.type.rawValue)")
            } catch {
                let appError = AppError.sharePlayMessageFailed(error.localizedDescription)
                ErrorLoggingService.shared.logError(appError)
                await handleError(appError)

                // Retry mechanism for network errors
                if isNetworkError(error) {
                    // ErrorLoggingService.shared.logger.info("Retrying message send after network error")
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay

                    do {
                        try await messenger.send(message)
                        // ErrorLoggingService.shared.logger.info("Message retry succeeded")
                    } catch {
                        ErrorLoggingService.shared.logSwiftError(error, context: "Message retry failed")
                    }
                }
            }
        }
    }


    // Helper methods to send specific message types
    func sendCharacterSpawn(id: UUID, type: CharacterType, position: SIMD3<Float>) {
        guard isActive else { return }

        let message = SyncMessage(
            type: .characterSpawned,
            characterID: id,
            characterType: type,
            position: [position.x, position.y, position.z],
            action: nil,
            effect: nil,
            characterState: nil,
            effectType: nil
        )
        sendMessage(message)
    }

    func sendCharacterAction(_ action: CharacterAction, for characterID: UUID?) {
        guard isActive else { return }

        let message = SyncMessage(
            type: .characterAction,
            characterID: characterID,
            characterType: nil,
            position: nil,
            action: action,
            effect: nil,
            characterState: nil,
            effectType: nil
        )
        sendMessage(message)
    }

    func sendEffect(_ effect: MagicEffect) {
        guard isActive else { return }

        let message = SyncMessage(
            type: .effectTriggered,
            characterID: nil,
            characterType: nil,
            position: nil,
            action: nil,
            effect: effect.rawValue,
            characterState: nil,
            effectType: effect.rawValue
        )
        sendMessage(message)
    }

    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain ||
               nsError.code == NSURLErrorNotConnectedToInternet ||
               nsError.code == NSURLErrorNetworkConnectionLost
    }

    private func handleReceivedMessage(_ message: SyncMessage) async {
        // Handle sync messages from other participants
        print("Received message: \(message.type)")

        // Dispatch to main thread for UI updates
        await MainActor.run {
            switch message.type {
            case .characterSpawned:
                if let state = message.characterState {
                     delegate?.sharePlayDidSpawnCharacter(state)
                } else if let characterID = message.characterID,
                          let characterType = message.characterType,
                          let positionArray = message.position,
                          positionArray.count == 3 {
                    // Legacy format fallback
                    let position = SIMD3<Float>(positionArray[0], positionArray[1], positionArray[2])
                    let state = CharacterSyncState(id: characterID, type: characterType, position: position, scale: 1.0, action: .idle)
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
                } else if let action = message.action, let characterID = message.characterID {
                    // Legacy format fallback
                    delegate?.sharePlayDidTriggerAction(action, characterID: characterID)
                }

            case .effectTriggered:
                if let effectType = message.effectType {
                    delegate?.sharePlayDidTriggerEffect(effectType)
                } else if let effect = message.effect {
                     // Legacy format fallback
                    delegate?.sharePlayDidTriggerEffect(effect)
                }
            }
        }
    }


    func endSharePlay() {
        session?.end()
        isActive = false
    }
}
