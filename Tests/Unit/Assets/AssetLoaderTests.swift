import XCTest
import RealityKit
@testable import AriasMagicApp

final class AssetLoaderTests: XCTestCase {
    
    @MainActor
    func testLoadCharacterPlaceholder() async throws {
        let loader = AssetLoader.shared
        
        // Since we only have placeholders enabled in Phase 1, this should succeed and return a box
        let entity = try await loader.loadCharacter(type: .sparkleThePrincess)
        
        XCTAssertNotNil(entity)
        XCTAssertNotNil(entity.model) // Should have a mesh
    }
    
    @MainActor
    func testCacheWorks() async throws {
        let loader = AssetLoader.shared
        loader.clearCache()
        
        let entity1 = try await loader.loadCharacter(type: .lunaTheStarDancer)
        // Modifying the first entity shouldn't affect the cache if we clone it, 
        // but cache stores the source.
        
        let entity2 = try await loader.loadCharacter(type: .lunaTheStarDancer)
        
        // Entities returned are clones, so they are different instances
        XCTAssertNotEqual(ObjectIdentifier(entity1), ObjectIdentifier(entity2))
        
        // But they should have same structure
        XCTAssertEqual(entity1.name, entity2.name)
    }
}

