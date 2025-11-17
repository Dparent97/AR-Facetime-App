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
    @Published var lastError: AppError?

    private var activity: MagicARActivity?
    private var session: GroupSession<MagicARActivity>?
    private var messenger: GroupSessionMessenger?
    private var cancellables = Set<AnyCancellable>()
    var onError: ((AppError) -> Void)?

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
            guard let messenger = messenger else {
                ErrorLoggingService.shared.logger.error("No messenger available for listening to messages")
                return
            }

            do {
                for await (message, _) in messenger.messages(of: SyncMessage.self) {
                    handleReceivedMessage(message)
                }
            } catch {
                let appError = AppError.sharePlayMessageFailed("Message receiving failed: \(error.localizedDescription)")
                ErrorLoggingService.shared.logError(appError)
                await handleError(appError)
            }
        }

        session.join()
    }

    func sendMessage(_ message: SyncMessage) {
        Task {
            guard let messenger = messenger else {
                let error = AppError.sharePlayMessageFailed("No active SharePlay session")
                ErrorLoggingService.shared.logError(error)
                await handleError(error)
                return
            }

            do {
                try await messenger.send(message)
                ErrorLoggingService.shared.logger.debug("SharePlay message sent: \(message.type.rawValue)")
            } catch {
                let appError = AppError.sharePlayMessageFailed(error.localizedDescription)
                ErrorLoggingService.shared.logError(appError)
                await handleError(appError)

                // Retry mechanism for network errors
                if isNetworkError(error) {
                    ErrorLoggingService.shared.logger.info("Retrying message send after network error")
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay

                    do {
                        try await messenger.send(message)
                        ErrorLoggingService.shared.logger.info("Message retry succeeded")
                    } catch {
                        ErrorLoggingService.shared.logSwiftError(error, context: "Message retry failed")
                    }
                }
            }
        }
    }

    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain ||
               nsError.code == NSURLErrorNotConnectedToInternet ||
               nsError.code == NSURLErrorNetworkConnectionLost
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
