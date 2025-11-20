//
//  EnhancedParticleEffects.swift
//  Aria's Magic SharePlay App
//
//  Production-quality particle systems using RealityKit
//  TODO: Implement in Phase 2 with iOS 18.0+ particle system APIs
//

import Foundation
import RealityKit
import Combine
import UIKit

/// Enhanced particle effect generator with RealityKit particle systems
/// Note: Stubbed for Phase 1. Full implementation requires iOS 18.0+ APIs.
@available(iOS 18.0, *)
class EnhancedParticleEffects {

    // MARK: - Sparkle Particle System

    /// Create enhanced sparkle particle effect
    /// - Parameters:
    ///   - position: Position to emit particles from
    ///   - intensity: Particle emission intensity (0.0 to 1.0)
    /// - Returns: Entity with particle emitter attached
    static func createSparkleEffect(at position: SIMD3<Float> = [0, 0, 0], intensity: Float = 1.0) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        // Create particle emitter component
        var particleEmitter = ParticleEmitterComponent()

        // Main emitter properties
        particleEmitter.emitterShape = .sphere
        particleEmitter.emitterShapeSize = [0.1, 0.1, 0.1]
        particleEmitter.birthRate = 50 * intensity
        particleEmitter.lifeSpan = 2.0
        particleEmitter.lifeSpanVariation = 0.5

        // Particle appearance
        particleEmitter.speed = 0.15
        particleEmitter.speedVariation = 0.05

        // Color animation (golden sparkles with fade)
        particleEmitter.color = .evolving(
            start: .constant(.init(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)),
            end: .constant(.init(red: 1.0, green: 0.7, blue: 0.0, alpha: 0.0))
        )

        // Size animation (start small, grow, then shrink)
        particleEmitter.size = 0.02
        particleEmitter.sizeVariation = 0.01

        // Movement
        particleEmitter.acceleration = [0, 0.05, 0] // Float upward

        // Rotation
        particleEmitter.angularSpeed = .init(x: 0, y: 2.0, z: 0)

        // Blending mode for glow effect
        particleEmitter.blendMode = .additive

        // Apply to entity
        particleEntity.components[ParticleEmitterComponent.self] = particleEmitter

        // Auto-cleanup after duration
        scheduleCleanup(for: particleEntity, after: 3.0)

        return particleEntity
    }

    // MARK: - Snow Particle System

    /// Create enhanced snow particle effect
    /// - Parameters:
    ///   - position: Position to emit particles from (typically above camera)
    ///   - intensity: Particle emission intensity (0.0 to 1.0)
    /// - Returns: Entity with particle emitter attached
    static func createSnowEffect(at position: SIMD3<Float> = [0, 1.5, 0], intensity: Float = 1.0) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        // Create particle emitter component
        var particleEmitter = ParticleEmitterComponent()

        // Emitter properties - wide area above
        particleEmitter.emitterShape = .box
        particleEmitter.emitterShapeSize = [2.0, 0.1, 2.0] // Wide horizontal area
        particleEmitter.birthRate = 100 * intensity
        particleEmitter.lifeSpan = 5.0
        particleEmitter.lifeSpanVariation = 1.0

        // Particle appearance - white snowflakes
        particleEmitter.speed = 0.0 // No initial speed, just falls
        particleEmitter.speedVariation = 0.0

        // Color - pure white with slight transparency
        particleEmitter.color = .constant(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))

        // Size - small snowflakes
        particleEmitter.size = 0.008
        particleEmitter.sizeVariation = 0.004

        // Movement - fall gently with drift
        particleEmitter.acceleration = [0, -0.15, 0] // Gentle fall

        // Add subtle horizontal drift
        particleEmitter.vortexStrength = 0.05

        // Rotation - gentle tumbling
        particleEmitter.angularSpeed = .init(x: 0.5, y: 0.5, z: 0.5)

        // Blending mode
        particleEmitter.blendMode = .alpha

        // Apply to entity
        particleEntity.components[ParticleEmitterComponent.self] = particleEmitter

        // Snow doesn't auto-cleanup (continuous effect)
        // Call stopEffect() to remove manually

        return particleEntity
    }

    // MARK: - Bubble Particle System

    /// Create enhanced bubble particle effect
    /// - Parameters:
    ///   - position: Position to emit particles from (typically ground level)
    ///   - intensity: Particle emission intensity (0.0 to 1.0)
    /// - Returns: Entity with particle emitter attached
    static func createBubbleEffect(at position: SIMD3<Float> = [0, 0, 0], intensity: Float = 1.0) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        // Create particle emitter component
        var particleEmitter = ParticleEmitterComponent()

        // Emitter properties
        particleEmitter.emitterShape = .sphere
        particleEmitter.emitterShapeSize = [0.2, 0.05, 0.2] // Flat disc at ground
        particleEmitter.birthRate = 15 * intensity
        particleEmitter.lifeSpan = 3.0
        particleEmitter.lifeSpanVariation = 1.0

        // Particle appearance
        particleEmitter.speed = 0.1
        particleEmitter.speedVariation = 0.05

        // Color - translucent cyan with rainbow reflections
        particleEmitter.color = .evolving(
            start: .constant(.init(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.4)),
            end: .constant(.init(red: 0.7, green: 0.6, blue: 1.0, alpha: 0.1))
        )

        // Size - varied bubble sizes
        particleEmitter.size = 0.04
        particleEmitter.sizeVariation = 0.02

        // Movement - float upward with wobble
        particleEmitter.acceleration = [0, 0.2, 0] // Rise up

        // Add wobble effect
        particleEmitter.vortexStrength = 0.1

        // No rotation (bubbles don't tumble)
        particleEmitter.angularSpeed = .init(x: 0, y: 0, z: 0)

        // Blending mode
        particleEmitter.blendMode = .alpha

        // Apply to entity
        particleEntity.components[ParticleEmitterComponent.self] = particleEmitter

        // Auto-cleanup after duration
        scheduleCleanup(for: particleEntity, after: 5.0)

        return particleEntity
    }

    // MARK: - Advanced Effects

    /// Create a burst effect (one-time explosion of particles)
    /// - Parameters:
    ///   - position: Center of burst
    ///   - color: Particle color
    ///   - count: Number of particles to emit
    /// - Returns: Entity with burst effect
    static func createBurstEffect(
        at position: SIMD3<Float>,
        color: UIColor,
        count: Int = 30
    ) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        var particleEmitter = ParticleEmitterComponent()

        // One-time burst
        particleEmitter.emitterShape = .point
        particleEmitter.birthRate = Float(count) / 0.1 // All particles in 0.1 seconds
        particleEmitter.lifeSpan = 1.0
        particleEmitter.lifeSpanVariation = 0.3

        // Explosive outward motion
        particleEmitter.speed = 0.5
        particleEmitter.speedVariation = 0.3

        // Color from parameter
        let rgbaColor = color.rgba()
        particleEmitter.color = .evolving(
            start: .constant(.init(
                red: Double(rgbaColor.red),
                green: Double(rgbaColor.green),
                blue: Double(rgbaColor.blue),
                alpha: 1.0
            )),
            end: .constant(.init(
                red: Double(rgbaColor.red),
                green: Double(rgbaColor.green),
                blue: Double(rgbaColor.blue),
                alpha: 0.0
            ))
        )

        particleEmitter.size = 0.015
        particleEmitter.sizeVariation = 0.005

        // Gravity
        particleEmitter.acceleration = [0, -0.3, 0]

        particleEmitter.blendMode = .additive

        particleEntity.components[ParticleEmitterComponent.self] = particleEmitter

        // Stop emitting after burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            particleEmitter.birthRate = 0
            particleEntity.components[ParticleEmitterComponent.self] = particleEmitter
        }

        // Cleanup after particles die
        scheduleCleanup(for: particleEntity, after: 2.0)

        return particleEntity
    }

    /// Create trail effect (follows a moving object)
    /// - Parameters:
    ///   - position: Starting position
    ///   - color: Trail color
    /// - Returns: Entity with trail effect
    static func createTrailEffect(at position: SIMD3<Float>, color: UIColor = .white) -> Entity {
        let particleEntity = Entity()
        particleEntity.position = position

        var particleEmitter = ParticleEmitterComponent()

        // Continuous low-rate emission
        particleEmitter.emitterShape = .point
        particleEmitter.birthRate = 20
        particleEmitter.lifeSpan = 0.5
        particleEmitter.lifeSpanVariation = 0.1

        // Minimal speed (particles stay near emission point)
        particleEmitter.speed = 0.02
        particleEmitter.speedVariation = 0.01

        let rgbaColor = color.rgba()
        particleEmitter.color = .evolving(
            start: .constant(.init(
                red: Double(rgbaColor.red),
                green: Double(rgbaColor.green),
                blue: Double(rgbaColor.blue),
                alpha: 0.8
            )),
            end: .constant(.init(
                red: Double(rgbaColor.red),
                green: Double(rgbaColor.green),
                blue: Double(rgbaColor.blue),
                alpha: 0.0
            ))
        )

        particleEmitter.size = 0.01
        particleEmitter.sizeVariation = 0.003

        // No gravity for trail
        particleEmitter.acceleration = [0, 0, 0]

        particleEmitter.blendMode = .additive

        particleEntity.components[ParticleEmitterComponent.self] = particleEmitter

        return particleEntity
    }

    // MARK: - Effect Control

    /// Stop particle emission (but let existing particles finish)
    static func stopEffect(_ entity: Entity) {
        guard var emitter = entity.components[ParticleEmitterComponent.self] else { return }
        emitter.birthRate = 0
        entity.components[ParticleEmitterComponent.self] = emitter
    }

    /// Immediately remove all particles
    static func clearEffect(_ entity: Entity) {
        entity.components[ParticleEmitterComponent.self] = nil
    }

    /// Schedule automatic cleanup of entity
    private static func scheduleCleanup(for entity: Entity, after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            entity.removeFromParent()
        }
    }
}

// MARK: - Helper Extensions

extension UIColor {
    /// Get RGBA components as tuple
    func rgba() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

// MARK: - Particle Effect Manager

/// Manages active particle effects in the scene
class ParticleEffectManager {
    static let shared = ParticleEffectManager()

    private var activeEffects: [UUID: Entity] = [:]
    private let effectLock = NSLock()

    private init() {}

    /// Add a particle effect to the scene
    /// - Parameters:
    ///   - effect: The effect type to create
    ///   - position: Position in world space
    ///   - parent: Parent entity to attach to
    /// - Returns: UUID for tracking this effect
    @discardableResult
    func addEffect(_ effect: MagicEffect, at position: SIMD3<Float>, to parent: Entity) -> UUID {
        let effectEntity: Entity

        switch effect {
        case .sparkles:
            effectEntity = EnhancedParticleEffects.createSparkleEffect(at: position)
        case .snow:
            effectEntity = EnhancedParticleEffects.createSnowEffect(at: position)
        case .bubbles:
            effectEntity = EnhancedParticleEffects.createBubbleEffect(at: position)
        }

        parent.addChild(effectEntity)

        let effectId = UUID()
        effectLock.lock()
        activeEffects[effectId] = effectEntity
        effectLock.unlock()

        // Play sound effect
        let sound: EffectSound
        switch effect {
        case .sparkles:
            sound = .sparkles
        case .snow:
            sound = .snow
        case .bubbles:
            sound = .bubbles
        }
        AudioService.shared.playEffect(sound)

        return effectId
    }

    /// Stop a specific effect
    func stopEffect(id: UUID) {
        effectLock.lock()
        defer { effectLock.unlock() }

        guard let effect = activeEffects[id] else { return }
        EnhancedParticleEffects.stopEffect(effect)
        activeEffects.removeValue(forKey: id)
    }

    /// Stop all active effects
    func stopAllEffects() {
        effectLock.lock()
        defer { effectLock.unlock() }

        for effect in activeEffects.values {
            EnhancedParticleEffects.clearEffect(effect)
        }
        activeEffects.removeAll()
    }

    /// Get count of active effects
    func activeEffectCount() -> Int {
        effectLock.lock()
        defer { effectLock.unlock() }
        return activeEffects.count
    }
}
