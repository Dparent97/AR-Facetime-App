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

        // Create the model entity immediately
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: Self.colorForType(type), isMetallic: false)
        self.modelEntity = ModelEntity(mesh: mesh, materials: [material])

        // Configure entity
        modelEntity.position = position
        modelEntity.scale = scale
        modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
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

        // Create simple animations for each action
        switch action {
        case .idle:
            completion()
            return

        case .wave:
            // Simple rotation animation
            let rotation = Transform(rotation: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]))
            modelEntity.move(to: rotation, relativeTo: modelEntity.parent, duration: 0.5)

        case .dance:
            // Bouncing animation
            var transform = modelEntity.transform
            transform.translation.y += 0.1
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.translation.y -= 0.1
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }

        case .twirl:
            // Full rotation
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            modelEntity.move(to: fullRotation, relativeTo: modelEntity.parent, duration: 1.0)

        case .jump:
            // Jump up and down
            var transform = modelEntity.transform
            transform.translation.y += 0.2
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.4)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transform.translation.y -= 0.2
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.4)
            }

        case .sparkle:
            // Scale pulse
            var transform = modelEntity.transform
            transform.scale = [1.2, 1.2, 1.2]
            modelEntity.move(to: transform, relativeTo: modelEntity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.scale = [1, 1, 1]
                self.modelEntity.move(to: transform, relativeTo: self.modelEntity.parent, duration: 0.3)
            }
        }

        // Reset to idle after animation and call completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentAction = .idle
            completion()
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
}
