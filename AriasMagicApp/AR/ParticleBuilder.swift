import Foundation
import RealityKit
import UIKit

@MainActor
public class ParticleBuilder {
    public static let shared = ParticleBuilder()
    
    private init() {}
    
    public func createEffectEntity(for type: EffectType) -> Entity {
        let root = Entity()
        
        switch type {
        case .sparkles:
            addSparkles(to: root)
        case .snow:
            addSnow(to: root)
        case .bubbles:
            addBubbles(to: root)
        }
        
        return root
    }
    
    private func addSparkles(to root: Entity) {
        // Create multiple small glowing spheres
        for _ in 0..<20 {
            let mesh = MeshResource.generateSphere(radius: 0.01)
            var material = UnlitMaterial(color: .yellow)
            material.blending = .transparent(opacity: 0.8)
            
            let particle = ModelEntity(mesh: mesh, materials: [material])
            particle.position = randomPosition(range: 0.3)
            root.addChild(particle)
            
            // Animate: Pulse and move up
            var transform = particle.transform
            transform.translation.y += 0.5
            transform.scale = .zero
            
            particle.move(to: transform, relativeTo: root, duration: 2.0, timingFunction: .easeOut)
        }
    }
    
    private func addSnow(to root: Entity) {
        for _ in 0..<30 {
            let mesh = MeshResource.generateSphere(radius: 0.005)
            let material = SimpleMaterial(color: .white, isMetallic: false)
            
            let particle = ModelEntity(mesh: mesh, materials: [material])
            // Start higher up
            var pos = randomPosition(range: 0.5)
            pos.y += 1.0
            particle.position = pos
            root.addChild(particle)
            
            // Animate: Fall down
            var transform = particle.transform
            transform.translation.y -= 1.5
            
            particle.move(to: transform, relativeTo: root, duration: 3.0, timingFunction: .linear)
        }
    }
    
    private func addBubbles(to root: Entity) {
        for _ in 0..<15 {
            let mesh = MeshResource.generateSphere(radius: Float.random(in: 0.02...0.05))
            var material = UnlitMaterial(color: .cyan)
            material.blending = .transparent(opacity: 0.4)
            
            let particle = ModelEntity(mesh: mesh, materials: [material])
            particle.position = randomPosition(range: 0.4)
            root.addChild(particle)
            
            // Animate: Float up and wobble
            var transform = particle.transform
            transform.translation.y += 0.8
            transform.translation.x += Float.random(in: -0.1...0.1)
            
            particle.move(to: transform, relativeTo: root, duration: 4.0, timingFunction: .easeOut)
        }
    }
    
    private func randomPosition(range: Float) -> SIMD3<Float> {
        return SIMD3<Float>(
            Float.random(in: -range...range),
            Float.random(in: -range...range),
            Float.random(in: -range...range)
        )
    }
}


