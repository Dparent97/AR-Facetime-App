import Foundation
import RealityKit
import ARKit
import Combine
import UIKit

public protocol ARSceneCoordinatorDelegate: AnyObject {
    func sceneDidRequestSpawn(at position: SIMD3<Float>)
    func sceneDidUpdateCharacter(id: UUID, position: SIMD3<Float>?, scale: Float?, rotation: simd_quatf?)
    func sceneDidSelectCharacter(id: UUID?)
    func sceneDidDetectExpression(_ expression: FaceExpression)
}

@MainActor
public class ARSceneController: NSObject, ARSessionDelegate {
    public let arView: ARView
    public weak var delegate: ARSceneCoordinatorDelegate?
    
    // Services
    private let faceTrackingService = FaceTrackingService()
    
    // State tracking
    private var characterEntities: [UUID: ModelEntity] = [:]
    private var characterLastActions: [UUID: CharacterAction] = [:]
    private var effectEntities: [UUID: Entity] = [:]
    private var selectedCharacterId: UUID?
    
    // Gesture recognizers
    private var currentGestureEntity: ModelEntity?
    private var initialGestureScale: Float = 1.0
    
    public init(arView: ARView? = nil) {
        self.arView = arView ?? ARView(frame: .zero)
        super.init()
        
        setupARSession()
        setupGestures()
        setupServices()
    }
    
    private func setupServices() {
        faceTrackingService.onExpressionDetected = { [weak self] expression in
            self?.delegate?.sceneDidDetectExpression(expression)
            
            // Feedback
            AudioService.shared.play(.faceTracking)
        }
    }
    
    private func setupARSession() {
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsUserFaceTracking {
            config.userFaceTrackingEnabled = true
        }
        config.planeDetection = [.horizontal]
        
        arView.session.delegate = self
        arView.session.run(config)
    }
    
    // MARK: - ARSessionDelegate
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                faceTrackingService.processFaceAnchor(faceAnchor)
            }
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }
    
    // MARK: - Sync with Store
    
    public func update(from store: CharacterStore) {
        // 1. Add new characters
        for (id, state) in store.characters {
            if characterEntities[id] == nil {
                spawnCharacter(state: state)
            }
        }
        
        // 2. Update existing characters
        for (id, entity) in characterEntities {
            guard let state = store.characters[id] else {
                // 3. Remove deleted characters
                removeCharacter(id: id)
                continue
            }
            
            updateCharacter(entity: entity, state: state)
        }
        
        // 4. Update Effects
        for effect in store.effects {
            if effectEntities[effect.id] == nil {
                spawnEffect(effect)
            }
        }
        
        // Cleanup expired effects
        for (id, _) in effectEntities {
            if !store.effects.contains(where: { $0.id == id }) {
                removeEffect(id: id)
            }
        }
    }
    
    private func spawnCharacter(state: CharacterState) {
        Task {
            let entity = await EntityFactory.shared.createEntity(for: state)
            
            // Add to anchor
            let anchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            
            characterEntities[state.id] = entity
            
            // Initial animation if any
            if state.currentAction != .idle {
                AnimationController.shared.playAnimation(on: entity, action: state.currentAction)
            }
        }
    }
    
    private func updateCharacter(entity: ModelEntity, state: CharacterState) {
        // Position/Scale updates
        if distance(entity.position, state.position) > 0.01 {
             entity.position = state.position
        }
        
        let scaleVec = SIMD3<Float>(repeating: state.scale)
        if distance(entity.scale, scaleVec) > 0.01 {
            entity.scale = scaleVec
        }
        
        // Actions
        if characterLastActions[state.id] != state.currentAction {
             AnimationController.shared.playAnimation(on: entity, action: state.currentAction)
             AudioService.shared.playForAction(state.currentAction)
             characterLastActions[state.id] = state.currentAction
        }
        
        entity.isEnabled = !state.isHidden
    }
    
    private func removeCharacter(id: UUID) {
        guard let entity = characterEntities[id] else { return }
        
        if let anchor = entity.parent as? AnchorEntity {
            arView.scene.removeAnchor(anchor)
        } else {
            entity.removeFromParent()
        }
        
        characterEntities.removeValue(forKey: id)
        characterLastActions.removeValue(forKey: id)
    }
    
    private func spawnEffect(_ state: EffectState) {
        let entity = ParticleBuilder.shared.createEffectEntity(for: state.type)
        
        // Add to anchor
        let anchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
        anchor.position = state.position
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        
        effectEntities[state.id] = entity
        
        // Play sound (mapped in AudioService)
        AudioService.shared.play(.sparkle) // Default fallback, or map types
    }
    
    private func removeEffect(id: UUID) {
        guard let entity = effectEntities[id] else { return }
        if let anchor = entity.parent as? AnchorEntity {
            arView.scene.removeAnchor(anchor)
        } else {
            entity.removeFromParent()
        }
        effectEntities.removeValue(forKey: id)
    }
    
    // MARK: - Gestures
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arView)
        
        if let entity = arView.entity(at: location) as? ModelEntity {
            // Find which character this is
            if let (id, _) = characterEntities.first(where: { $0.value == entity }) {
                selectedCharacterId = id
                delegate?.sceneDidSelectCharacter(id: id)
                
                // Feedback
                AnimationController.shared.playAnimation(on: entity, action: .jump)
            }
        } else {
            // Tap on empty space -> Request spawn
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            if let result = results.first {
                let position = SIMD3<Float>(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                delegate?.sceneDidRequestSpawn(at: position)
            }
        }
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let id = selectedCharacterId, let entity = characterEntities[id] else { return }
        
        if sender.state == .changed {
            let translation = sender.translation(in: arView)
            let scaleFactor: Float = 0.001
            
            var newPos = entity.position
            newPos.x += Float(translation.x) * scaleFactor
            newPos.z += Float(translation.y) * scaleFactor
            
            delegate?.sceneDidUpdateCharacter(id: id, position: newPos, scale: nil, rotation: nil)
            
            sender.setTranslation(.zero, in: arView)
        }
    }
    
    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let id = selectedCharacterId, let entity = characterEntities[id] else { return }
        
        if sender.state == .began {
            initialGestureScale = entity.scale.x
        } else if sender.state == .changed {
            let newScale = initialGestureScale * Float(sender.scale)
            delegate?.sceneDidUpdateCharacter(id: id, position: nil, scale: newScale, rotation: nil)
        }
    }
}
