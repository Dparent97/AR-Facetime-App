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

class Character: Identifiable, ObservableObject {
    let id: UUID
    let type: CharacterType
    @Published var position: SIMD3<Float>
    @Published var scale: SIMD3<Float>
    @Published var currentAction: CharacterAction

    var entity: ModelEntity?

    init(id: UUID = UUID(), type: CharacterType, position: SIMD3<Float> = [0, 0, -1], scale: SIMD3<Float> = [1, 1, 1]) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.currentAction = .idle

        loadCharacterModel()
    }

    /// Load character model from AssetLoader (USDZ or placeholder)
    private func loadCharacterModel() {
        Task {
            // Load character entity from AssetLoader
            if let loadedEntity = await AssetLoader.shared.loadCharacter(type: type) {
                await MainActor.run {
                    // Configure loaded entity
                    loadedEntity.position = position
                    loadedEntity.scale = scale

                    // Ensure collision is set for interaction
                    if loadedEntity.collision == nil {
                        loadedEntity.collision = CollisionComponent(
                            shapes: [.generateBox(size: [0.1, 0.1, 0.1])]
                        )
                    }

                    self.entity = loadedEntity
                }
            } else {
                // Fallback to creating placeholder
                await MainActor.run {
                    self.entity = self.createPlaceholderEntity()
                }
            }
        }
    }

    /// Create a placeholder entity (used when USDZ files not available)
    private func createPlaceholderEntity() -> ModelEntity {
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: colorForType(type), isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])

        modelEntity.position = position
        modelEntity.scale = scale

        // Add collision for interaction
        modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
        modelEntity.name = type.rawValue

        return modelEntity
    }

    private func colorForType(_ type: CharacterType) -> UIColor {
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

    func performAction(_ action: CharacterAction, completion: (() -> Void)? = nil) {
        currentAction = action

        guard let entity = entity else {
            completion?()
            return
        }

        // Play sound effect for action
        playActionSound(for: action)

        // Create simple animations for each action
        // TODO: Replace with skeletal animations when USDZ models are loaded
        switch action {
        case .idle:
            completion?()

        case .wave:
            // Simple rotation animation
            let rotation = Transform(rotation: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]))
            entity.move(to: rotation, relativeTo: entity.parent, duration: 0.5)
            scheduleCompletion(after: 0.5, completion: completion)

        case .dance:
            // Bouncing animation
            var transform = entity.transform
            transform.translation.y += 0.1
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.translation.y -= 0.1
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }
            scheduleCompletion(after: 0.6, completion: completion)

        case .twirl:
            // Full rotation
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            entity.move(to: fullRotation, relativeTo: entity.parent, duration: 1.0)
            scheduleCompletion(after: 1.0, completion: completion)

        case .jump:
            // Jump up and down
            var transform = entity.transform
            transform.translation.y += 0.2
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transform.translation.y -= 0.2
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)
            }
            scheduleCompletion(after: 0.8, completion: completion)

        case .sparkle:
            // Scale pulse with particle effect
            var transform = entity.transform
            transform.scale = [1.2, 1.2, 1.2]
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            // Add sparkle particle effect
            let sparkleEffect = EnhancedParticleEffects.createSparkleEffect(at: entity.position)
            entity.parent?.addChild(sparkleEffect)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.scale = [1, 1, 1]
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }
            scheduleCompletion(after: 0.6, completion: completion)
        }

        // Reset to idle after animation
        let animationDuration = durationForAction(action)
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.currentAction = .idle
        }
    }

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
