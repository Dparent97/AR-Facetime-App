import Foundation
import RealityKit

@MainActor
public class AnimationController {
    public static let shared = AnimationController()
    
    private init() {}
    
    public func playAnimation(on entity: Entity, action: CharacterAction) {
        // Check for skeletal animation support in Phase 3
        // For now, use transform animations (placeholder)
        
        switch action {
        case .idle:
            // Stop animations or reset to idle pose
            break
            
        case .wave:
            animateWave(entity)
            
        case .dance:
            animateDance(entity)
            
        case .twirl:
            animateTwirl(entity)
            
        case .jump:
            animateJump(entity)
            
        case .sparkle:
            animateSparkle(entity)
        }
    }
    
    private func animateWave(_ entity: Entity) {
        // Simple rotation wiggle
        let currentRotation = entity.transform.rotation
        let left = simd_mul(currentRotation, simd_quatf(angle: .pi / 6, axis: [0, 0, 1]))
        let right = simd_mul(currentRotation, simd_quatf(angle: -.pi / 6, axis: [0, 0, 1]))
        
        var transform = entity.transform
        transform.rotation = left
        
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeInOut)
        
        // We would need a sequence here. RealityKit's move(to:) is fire-and-forget.
        // For robust animations, we'd use AnimationResource or a custom sequencer.
        // For Phase 1 placeholder: just one move.
    }
    
    private func animateDance(_ entity: Entity) {
        // Hop up
        var transform = entity.transform
        transform.translation.y += 0.1
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeInOut)
    }
    
    private func animateTwirl(_ entity: Entity) {
        // 360 spin
        let currentRotation = entity.transform.rotation
        let spin = simd_mul(currentRotation, simd_quatf(angle: .pi, axis: [0, 1, 0]))
        
        var transform = entity.transform
        transform.rotation = spin
        
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.5, timingFunction: .linear)
    }
    
    private func animateJump(_ entity: Entity) {
         var transform = entity.transform
         transform.translation.y += 0.2
         entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeOut)
    }
    
    private func animateSparkle(_ entity: Entity) {
        // Pulse scale
        var transform = entity.transform
        transform.scale *= 1.2
        entity.move(to: transform, relativeTo: entity.parent, duration: 0.3, timingFunction: .easeInOut)
    }
}

