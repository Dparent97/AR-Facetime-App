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
    @Published var scale: SIMD3<Float>
    @Published var currentAction: CharacterAction

    let modelEntity: ModelEntity

    init(id: UUID = UUID(), type: CharacterType, position: SIMD3<Float> = [0, 0, -1], scale: SIMD3<Float> = [1, 1, 1]) {
        self.id = id
        self.characterType = type
        self.position = position
        self.scale = scale
        self.currentAction = .idle

        // Create the model entity immediately with placeholder
        // TODO: Enhance with AssetLoader for USDZ models
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: Self.colorForType(type), isMetallic: false)
        self.modelEntity = ModelEntity(mesh: mesh, materials: [material])

        // Configure entity
        modelEntity.position = position
        modelEntity.scale = scale
        modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
        modelEntity.name = type.rawValue
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

    func performAction(_ action: CharacterAction, completion: @escaping () -> Void = {}) {
        currentAction = action

        // Play sound effect for action (when AudioService available)
        playActionSound(for: action)

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

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.translation.y -= 0.1
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }
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

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transform.translation.y -= 0.2
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.4)
            }
            scheduleCompletion(after: 0.8, completion: completion)

        case .sparkle:
            // Scale pulse with particle effect
            var transform = modelEntity.transform
            transform.scale = [1.2, 1.2, 1.2]
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.3)

            // Add sparkle particle effect (when EnhancedParticleEffects available)
            if let parent = modelEntity.parent {
                let sparkleEffect = EnhancedParticleEffects.createSparkleEffect(at: modelEntity.position)
                parent.addChild(sparkleEffect)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.scale = [1, 1, 1]
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }
            scheduleCompletion(after: 0.6, completion: completion)
        }

        // Reset to idle after animation
        let animationDuration = durationForAction(action)
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.currentAction = .idle
        }
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
        // Remove entity from parent and clear resources
        modelEntity.removeFromParent()
        // Additional cleanup can be added here (e.g., stop animations, release textures)
    }

    // MARK: - Audio and Effects Support

    /// Play sound effect for character action
    private func playActionSound(for action: CharacterAction) {
        let sound: CharacterSound?

        switch action {
        case .idle:
            sound = nil
        case .wave:
            sound = .wave
        case .dance:
            sound = .dance
        case .twirl:
            sound = .twirl
        case .jump:
            sound = .jump
        case .sparkle:
            sound = .sparkle
        }

        if let sound = sound {
            AudioService.shared.playSound(sound)
        }
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

    /// Schedule completion callback
    private func scheduleCompletion(after delay: TimeInterval, completion: (() -> Void)?) {
        guard let completion = completion else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion()
        }
    }
}
