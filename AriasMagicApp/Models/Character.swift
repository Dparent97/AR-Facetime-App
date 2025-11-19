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
    @Published var currentAction: CharacterAction

    // Private backing storage for scale
    private var _scale: Float = 1.0

    // AnimatableCharacter conformance
    var characterType: CharacterType { type }
    var modelEntity: ModelEntity { entity! }

    var scale: Float {
        get { _scale }
        set {
            _scale = newValue
            entity?.scale = [newValue, newValue, newValue]
        }
    }

    var entity: ModelEntity?

    init(id: UUID = UUID(), type: CharacterType, position: SIMD3<Float> = [0, 0, -1], scale: Float = 1.0) {
        self.id = id
        self.type = type
        self.position = position
        self._scale = scale
        self.currentAction = .idle

        createEntity()
    }

    private func createEntity() {
        // Create placeholder entity with distinct colors for each character
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: colorForType(type), isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])

        modelEntity.position = position
        modelEntity.scale = [_scale, _scale, _scale]

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

    // MARK: - AnimatableCharacter Protocol Conformance

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

        case .dance:
            // Bouncing animation
            var transform = entity.transform
            transform.translation.y += 0.1
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.translation.y -= 0.1
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }

        case .twirl:
            // Full rotation
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            entity.move(to: fullRotation, relativeTo: entity.parent, duration: 1.0)

        case .jump:
            // Jump up and down
            var transform = entity.transform
            transform.translation.y += 0.2
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transform.translation.y -= 0.2
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)
            }

        case .sparkle:
            // Scale pulse
            var transform = entity.transform
            let currentScale = self._scale
            transform.scale = [currentScale * 1.2, currentScale * 1.2, currentScale * 1.2]
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.scale = [currentScale, currentScale, currentScale]
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }
        }

        // Reset to idle after animation and call completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentAction = .idle
            completion()
        }
    }

    func setPosition(_ position: SIMD3<Float>, animated: Bool) {
        self.position = position

        guard let entity = entity else { return }

        if animated {
            entity.move(
                to: Transform(translation: position),
                relativeTo: entity.parent,
                duration: 0.3
            )
        } else {
            entity.position = position
        }
    }

    func setScale(_ scale: Float, animated: Bool) {
        self._scale = scale

        guard let entity = entity else { return }

        let scaleVector = SIMD3<Float>(repeating: scale)

        if animated {
            entity.move(
                to: Transform(scale: scaleVector),
                relativeTo: entity.parent,
                duration: 0.3
            )
        } else {
            entity.scale = scaleVector
        }
    }

    func cleanup() {
        entity?.removeFromParent()
        entity = nil
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
