import SwiftUI
import RealityKit
import ARKit

struct ARContainerView: UIViewRepresentable {
    @Bindable var store: CharacterStore
    @Binding var selectedCharacterType: CharacterType
    @Binding var selectedCharacterID: UUID?
    
    let sceneController: ARSceneController
    
    func makeUIView(context: Context) -> ARView {
        // Assign delegate to coordinator to handle gestures
        sceneController.delegate = context.coordinator
        return sceneController.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Sync store state to scene controller
        sceneController.update(from: store)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSceneCoordinatorDelegate {
        var parent: ARContainerView
        
        init(_ parent: ARContainerView) {
            self.parent = parent
        }
        
        func sceneDidRequestSpawn(at position: SIMD3<Float>) {
            // Spawn the currently selected type
            parent.store.spawnCharacter(type: parent.selectedCharacterType, at: position)
        }
        
        func sceneDidUpdateCharacter(id: UUID, position: SIMD3<Float>?, scale: Float?, rotation: simd_quatf?) {
            parent.store.updateCharacter(id: id, position: position, scale: scale, rotation: rotation)
        }
        
        func sceneDidSelectCharacter(id: UUID?) {
            // Update UI selection
            DispatchQueue.main.async {
                self.parent.selectedCharacterID = id
            }
        }
        
        func sceneDidDetectExpression(_ expression: FaceExpression) {
            // Map expression to action
            let action: CharacterAction
            switch expression {
            case .smile: action = .wave
            case .eyebrowsRaised: action = .jump
            case .mouthOpen: action = .sparkle
            }
            
            // Apply to selected character or all?
            // Let's apply to selected for now
            if let id = parent.selectedCharacterID {
                parent.store.performAction(id: id, action: action)
            } else {
                // Fallback: Apply to first character if any
                if let firstId = parent.store.characters.keys.first {
                    parent.store.performAction(id: firstId, action: action)
                }
            }
        }
    }
}

