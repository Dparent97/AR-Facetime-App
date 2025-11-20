import Foundation
import Observation
import simd

@Observable
public class CharacterStore {
    public var characters: [UUID: CharacterState] = [:]
    public var effects: [EffectState] = []
    
    public init() {}
    
    // MARK: - Character Reducers
    
    public func spawnCharacter(type: CharacterType, at position: SIMD3<Float> = .zero, scale: Float = 1.0) {
        let id = UUID()
        let newCharacter = CharacterState(
            id: id,
            type: type,
            position: position,
            scale: scale
        )
        characters[id] = newCharacter
        print("Spawned character: \(type.rawValue) at \(position)")
    }
    
    public func updateCharacter(id: UUID, position: SIMD3<Float>? = nil, scale: Float? = nil, rotation: simd_quatf? = nil) {
        guard var character = characters[id] else { return }
        
        if let position = position {
            character.position = position
        }
        if let scale = scale {
            character.scale = scale
        }
        if let rotation = rotation {
            character.rotation = rotation
        }
        
        characters[id] = character
    }
    
    public func removeCharacter(id: UUID) {
        characters.removeValue(forKey: id)
        print("Removed character: \(id)")
    }
    
    public func performAction(id: UUID, action: CharacterAction) {
        guard var character = characters[id] else { return }
        character.currentAction = action
        characters[id] = character
        
        // If action is temporary, we might want to reset it later, 
        // but the domain just records the current state. 
        // The AR layer will observe this and play animation.
        // We should probably reset it to idle after some time?
        // Or better, the AR layer signals when animation is done.
        // For now, let's leave it as setting the state.
        
        print("Character \(id) performing action: \(action)")
    }
    
    public func setCharacterHidden(id: UUID, isHidden: Bool) {
        guard var character = characters[id] else { return }
        character.isHidden = isHidden
        characters[id] = character
    }
    
    // MARK: - Effect Reducers
    
    public func spawnEffect(type: EffectType, at position: SIMD3<Float>) {
        let effect = EffectState(type: type, position: position)
        effects.append(effect)
        
        // Auto-cleanup after duration + buffer
        // Note: In a real app, we might use a Timer or Task.
        // Since this is a store, we can use a Task.
        Task {
            try? await Task.sleep(nanoseconds: UInt64((effect.duration + 0.5) * 1_000_000_000))
            await removeEffect(id: effect.id)
        }
        
        print("Spawned effect: \(type) at \(position)")
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

