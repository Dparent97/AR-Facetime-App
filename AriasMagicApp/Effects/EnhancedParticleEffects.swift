//
//  EnhancedParticleEffects.swift
//  Aria's Magic SharePlay App
//
//  Production-quality particle effects using RealityKit ParticleEmitterComponent
//

import Foundation
import RealityKit
import Combine

// MARK: - Enhanced Particle System

/// Enhanced particle effect generator with RealityKit particle systems
class EnhancedParticleEffects {

    // MARK: - Sparkle Effect

    /// Create an enhanced sparkle particle effect
    /// - Parameter position: Position to spawn the effect
    /// - Returns: Entity with particle emitter
    static func createSparkleEffect(at position: SIMD3<Float> = [0, 0, 0]) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        // Create particle emitter component
        var particleEmitter = ParticleEmitterComponent()

        // Main emitter properties
        particleEmitter.emitterShape = .sphere
        particleEmitter.emitterShapeSize = [0.05, 0.05, 0.05]
        particleEmitter.birthRate = 50
        particleEmitter.lifeSpan = 2.0
        particleEmitter.lifeSpanVariation = 0.5

        // Particle appearance
        particleEmitter.speed = 0.15
        particleEmitter.speedVariation = 0.05
        particleEmitter.color = .evolving(
            start: .constant(.init(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)), // Golden
            end: .constant(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0))     // Fade to transparent
        )

        // Particle size
        particleEmitter.size = 0.01
        particleEmitter.sizeVariation = 0.005

        // Motion
        particleEmitter.acceleration = [0, 0.1, 0] // Float upward
        particleEmitter.angularSpeed = .random(in: -2...2)

        // Blending for glow effect
        particleEmitter.blendMode = .additive

        // Burst configuration
        particleEmitter.burstCount = 100
        particleEmitter.burstCountVariation = 20
        particleEmitter.isEmitting = true

        // Add component to entity
        particleEntity.components.set(particleEmitter)

        // Auto-cleanup after effect completes
        autoCleanup(entity: particleEntity, after: 3.0)

        return particleEntity
    }

    // MARK: - Snow Effect

    /// Create an enhanced snow particle effect
    /// - Parameter position: Position to spawn the effect (usually above camera)
    /// - Returns: Entity with particle emitter
    static func createSnowEffect(at position: SIMD3<Float> = [0, 1.0, 0]) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        // Create particle emitter component
        var particleEmitter = ParticleEmitterComponent()

        // Emitter shape - wide horizontal plane
        particleEmitter.emitterShape = .plane
        particleEmitter.emitterShapeSize = [2.0, 0.01, 2.0] // Wide horizontal area

        // Emission properties
        particleEmitter.birthRate = 100
        particleEmitter.lifeSpan = 5.0
        particleEmitter.lifeSpanVariation = 1.0

        // Particle appearance - white snowflakes
        particleEmitter.color = .constant(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))

        // Particle size
        particleEmitter.size = 0.005
        particleEmitter.sizeVariation = 0.003

        // Motion - gentle falling with drift
        particleEmitter.speed = 0.1
        particleEmitter.speedVariation = 0.05
        particleEmitter.acceleration = [0, -0.15, 0] // Fall downward

        // Add gentle side-to-side drift using angle variation
        particleEmitter.angle = .random(in: -.pi/8...(.pi/8))
        particleEmitter.angularSpeed = .random(in: -1...1) // Gentle rotation

        // Blending
        particleEmitter.blendMode = .alpha

        // Continuous emission
        particleEmitter.isEmitting = true

        // Add component to entity
        particleEntity.components.set(particleEmitter)

        // Snow continues until manually stopped
        // Auto-cleanup after 10 seconds
        autoCleanup(entity: particleEntity, after: 10.0)

        return particleEntity
    }

    // MARK: - Bubble Effect

    /// Create an enhanced bubble particle effect
    /// - Parameter position: Position to spawn the effect (usually at ground level)
    /// - Returns: Entity with particle emitter
    static func createBubbleEffect(at position: SIMD3<Float> = [0, 0, 0]) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        // Create particle emitter component
        var particleEmitter = ParticleEmitterComponent()

        // Emitter shape - point source at bottom
        particleEmitter.emitterShape = .point
        particleEmitter.birthRate = 30
        particleEmitter.lifeSpan = 3.0
        particleEmitter.lifeSpanVariation = 1.0

        // Particle appearance - translucent cyan bubbles with rainbow tint
        particleEmitter.color = .evolving(
            start: .constant(.init(red: 0.5, green: 0.9, blue: 1.0, alpha: 0.5)),  // Cyan semi-transparent
            end: .constant(.init(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.0))     // Purple fade out
        )

        // Variable bubble sizes
        particleEmitter.size = 0.03
        particleEmitter.sizeVariation = 0.02

        // Size evolution - bubbles grow slightly then pop
        particleEmitter.sizeMultiplier = .evolving(
            start: .constant(0.5),
            end: .constant(1.2)
        )

        // Motion - rise with wobble
        particleEmitter.speed = 0.2
        particleEmitter.speedVariation = 0.1
        particleEmitter.acceleration = [0, 0.2, 0] // Float upward

        // Wobble motion using angle variation
        particleEmitter.angle = .random(in: 0...(2 * .pi))
        particleEmitter.angularSpeed = .random(in: -0.5...0.5)

        // Blending - alpha for translucency
        particleEmitter.blendMode = .alpha

        // Continuous emission
        particleEmitter.isEmitting = true

        // Add component to entity
        particleEntity.components.set(particleEmitter)

        // Auto-cleanup after effect
        autoCleanup(entity: particleEntity, after: 8.0)

        return particleEntity
    }

    // MARK: - Helper Methods

    /// Auto-cleanup particle entity after duration
    /// - Parameters:
    ///   - entity: The particle entity
    ///   - duration: Duration in seconds before cleanup
    private static func autoCleanup(entity: Entity, after duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            // Stop emitting first
            if var emitter = entity.components[ParticleEmitterComponent.self] {
                emitter.isEmitting = false
                entity.components.set(emitter)
            }

            // Remove entity after particles fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                entity.removeFromParent()
            }
        }
    }

    /// Manually stop a particle effect
    /// - Parameter entity: The particle entity to stop
    static func stopEffect(_ entity: Entity) {
        if var emitter = entity.components[ParticleEmitterComponent.self] {
            emitter.isEmitting = false
            entity.components.set(emitter)
        }
    }

    /// Resume a stopped particle effect
    /// - Parameter entity: The particle entity to resume
    static func resumeEffect(_ entity: Entity) {
        if var emitter = entity.components[ParticleEmitterComponent.self] {
            emitter.isEmitting = true
            entity.components.set(emitter)
        }
    }
}

// MARK: - Particle Effect Factory

/// Factory for creating particle effects with different configurations
class ParticleEffectFactory {

    /// Create a particle effect for the given magic effect type
    /// - Parameters:
    ///   - effectType: The type of magic effect
    ///   - position: Position in AR space
    /// - Returns: Entity with particle emitter
    static func createEffect(_ effectType: MagicEffect, at position: SIMD3<Float> = [0, 0, 0]) -> Entity {
        switch effectType {
        case .sparkles:
            return EnhancedParticleEffects.createSparkleEffect(at: position)
        case .snow:
            return EnhancedParticleEffects.createSnowEffect(at: position)
        case .bubbles:
            return EnhancedParticleEffects.createBubbleEffect(at: position)
        }
    }

    /// Create a character spawn effect (magical poof)
    /// - Parameter position: Spawn position
    /// - Returns: Entity with particle emitter
    static func createSpawnEffect(at position: SIMD3<Float>) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        var particleEmitter = ParticleEmitterComponent()

        // Burst of sparkles for spawn
        particleEmitter.emitterShape = .sphere
        particleEmitter.emitterShapeSize = [0.1, 0.1, 0.1]

        particleEmitter.birthRate = 0 // Burst only
        particleEmitter.burstCount = 150
        particleEmitter.burstCountVariation = 30

        particleEmitter.lifeSpan = 1.0
        particleEmitter.lifeSpanVariation = 0.3

        // Rainbow colors for magical spawn
        particleEmitter.color = .evolving(
            start: .constant(.init(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0)), // Magenta
            end: .constant(.init(red: 0.5, green: 1.0, blue: 1.0, alpha: 0.0))    // Cyan fade
        )

        particleEmitter.size = 0.008
        particleEmitter.sizeVariation = 0.004

        particleEmitter.speed = 0.3
        particleEmitter.speedVariation = 0.15

        particleEmitter.blendMode = .additive
        particleEmitter.isEmitting = true

        particleEntity.components.set(particleEmitter)

        EnhancedParticleEffects.autoCleanup(entity: particleEntity, after: 2.0)

        return particleEntity
    }

    /// Create a character action effect (for sparkle action)
    /// - Parameter position: Action position
    /// - Returns: Entity with particle emitter
    static func createActionSparkleEffect(at position: SIMD3<Float>) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        var particleEmitter = ParticleEmitterComponent()

        // Wand sparkle effect
        particleEmitter.emitterShape = .cone
        particleEmitter.emitterShapeSize = [0.05, 0.15, 0.05]

        particleEmitter.birthRate = 200
        particleEmitter.lifeSpan = 1.0

        particleEmitter.color = .constant(.init(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0))

        particleEmitter.size = 0.006
        particleEmitter.speed = 0.4
        particleEmitter.acceleration = [0, 0.1, 0]

        particleEmitter.blendMode = .additive
        particleEmitter.isEmitting = true

        particleEntity.components.set(particleEmitter)

        EnhancedParticleEffects.autoCleanup(entity: particleEntity, after: 1.5)

        return particleEntity
    }
}

// MARK: - Particle Effect Manager

/// Manager for tracking and controlling active particle effects
class ParticleEffectManager {
    static let shared = ParticleEffectManager()

    private var activeEffects: [UUID: Entity] = [:]

    private init() {}

    /// Spawn a new particle effect
    /// - Parameters:
    ///   - effectType: Type of effect to spawn
    ///   - position: Position in AR space
    ///   - parent: Parent entity to attach to
    /// - Returns: UUID of the spawned effect
    @discardableResult
    func spawnEffect(_ effectType: MagicEffect, at position: SIMD3<Float>, parent: Entity) -> UUID {
        let effectEntity = ParticleEffectFactory.createEffect(effectType, at: position)
        let id = UUID()

        parent.addChild(effectEntity)
        activeEffects[id] = effectEntity

        return id
    }

    /// Stop and remove a specific effect
    /// - Parameter id: UUID of the effect to remove
    func removeEffect(id: UUID) {
        guard let entity = activeEffects[id] else { return }

        EnhancedParticleEffects.stopEffect(entity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            entity.removeFromParent()
            self.activeEffects.removeValue(forKey: id)
        }
    }

    /// Stop all active effects
    func stopAllEffects() {
        for (id, entity) in activeEffects {
            EnhancedParticleEffects.stopEffect(entity)
            entity.removeFromParent()
        }
        activeEffects.removeAll()
    }

    /// Get count of active effects
    var activeEffectCount: Int {
        return activeEffects.count
    }
}
