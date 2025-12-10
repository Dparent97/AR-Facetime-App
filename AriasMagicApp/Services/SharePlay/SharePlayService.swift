import Foundation
import GroupActivities
import Combine
import SwiftUI

@MainActor
public class SharePlayService: ObservableObject {
    public static let shared = SharePlayService()
    
    @Published public var isActive = false
    @Published public var participants: [Participant] = []
    
    private var session: GroupSession<AriaMagicMoment>?
    private var messenger: GroupSessionMessenger?
    private var tasks = Set<Task<Void, Never>>()
    private var subscriptions = Set<AnyCancellable>()
    
    // Reference to store to apply updates
    private var store: CharacterStore?
    
    private init() {
        // Listen for new sessions
        Task {
            for await session in AriaMagicMoment.sessions() {
                self.configureSession(session)
            }
        }
    }
    
    public func bind(to store: CharacterStore) {
        self.store = store
        
        // Listen to local events and broadcast them
        store.eventSubject
            .sink { [weak self] event in
                self?.broadcastEvent(event)
            }
            .store(in: &subscriptions)
    }
    
    public func start() {
        Task {
            let activity = AriaMagicMoment()
            switch await activity.prepareForActivation() {
            case .activationPreferred:
                _ = try? await activity.activate()
            case .activationDisabled:
                print("SharePlay disabled")
            case .cancelled:
                break
            @unknown default:
                break
            }
        }
    }
    
    public func leave() {
        session?.leave()
        reset()
    }
    
    private func reset() {
        session = nil
        messenger = nil
        isActive = false
        participants = []
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    private func configureSession(_ session: GroupSession<AriaMagicMoment>) {
        reset()
        
        self.session = session
        self.messenger = GroupSessionMessenger(session: session)
        
        let sessionStateTask = Task {
            for await state in session.$state.values {
                if case .invalidated = state {
                    self.reset()
                }
            }
        }
        tasks.insert(sessionStateTask)
        
        let participantsTask = Task {
            for await activeParticipants in session.$activeParticipants.values {
                self.participants = Array(activeParticipants)
                self.isActive = !activeParticipants.isEmpty
                
                // If we are the only one and someone joins, they might need state.
                // But simpler: New joiner requests state.
            }
        }
        tasks.insert(participantsTask)
        
        // Handle incoming messages
        let messageTask = Task {
            guard let messenger = self.messenger else { return }
            for await (message, _) in messenger.messages(of: SyncMessage.self) {
                self.handleMessage(message)
            }
        }
        tasks.insert(messageTask)
        
        session.join()
        
        // Request state from others just in case we are late joiner
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Wait a bit
            self.send(.requestState)
        }
    }
    
    private func broadcastEvent(_ event: StoreEvent) {
        guard isActive else { return }
        
        let message: SyncMessage
        switch event {
        case .characterSpawned(let state):
            message = .characterSpawned(state)
        case .characterUpdated(let state):
            message = .characterUpdated(state)
        case .characterRemoved(let id):
            message = .characterRemoved(id)
        case .actionTriggered(let id, let action):
            message = .characterAction(id, action)
        case .effectSpawned(let state):
            message = .effectSpawned(state)
        }
        
        send(message)
    }
    
    private func send(_ message: SyncMessage) {
        Task {
            try? await messenger?.send(message)
        }
    }
    
    private func handleMessage(_ message: SyncMessage) {
        guard let store = store else { return }
        
        switch message {
        case .characterSpawned(let state):
            store.spawnCharacter(state: state, source: .remote)
            
        case .characterUpdated(let state):
            store.updateCharacterState(state, source: .remote)
            
        case .characterRemoved(let id):
            store.removeCharacter(id: id, source: .remote)
            
        case .characterAction(let id, let action):
            store.performAction(id: id, action: action, source: .remote)
            
        case .effectSpawned(let state):
            store.spawnEffect(state: state, source: .remote)
            
        case .requestState:
            // Send our current state to everyone (or just the requester if we could target, but broadcast is fine)
            // To avoid flooding, maybe only "active" or "host" sends?
            // For now, everyone sends. It's a prototype.
            for character in store.characters.values {
                send(.characterSpawned(character))
            }
        }
    }
}

