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
        case characterAction
        case effectTriggered
    }

    let type: MessageType
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let action: CharacterAction?
    let effect: String?
}

class SharePlayService: ObservableObject {
    @Published var isActive = false
    @Published var participants: [Participant] = []

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()

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

    private func handleReceivedMessage(_ message: SyncMessage) {
        // Handle sync messages from other participants
        print("Received message: \(message.type)")
        // This would be connected to the CharacterViewModel to sync state
    }

    func endSharePlay() {
        session?.end()
        isActive = false
    }
}
