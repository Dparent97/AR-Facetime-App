import Foundation
import Observation
import simd
import Combine

public enum UpdateSource {
    case local
    case remote
}

public enum StoreEvent {
    case characterSpawned(CharacterState)
    case characterUpdated(CharacterState)
    case characterRemoved(UUID)
    case actionTriggered(UUID, CharacterAction)
    case effectSpawned(EffectState)
}

@Observable
public class CharacterStore {
    public var characters: [UUID: CharacterState] = [:]
    public var effects: [EffectState] = []
    
    // Event stream for external services (like SharePlay) to observe
    // We use a PassthroughSubject to emit events only when they should be broadcast
    @ObservationIgnored
    public let eventSubject = PassthroughSubject<StoreEvent, Never>()
    
    public init() {}
    
    // MARK: - Character Reducers
    
    public func spawnCharacter(type: CharacterType, at position: SIMD3<Float> = .zero, scale: Float = 1.0, source: UpdateSource = .local) {
        let id = UUID()
        spawnCharacter(
            state: CharacterState(id: id, type: type, position: position, scale: scale),
            source: source
        )
    }
    
    public func spawnCharacter(state: CharacterState, source: UpdateSource = .local) {
        characters[state.id] = state
        print("Spawned character: \(state.type.rawValue) at \(state.position) [\(source)]")
        
        if source == .local {
            eventSubject.send(.characterSpawned(state))
        }
    }
    
    public func updateCharacter(id: UUID, position: SIMD3<Float>? = nil, scale: Float? = nil, rotation: simd_quatf? = nil, source: UpdateSource = .local) {
        guard var character = characters[id] else { return }
        
        if let position = position { character.position = position }
        if let scale = scale { character.scale = scale }
        if let rotation = rotation { character.rotation = rotation }
        
        characters[id] = character
        
        if source == .local {
            eventSubject.send(.characterUpdated(character))
        }
    }
    
    public func updateCharacterState(_ state: CharacterState, source: UpdateSource = .local) {
        // Full state replacement (usually from remote)
        characters[state.id] = state
        
        if source == .local {
            eventSubject.send(.characterUpdated(state))
        }
    }
    
    public func removeCharacter(id: UUID, source: UpdateSource = .local) {
        characters.removeValue(forKey: id)
        print("Removed character: \(id) [\(source)]")
        
        if source == .local {
            eventSubject.send(.characterRemoved(id))
        }
    }
    
    public func performAction(id: UUID, action: CharacterAction, source: UpdateSource = .local) {
        guard var character = characters[id] else { return }
        character.currentAction = action
        characters[id] = character
        
        print("Character \(id) performing action: \(action) [\(source)]")
        
        if source == .local {
            eventSubject.send(.actionTriggered(id, action))
            
            // Auto-reset to idle so the action can be triggered again
            if action != .idle {
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds reset
                    self.performAction(id: id, action: .idle, source: .local)
                }
            }
        }
    }
    
    public func setCharacterHidden(id: UUID, isHidden: Bool, source: UpdateSource = .local) {
        guard var character = characters[id] else { return }
        character.isHidden = isHidden
        characters[id] = character
        
        if source == .local {
            eventSubject.send(.characterUpdated(character))
        }
    }
    
    // MARK: - Effect Reducers
    
    public func spawnEffect(type: EffectType, at position: SIMD3<Float>, source: UpdateSource = .local) {
        let effect = EffectState(type: type, position: position)
        spawnEffect(state: effect, source: source)
    }
    
    public func spawnEffect(state: EffectState, source: UpdateSource = .local) {
        effects.append(state)
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64((state.duration + 0.5) * 1_000_000_000))
            await removeEffect(id: state.id)
        }
        
        print("Spawned effect: \(state.type) at \(state.position) [\(source)]")
        
        if source == .local {
            eventSubject.send(.effectSpawned(state))
        }
    }
    
    @MainActor
    private func removeEffect(id: UUID) {
        effects.removeAll { $0.id == id }
    }
    
    public func clearAll() {
        characters.removeAll()
        effects.removeAll()
    }
}
