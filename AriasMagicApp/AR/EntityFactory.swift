import Foundation
import RealityKit

@MainActor
public class EntityFactory {
    public static let shared = EntityFactory()
    
    private init() {}
    
    public func createEntity(for state: CharacterState) async -> ModelEntity {
        let entity: ModelEntity
        do {
            entity = try await AssetLoader.shared.loadCharacter(type: state.type)
        } catch {
            print("Failed to load entity for \(state.type): \(error)")
            // Fallback handled by AssetLoader for now, but double safety:
            entity = ModelEntity(mesh: .generateBox(size: 0.1), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        }
        
        // Apply state
        entity.name = state.id.uuidString
        entity.position = state.position
        entity.scale = SIMD3<Float>(repeating: state.scale)
        entity.orientation = state.rotation
        
        return entity
    }
}

