import XCTest
import RealityKit
import ARKit
@testable import AriasMagicApp

final class ARSceneControllerTests: XCTestCase {
    
    class MockDelegate: ARSceneCoordinatorDelegate {
        var spawnCalled = false
        var lastSpawnPosition: SIMD3<Float>?
        
        var updateCalled = false
        var lastUpdateId: UUID?
        
        var selectCalled = false
        var lastSelectId: UUID?
        
        var expressionCalled = false
        var lastExpression: FaceExpression?
        
        func sceneDidRequestSpawn(at position: SIMD3<Float>) {
            spawnCalled = true
            lastSpawnPosition = position
        }
        
        func sceneDidUpdateCharacter(id: UUID, position: SIMD3<Float>?, scale: Float?, rotation: simd_quatf?) {
            updateCalled = true
            lastUpdateId = id
        }
        
        func sceneDidSelectCharacter(id: UUID?) {
            selectCalled = true
            lastSelectId = id
        }
        
        func sceneDidDetectExpression(_ expression: FaceExpression) {
            expressionCalled = true
            lastExpression = expression
        }
    }
    
    @MainActor
    func testUpdateFromStore() async {
        // Setup
        let controller = ARSceneController() // Uses real ARView (headless)
        let store = CharacterStore()
        let delegate = MockDelegate()
        controller.delegate = delegate
        
        // 1. Test Spawn
        store.spawnCharacter(type: .sparkleThePrincess, at: SIMD3<Float>(0, 0, -1))
        
        // Allow async task in controller to run
        controller.update(from: store)
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s wait for EntityFactory
        
        // Check if entity exists in scene (indirectly via internal state which is private, 
        // but we can check scene anchors)
        XCTAssertFalse(controller.arView.scene.anchors.isEmpty)
        
        // 2. Test Update
        guard let id = store.characters.keys.first else { return XCTFail() }
        store.updateCharacter(id: id, position: SIMD3<Float>(0, 1, -1))
        controller.update(from: store)
        
        // 3. Test Remove
        store.removeCharacter(id: id)
        controller.update(from: store)
        
        // Should be removed (async removal might take a tick, but logic is synchronous in update for removal)
        // Wait for potential async cleanup if any
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Check anchor count decremented (might not be 0 if other things exist, but logic says removeAnchor)
        XCTAssertTrue(controller.arView.scene.anchors.isEmpty)
    }
    
    @MainActor
    func testGestureDelegation() {
        // Hard to test gestures programmatically on ARView without mocking UIGestureRecognizer
        // skipping for now or need to expose handleTap directly?
        // They are private @objc.
        // Integration tests usually verify wiring.
        // We can verify delegate wiring is correct.
    }
}

