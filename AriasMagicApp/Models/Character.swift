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

class Character: Identifiable, ObservableObject, AnimatableCharacter, CharacterSyncable, AudioCharacter {
    let id: UUID
    let type: CharacterType
    @Published var position: SIMD3<Float>
    @Published var scale: SIMD3<Float>
    @Published var currentAction: CharacterAction

    private var entity: ModelEntity?

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

    // MARK: - AnimatableCharacter Protocol

    var characterType: CharacterType {
        return type
    }

    var modelEntity: ModelEntity {
        guard let entity = entity else {
            // Return a default entity if none exists
            fatalError("ModelEntity not initialized. This should not happen.")
        }
        return entity
    }

    func performAction(_ action: CharacterAction, completion: @escaping () -> Void) {
        currentAction = action

        guard let entity = entity else {
            completion()
            return
        }

        // Create simple animations for each action
        let animationDuration: TimeInterval

        switch action {
        case .idle:
            animationDuration = 0
            completion()

        case .wave:
            // Simple rotation animation
            animationDuration = 0.5
            let rotation = Transform(rotation: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]))
            entity.move(to: rotation, relativeTo: entity.parent, duration: animationDuration)

            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                completion()
            }

        case .dance:
            // Bouncing animation
            animationDuration = 0.6
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
            animationDuration = 1.0
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            entity.move(to: fullRotation, relativeTo: entity.parent, duration: animationDuration)

            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                completion()
            }

        case .jump:
            // Jump up and down
            animationDuration = 0.8
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
            animationDuration = 0.6
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
        if action != .idle {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.currentAction = .idle
            }
        }
    }

    func setPosition(_ position: SIMD3<Float>) {
        self.position = position
        entity?.position = position
    }

    func setScale(_ scale: SIMD3<Float>) {
        self.scale = scale
        entity?.scale = scale
    }

    func cleanup() {
        entity?.removeFromParent()
        entity = nil
    }

    // MARK: - CharacterSyncable Protocol

    func encodeState() -> [String: Any] {
        return [
            "id": id.uuidString,
            "type": type.rawValue,
            "position": [position.x, position.y, position.z],
            "scale": [scale.x, scale.y, scale.z],
            "action": currentAction.rawValue
        ]
    }

    func decodeState(_ state: [String: Any]) {
        if let positionArray = state["position"] as? [Float], positionArray.count == 3 {
            setPosition(SIMD3<Float>(positionArray[0], positionArray[1], positionArray[2]))
        }

        if let scaleArray = state["scale"] as? [Float], scaleArray.count == 3 {
            setScale(SIMD3<Float>(scaleArray[0], scaleArray[1], scaleArray[2]))
        }

        if let actionString = state["action"] as? String,
           let action = CharacterAction(rawValue: actionString) {
            performAction(action) { }
        }
    }

    // MARK: - AudioCharacter Protocol

    func soundEffectForAction(_ action: CharacterAction) -> String? {
        switch action {
        case .idle:
            return nil
        case .wave:
            return "character_wave"
        case .dance:
            return "character_dance"
        case .twirl:
            return "character_twirl"
        case .jump:
            return "character_jump"
        case .sparkle:
            return "character_sparkle"
        }
    }

    func ambientSound() -> String? {
        // Each character type could have its own ambient sound
        switch type {
        case .sparkleThePrincess:
            return "ambient_sparkle"
        case .lunaTheStarDancer:
            return "ambient_luna"
        case .rosieTheDreamWeaver:
            return "ambient_rosie"
        case .crystalTheGemKeeper:
            return "ambient_crystal"
        case .willowTheWishMaker:
            return "ambient_willow"
        }
    }
}

// MARK: - Default Character Factory

/// Default factory implementation for creating characters
class DefaultCharacterFactory: CharacterFactory {
    static let shared = DefaultCharacterFactory()

    private init() {}

    func createCharacter(type: CharacterType) -> AnimatableCharacter {
        return Character(type: type)
    }

    func supportedCharacterTypes() -> [CharacterType] {
        return CharacterType.allCases
    }
}
