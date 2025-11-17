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
        case characterAction
        case effectTriggered
    }

    let type: MessageType
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let action: CharacterAction?
    let effect: MagicEffect?
    let timestamp: Date
}

class SharePlayService: ObservableObject {
    @Published var isActive = false
    @Published var participants: [Participant] = []

    weak var delegate: SharePlayServiceDelegate?

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()
    private var pendingSpawns: Set<UUID> = []  // Track spawns to prevent duplicates

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
                }
            }
            .store(in: &cancellables)

        // Listen for messages
        Task {
            guard let messenger = messenger else { return }

            for await (message, _) in messenger.messages(of: SyncMessage.self) {
                handleReceivedMessage(message)
            }
        }

        session.join()
    }

    func sendMessage(_ message: SyncMessage) {
        Task {
            try? await messenger?.send(message)
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
            timestamp: Date()
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
            timestamp: Date()
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
            effect: effect,
            timestamp: Date()
        )
        sendMessage(message)
    }

    private func handleReceivedMessage(_ message: SyncMessage) {
        // Handle sync messages from other participants
        print("Received message: \(message.type)")

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch message.type {
            case .characterSpawned:
                if let characterID = message.characterID,
                   let characterType = message.characterType,
                   let positionArray = message.position,
                   positionArray.count == 3 {

                    // Conflict resolution: check if this spawn is already pending
                    if self.pendingSpawns.contains(characterID) {
                        print("Duplicate spawn detected for character \(characterID), ignoring")
                        return
                    }

                    self.pendingSpawns.insert(characterID)

                    let position = SIMD3<Float>(positionArray[0], positionArray[1], positionArray[2])
                    self.delegate?.sharePlayService(self, didReceiveCharacterSpawn: characterID, type: characterType, position: position)

                    // Remove from pending after a short delay to allow for deduplication
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.pendingSpawns.remove(characterID)
                    }
                }

            case .characterAction:
                if let action = message.action {
                    self.delegate?.sharePlayService(self, didReceiveAction: action, for: message.characterID)
                }

            case .effectTriggered:
                if let effect = message.effect {
                    self.delegate?.sharePlayService(self, didReceiveEffect: effect)
                }
            }
        }
    }

    func endSharePlay() {
        session?.end()
        isActive = false
    }
}
