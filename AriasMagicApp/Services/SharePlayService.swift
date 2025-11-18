//
//  SharePlayService.swift
//  Aria's Magic SharePlay App
//
//  Handles SharePlay synchronization with full bidirectional sync
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

// Enhanced sync message for SharePlay
struct SyncMessage: Codable {
    enum MessageType: String, Codable {
        case characterSpawned
        case characterAction
        case characterPositionUpdated
        case characterScaleUpdated
        case characterRemoved
        case effectTriggered
    }

    let type: MessageType
    let timestamp: Date
    let senderID: String
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let scale: [Float]?
    let action: CharacterAction?
    let effect: String?

    init(
        type: MessageType,
        senderID: String,
        characterID: UUID? = nil,
        characterType: CharacterType? = nil,
        position: SIMD3<Float>? = nil,
        scale: SIMD3<Float>? = nil,
        action: CharacterAction? = nil,
        effect: String? = nil
    ) {
        self.type = type
        self.timestamp = Date()
        self.senderID = senderID
        self.characterID = characterID
        self.characterType = characterType
        self.position = position.map { [$0.x, $0.y, $0.z] }
        self.scale = scale.map { [$0.x, $0.y, $0.z] }
        self.action = action
        self.effect = effect
    }

    var positionVector: SIMD3<Float>? {
        guard let pos = position, pos.count == 3 else { return nil }
        return SIMD3<Float>(pos[0], pos[1], pos[2])
    }

    var scaleVector: SIMD3<Float>? {
        guard let scl = scale, scl.count == 3 else { return nil }
        return SIMD3<Float>(scl[0], scl[1], scl[2])
    }
}

// Protocol for SharePlay delegate to avoid circular dependencies
protocol SharePlayDelegate: AnyObject {
    func sharePlayDidReceiveCharacterSpawn(
        id: UUID,
        type: CharacterType,
        position: SIMD3<Float>,
        from senderID: String
    )
    func sharePlayDidReceiveCharacterAction(
        id: UUID,
        action: CharacterAction,
        from senderID: String
    )
    func sharePlayDidReceiveCharacterPositionUpdate(
        id: UUID,
        position: SIMD3<Float>,
        from senderID: String
    )
    func sharePlayDidReceiveCharacterScaleUpdate(
        id: UUID,
        scale: SIMD3<Float>,
        from senderID: String
    )
    func sharePlayDidReceiveCharacterRemoval(
        id: UUID,
        from senderID: String
    )
    func sharePlayDidReceiveEffect(
        effect: String,
        from senderID: String
    )
}

class SharePlayService: ObservableObject {
    @Published var isActive = false
    @Published var participants: [Participant] = []
    @Published var lastSyncTime: Date?
    @Published var syncErrorCount: Int = 0

    weak var delegate: SharePlayDelegate?

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()

    // Sync throttling
    private var lastSyncTimestamps: [String: Date] = [:] // key: "characterID-messageType"
    private let syncThrottleInterval: TimeInterval = 0.1 // 100ms minimum between syncs

    // Network retry configuration
    private let maxRetries = 3
    private var retryDelays: [TimeInterval] = [0.5, 1.0, 2.0]

    // Local participant ID
    private var localParticipantID: String {
        session?.localParticipant.id.uuidString ?? UUID().uuidString
    }

    init() {
        setupGroupSession()
    }

    private func setupGroupSession() {
        Task {
            for await session in MagicARActivity.sessions() {
                await MainActor.run {
                    configureSession(session)
                }
            }
        }
    }

    func startSharePlay() {
        Task {
            let activity = MagicARActivity()
            self.activity = activity

            switch await activity.prepareForActivation() {
            case .activationPreferred:
                do {
                    try await activity.activate()
                } catch {
                    await handleError("SharePlay activation failed: \(error.localizedDescription)")
                }
            case .activationDisabled:
                await handleError("SharePlay activation disabled")
            case .cancelled:
                print("SharePlay cancelled by user")
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
                    self?.lastSyncTimestamps.removeAll()
                }
            }
            .store(in: &cancellables)

        // Listen for messages
        Task {
            await receiveMessages()
        }

        session.join()
    }

    // MARK: - Message Receiving

    private func receiveMessages() async {
        guard let messenger = messenger else { return }

        for await (message, _) in messenger.messages(of: SyncMessage.self) {
            await MainActor.run {
                handleReceivedMessage(message)
            }
        }
    }

    private func handleReceivedMessage(_ message: SyncMessage) {
        // Don't process our own messages
        guard message.senderID != localParticipantID else { return }

        lastSyncTime = Date()

        switch message.type {
        case .characterSpawned:
            guard let id = message.characterID,
                  let type = message.characterType,
                  let position = message.positionVector else { return }
            delegate?.sharePlayDidReceiveCharacterSpawn(
                id: id,
                type: type,
                position: position,
                from: message.senderID
            )

        case .characterAction:
            guard let id = message.characterID,
                  let action = message.action else { return }
            delegate?.sharePlayDidReceiveCharacterAction(
                id: id,
                action: action,
                from: message.senderID
            )

        case .characterPositionUpdated:
            guard let id = message.characterID,
                  let position = message.positionVector else { return }
            delegate?.sharePlayDidReceiveCharacterPositionUpdate(
                id: id,
                position: position,
                from: message.senderID
            )

        case .characterScaleUpdated:
            guard let id = message.characterID,
                  let scale = message.scaleVector else { return }
            delegate?.sharePlayDidReceiveCharacterScaleUpdate(
                id: id,
                scale: scale,
                from: message.senderID
            )

        case .characterRemoved:
            guard let id = message.characterID else { return }
            delegate?.sharePlayDidReceiveCharacterRemoval(
                id: id,
                from: message.senderID
            )

        case .effectTriggered:
            guard let effect = message.effect else { return }
            delegate?.sharePlayDidReceiveEffect(
                effect: effect,
                from: message.senderID
            )
        }
    }

    // MARK: - Message Sending (with throttling and retry)

    func syncCharacterSpawn(
        id: UUID,
        type: CharacterType,
        position: SIMD3<Float>
    ) {
        let message = SyncMessage(
            type: .characterSpawned,
            senderID: localParticipantID,
            characterID: id,
            characterType: type,
            position: position
        )
        sendMessageWithRetry(message)
    }

    func syncCharacterAction(
        id: UUID,
        action: CharacterAction
    ) {
        let throttleKey = "\(id.uuidString)-action"
        guard shouldSendMessage(for: throttleKey) else { return }

        let message = SyncMessage(
            type: .characterAction,
            senderID: localParticipantID,
            characterID: id,
            action: action
        )
        sendMessageWithRetry(message)
    }

    func syncCharacterPosition(
        id: UUID,
        position: SIMD3<Float>
    ) {
        let throttleKey = "\(id.uuidString)-position"
        guard shouldSendMessage(for: throttleKey) else { return }

        let message = SyncMessage(
            type: .characterPositionUpdated,
            senderID: localParticipantID,
            characterID: id,
            position: position
        )
        sendMessageWithRetry(message)
    }

    func syncCharacterScale(
        id: UUID,
        scale: SIMD3<Float>
    ) {
        let throttleKey = "\(id.uuidString)-scale"
        guard shouldSendMessage(for: throttleKey) else { return }

        let message = SyncMessage(
            type: .characterScaleUpdated,
            senderID: localParticipantID,
            characterID: id,
            scale: scale
        )
        sendMessageWithRetry(message)
    }

    func syncCharacterRemoval(id: UUID) {
        let message = SyncMessage(
            type: .characterRemoved,
            senderID: localParticipantID,
            characterID: id
        )
        sendMessageWithRetry(message)
    }

    func syncEffect(effect: String) {
        let message = SyncMessage(
            type: .effectTriggered,
            senderID: localParticipantID,
            effect: effect
        )
        sendMessageWithRetry(message)
    }

    // MARK: - Throttling

    private func shouldSendMessage(for key: String) -> Bool {
        let now = Date()
        if let lastSync = lastSyncTimestamps[key] {
            let timeSinceLastSync = now.timeIntervalSince(lastSync)
            if timeSinceLastSync < syncThrottleInterval {
                return false
            }
        }
        lastSyncTimestamps[key] = now
        return true
    }

    // MARK: - Network Error Handling and Retry

    private func sendMessageWithRetry(_ message: SyncMessage, attempt: Int = 0) {
        Task {
            do {
                try await messenger?.send(message)
                if syncErrorCount > 0 {
                    await MainActor.run {
                        syncErrorCount = 0
                    }
                }
            } catch {
                await handleSendError(error, message: message, attempt: attempt)
            }
        }
    }

    private func handleSendError(_ error: Error, message: SyncMessage, attempt: Int) async {
        await MainActor.run {
            syncErrorCount += 1
        }

        if attempt < maxRetries {
            let delay = retryDelays[min(attempt, retryDelays.count - 1)]
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            sendMessageWithRetry(message, attempt: attempt + 1)
        } else {
            await handleError("Failed to send message after \(maxRetries) attempts: \(error.localizedDescription)")
        }
    }

    private func handleError(_ message: String) async {
        await MainActor.run {
            print("SharePlay Error: \(message)")
            // Could notify delegate or post notification here
        }
    }

    func endSharePlay() {
        session?.end()
        isActive = false
        lastSyncTimestamps.removeAll()
        cancellables.removeAll()
    }

    // MARK: - Debug Helpers

    func getParticipantCount() -> Int {
        return participants.count
    }

    func getSyncStats() -> (messageCount: Int, errorCount: Int, lastSync: Date?) {
        return (lastSyncTimestamps.count, syncErrorCount, lastSyncTime)
    }
}
