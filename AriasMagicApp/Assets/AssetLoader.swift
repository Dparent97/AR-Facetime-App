import Foundation
import RealityKit
import UIKit

@MainActor
public class AssetLoader {
    public static let shared = AssetLoader()
    
    private var cache: [String: ModelEntity] = [:]
    
    private init() {}
    
    public func loadCharacter(type: CharacterType) async throws -> ModelEntity {
        let asset = AssetCatalog.character(type)
        let cacheKey = asset.resourceName
        
        if let cached = cache[cacheKey] {
            return cached.clone(recursive: true)
        }
        
        // Try loading from bundle (placeholder for now just generates box)
        // In Phase 3, we will actually try `ModelEntity.loadModel`
        
        // Check if file exists in bundle (mock check for now)
        let fileExists = false 
        
        if fileExists {
            // Real loading logic would go here
            // let entity = try await ModelEntity.loadModel(named: asset.resourceName)
            // cache[cacheKey] = entity
            // return entity.clone(recursive: true)
            throw AssetError.fileNotFound(asset.resourceName)
        } else {
            // Fallback to placeholder
            let entity = createPlaceholder(for: asset)
            cache[cacheKey] = entity
            return entity.clone(recursive: true)
        }
    }
    
    private func createPlaceholder(for asset: AssetCatalog) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: 0.2) // 20cm box
        let material = SimpleMaterial(color: asset.placeholderColor, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = asset.resourceName
        
        // Add collision for gestures
        entity.generateCollisionShapes(recursive: true)
        
        return entity
    }
    
    public func clearCache() {
        cache.removeAll()
    }
}

public enum AssetError: Error {
    case fileNotFound(String)
    case corruptData
}

