//
//  MagicEffect.swift
//  Aria's Magic SharePlay App
//
//  Magic effects like sparkles, snow, bubbles
//

import Foundation
import RealityKit

enum MagicEffect: String, CaseIterable, Codable {
    case sparkles
    case snow
    case bubbles

    var displayName: String {
        switch self {
        case .sparkles: return "✨ Sparkles"
        case .snow: return "❄️ Snow"
        case .bubbles: return "🫧 Bubbles"
        }
    }

    var emoji: String {
        switch self {
        case .sparkles: return "✨"
        case .snow: return "❄️"
        case .bubbles: return "🫧"
        }
    }
}

class MagicEffectGenerator {
    static func createParticleEffect(for effect: MagicEffect) -> Entity {
        let particleEntity = Entity()

        // Create particle emitter based on effect type
        // Note: In production, you'd use RealityKit's particle system
        // For now, we'll create simple visual representations

        switch effect {
        case .sparkles:
            createSparkles(in: particleEntity)
        case .snow:
            createSnow(in: particleEntity)
        case .bubbles:
            createBubbles(in: particleEntity)
        }

        return particleEntity
    }

    private static func createSparkles(in entity: Entity) {
        // Create small glowing spheres
        for _ in 0..<20 {
            let mesh = MeshResource.generateSphere(radius: 0.01)
            var material = UnlitMaterial(color: .yellow)
            material.blending = .transparent(opacity: 0.8)

            let sphere = ModelEntity(mesh: mesh, materials: [material])
            sphere.position = randomPosition()
            entity.addChild(sphere)

            // Animate
            animateParticle(sphere, duration: 2.0)
        }
    }

    private static func createSnow(in entity: Entity) {
        // Create white falling particles
        for _ in 0..<30 {
            let mesh = MeshResource.generateSphere(radius: 0.005)
            let material = SimpleMaterial(color: .white, isMetallic: false)

            let sphere = ModelEntity(mesh: mesh, materials: [material])
            sphere.position = randomPosition(yRange: 0.5...1.0)
            entity.addChild(sphere)

            // Animate falling
            animateFalling(sphere, duration: 3.0)
        }
    }

    private static func createBubbles(in entity: Entity) {
        // Create transparent spheres
        for _ in 0..<15 {
            let mesh = MeshResource.generateSphere(radius: Float.random(in: 0.02...0.05))
            var material = UnlitMaterial(color: .cyan)
            material.blending = .transparent(opacity: 0.3)

            let sphere = ModelEntity(mesh: mesh, materials: [material])
            sphere.position = randomPosition()
            entity.addChild(sphere)

            // Animate floating up
            animateFloating(sphere, duration: 4.0)
        }
    }

    private static func randomPosition(yRange: ClosedRange<Float> = -0.2...0.2) -> SIMD3<Float> {
        return SIMD3<Float>(
            Float.random(in: -0.3...0.3),
            Float.random(in: yRange),
            Float.random(in: -0.3...0.3)
        )
    }

    private static func animateParticle(_ entity: ModelEntity, duration: Float) {
        var transform = entity.transform
        transform.translation.y += 0.3
        transform.scale = [0, 0, 0]
        entity.move(to: transform, relativeTo: entity.parent, duration: TimeInterval(duration))
    }

    private static func animateFalling(_ entity: ModelEntity, duration: Float) {
        var transform = entity.transform
        transform.translation.y -= 1.0
        entity.move(to: transform, relativeTo: entity.parent, duration: TimeInterval(duration))
    }

    private static func animateFloating(_ entity: ModelEntity, duration: Float) {
        var transform = entity.transform
        transform.translation.y += 1.0
        entity.move(to: transform, relativeTo: entity.parent, duration: TimeInterval(duration))
    }
}
