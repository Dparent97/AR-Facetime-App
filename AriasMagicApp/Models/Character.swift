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
    let type: CharacterType
    @Published var position: SIMD3<Float>
    @Published var scale: SIMD3<Float>
    @Published var currentAction: CharacterAction

    var entity: ModelEntity?

    // MARK: - AnimatableCharacter Protocol Conformance

    var modelEntity: ModelEntity {
        guard let entity = entity else {
            fatalError("ModelEntity not initialized")
        }
        return entity
    }

    var characterType: CharacterType {
        return type
    }

    init(id: UUID = UUID(), type: CharacterType, position: SIMD3<Float> = [0, 0, -1], scale: SIMD3<Float> = [1, 1, 1]) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.currentAction = .idle

        createEntity()
    }

    private func createEntity() {
        // Create placeholder entity with distinct colors for each character
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: colorForType(type), isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])

        modelEntity.position = position
        modelEntity.scale = scale

        // Add collision for interaction
        modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])

        self.entity = modelEntity
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

    // MARK: - AnimatableCharacter Protocol Methods

    func performAction(_ action: CharacterAction, completion: @escaping () -> Void) {
        currentAction = action

        guard let entity = entity else {
            completion()
            return
        }

        // Create simple animations for each action
        switch action {
        case .idle:
            completion()
            return

        case .wave:
            // Simple rotation animation
            let rotation = Transform(rotation: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]))
            entity.move(to: rotation, relativeTo: entity.parent, duration: 0.5)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion()
            }

        case .dance:
            // Bouncing animation
            var transform = entity.transform
            transform.translation.y += 0.1
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.translation.y -= 0.1
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completion()
                }
            }

        case .twirl:
            // Full rotation
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            entity.move(to: fullRotation, relativeTo: entity.parent, duration: 1.0)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion()
            }

        case .jump:
            // Jump up and down
            var transform = entity.transform
            transform.translation.y += 0.2
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transform.translation.y -= 0.2
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    completion()
                }
            }

        case .sparkle:
            // Scale pulse
            var transform = entity.transform
            transform.scale = [1.2, 1.2, 1.2]
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.scale = [1, 1, 1]
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completion()
                }
            }
        }

        // Reset to idle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentAction = .idle
        }
    }

    /// Legacy method for backwards compatibility
    func performAction(_ action: CharacterAction) {
        performAction(action) { }
    }
}

// MARK: - Character Factory

/// Default factory for creating placeholder character cubes
/// The 3D Engineer will create a new factory that produces real 3D models
class PlaceholderCharacterFactory: CharacterFactory {
    static let shared = PlaceholderCharacterFactory()

    private init() {}

    func createCharacter(
        type: CharacterType,
        at position: SIMD3<Float> = [0, 0, -1],
        scale: SIMD3<Float> = [1, 1, 1]
    ) -> AnimatableCharacter {
        return Character(type: type, position: position, scale: scale)
    }

    func supportedCharacterTypes() -> [CharacterType] {
        return CharacterType.allCases
    }
}

/// Factory registry to allow switching between placeholder and real models
class CharacterFactoryRegistry {
    static let shared = CharacterFactoryRegistry()

    private var currentFactory: CharacterFactory = PlaceholderCharacterFactory.shared

    private init() {}

    /// Register a new factory (e.g., the 3D model factory)
    func registerFactory(_ factory: CharacterFactory) {
        currentFactory = factory
    }

    /// Get the current active factory
    func getFactory() -> CharacterFactory {
        return currentFactory
    }

    /// Convenience method to create a character using the current factory
    func createCharacter(
        type: CharacterType,
        at position: SIMD3<Float> = [0, 0, -1],
        scale: SIMD3<Float> = [1, 1, 1]
    ) -> AnimatableCharacter {
        return currentFactory.createCharacter(type: type, at: position, scale: scale)
    }
}
