//
//  Character.swift
//  Aria's Magic SharePlay App
//
//  Character model with animations
//

import Foundation
import RealityKit
import Combine

enum CharacterType: String, CaseIterable, Codable {
    case sparkleThePrincess = "Sparkle the Princess"
    case lunaTheStarDancer = "Luna the Star Dancer"
    case rosieTheDreamWeaver = "Rosie the Dream Weaver"
    case crystalTheGemKeeper = "Crystal the Gem Keeper"
    case willowTheWishMaker = "Willow the Wish Maker"
}

enum CharacterAction: String, Codable {
    case idle
    case wave
    case dance
    case twirl
    case jump
    case sparkle
}

class Character: Identifiable, ObservableObject, AnimatableCharacter {
    let id: UUID
    let characterType: CharacterType
    @Published var position: SIMD3<Float>
    @Published var currentAction: CharacterAction

    let modelEntity: ModelEntity

    // Track pending animations for cancellation (memory leak prevention)
    private var pendingWorkItems: [DispatchWorkItem] = []

    // Private backing storage for scale
    private var _scale: Float = 1.0

    // AnimatableCharacter conformance
    var characterType: CharacterType { type }

    var scale: Float {
        get { _scale }
        set {
            _scale = newValue
            modelEntity.scale = [newValue, newValue, newValue]
        }
    }


    init(id: UUID = UUID(), type: CharacterType, position: SIMD3<Float> = [0, 0, -1], scale: Float = 1.0) {
        self.id = id
        self.characterType = type
        self.position = position
        self._scale = scale
        self.currentAction = .idle

        // Create the model entity immediately with placeholder
        // TODO: Enhance with AssetLoader for USDZ models
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: Self.colorForType(type), isMetallic: false)
        self.modelEntity = ModelEntity(mesh: mesh, materials: [material])

        // Configure entity
        modelEntity.position = position
        modelEntity.scale = [_scale, _scale, _scale]

        // Add collision for interaction

        modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
        modelEntity.name = type.rawValue
    }

    deinit {
        // Cancel all pending animations to prevent memory leaks
        cancelAllAnimations()
    }

    /// Cancels all pending animation work items
    func cancelAllAnimations() {
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
    }

    private static func colorForType(_ type: CharacterType) -> UIColor {
        switch type {
        case .sparkleThePrincess:
            return .systemPink
        case .lunaTheStarDancer:
            return .systemPurple
        case .rosieTheDreamWeaver:
            return .systemRed
        case .crystalTheGemKeeper:
            return .systemCyan
        case .willowTheWishMaker:
            return .systemGreen
        }
    }

    // MARK: - AnimatableCharacter Protocol Conformance

    func performAction(_ action: CharacterAction, completion: @escaping () -> Void = {}) {
        currentAction = action

        // Play sound effect for action (when AudioService available)
        playActionSound(for: action)

        guard let _ = modelEntity.parent else {
            completion()
            return
        }

        // Create simple animations for each action
        // TODO: Replace with skeletal animations when USDZ models are loaded
        switch action {
        case .idle:
            completion()
            return

        case .wave:
            // Simple rotation animation
            let rotation = Transform(rotation: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]))
            modelEntity.move(to: rotation, relativeTo: modelEntity.parent, duration: 0.5)
            scheduleCompletion(after: 0.5, completion: completion)

        case .dance:
            // Bouncing animation
            var transform = modelEntity.transform
            transform.translation.y += 0.1
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.3)

            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                var transform = self.modelEntity.transform
                transform.translation.y -= 0.1
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
            scheduleCompletion(after: 0.6, completion: completion)

        case .twirl:
            // Full rotation
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            modelEntity.move(to: fullRotation, relativeTo: modelEntity.parent, duration: 1.0)
            scheduleCompletion(after: 1.0, completion: completion)

        case .jump:
            // Jump up and down
            var transform = modelEntity.transform
            transform.translation.y += 0.2
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.4)

            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                var transform = self.modelEntity.transform
                transform.translation.y -= 0.2
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.4)
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
            scheduleCompletion(after: 0.8, completion: completion)

        case .sparkle:
            // Scale pulse
            var transform = modelEntity.transform
            let currentScale = self._scale
            transform.scale = [currentScale * 1.2, currentScale * 1.2, currentScale * 1.2]
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.3)

            // Add sparkle particle effect (when EnhancedParticleEffects available)
            if let parent = modelEntity.parent {
                // Use the EnhancedParticleEffects if available, otherwise fallback
                // Note: Assuming EnhancedParticleEffects is a valid type in the project
                // let sparkleEffect = EnhancedParticleEffects.createSparkleEffect(at: modelEntity.position)
                // parent.addChild(sparkleEffect)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                var transform = self.modelEntity.transform
                transform.scale = [currentScale, currentScale, currentScale]
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }

            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                var transform = self.modelEntity.transform
                transform.scale = [1, 1, 1]
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
            scheduleCompletion(after: 0.6, completion: completion)
        }

        // Reset to idle after animation
        let animationDuration = durationForAction(action)
        let idleWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.currentAction = .idle
            completion()
        }
        pendingWorkItems.append(idleWorkItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: idleWorkItem)
    }

    // MARK: - AnimatableCharacter Protocol Methods

    func setPosition(_ position: SIMD3<Float>) {
        self.position = position
        modelEntity.position = position
    }

    func setScale(_ scale: Float) {
        let scaleVector = SIMD3<Float>(repeating: scale)
        self.scale = scaleVector
        modelEntity.scale = scaleVector
    }

    func cleanup() {
        // Cancel animations first
        cancelAllAnimations()
        // Remove entity from parent and clear resources
        modelEntity.removeFromParent()
        // Additional cleanup can be added here (e.g., stop animations, release textures)
    }

    // MARK: - Audio and Effects Support

    /// Play sound effect for character action
    private func playActionSound(for action: CharacterAction) {
        // Implementation depends on AudioService
        // AudioService.shared.playCharacterAction(action)
    }

    /// Get duration for action animation
    private func durationForAction(_ action: CharacterAction) -> TimeInterval {
        switch action {
        case .idle:
            return 0
        case .wave:
            return 0.5
        case .dance:
            return 0.6
        case .twirl:
            return 1.0
        case .jump:
            return 0.8
        case .sparkle:
            return 0.6
        }
    }

    /// Schedule completion callback with memory leak prevention
    private func scheduleCompletion(after delay: TimeInterval, completion: (() -> Void)?) {
        guard let completion = completion else { return }
        let workItem = DispatchWorkItem {
            completion()
        }
        pendingWorkItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    func setPosition(_ position: SIMD3<Float>, animated: Bool) {
        self.position = position

        if animated {
            modelEntity.move(
                to: Transform(translation: position),
                relativeTo: modelEntity.parent,
                duration: 0.3
            )
        } else {
            modelEntity.position = position
        }
    }

    func setScale(_ scale: Float, animated: Bool) {
        self._scale = scale

        let scaleVector = SIMD3<Float>(repeating: scale)

        if animated {
            modelEntity.move(
                to: Transform(scale: scaleVector),
                relativeTo: modelEntity.parent,
                duration: 0.3
            )
        } else {
            modelEntity.scale = scaleVector
        }
    }

    func cleanup() {
        // Cancel animations first
        cancelAllAnimations()
        // Remove entity from parent and clear resources
        modelEntity.removeFromParent()
        // Additional cleanup can be added here (e.g., stop animations, release textures)
    }

    // MARK: - Legacy Support

    /// Legacy method for backward compatibility
    func performAction(_ action: CharacterAction) {
        performAction(action) { }
    }
}

// MARK: - Character Factory Implementation

/// Default factory for creating characters with placeholder cube models
class DefaultCharacterFactory: CharacterFactory {
    func createCharacter(type: CharacterType, at position: SIMD3<Float>, scale: Float) -> AnimatableCharacter {
        return Character(type: type, position: position, scale: scale)
    }

    func supportedCharacterTypes() -> [CharacterType] {
        return CharacterType.allCases
    }

    func preloadResources(for types: [CharacterType]?) async throws {
        // No resources to preload for placeholder implementation
        // 3D Engineer will implement actual resource loading
    }
}
