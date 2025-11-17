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

    // Track pending animations for cancellation
    private var pendingWorkItems: [DispatchWorkItem] = []

    init(id: UUID = UUID(), type: CharacterType, position: SIMD3<Float> = [0, 0, -1], scale: SIMD3<Float> = [1, 1, 1]) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.currentAction = .idle

        createEntity()
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

    func performAction(_ action: CharacterAction) {
        currentAction = action

        guard let entity = entity else { return }

        // Create simple animations for each action
        switch action {
        case .idle:
            break

        case .wave:
            // Simple rotation animation
            let rotation = Transform(rotation: simd_quatf(angle: .pi / 4, axis: [0, 1, 0]))
            entity.move(to: rotation, relativeTo: entity.parent, duration: 0.5)

        case .dance:
            // Bouncing animation
            var transform = entity.transform
            transform.translation.y += 0.1
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            let workItem = DispatchWorkItem { [weak self, weak entity] in
                guard let self = self, let entity = entity else { return }
                var transform = entity.transform
                transform.translation.y -= 0.1
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)

        case .twirl:
            // Full rotation
            let fullRotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
            entity.move(to: fullRotation, relativeTo: entity.parent, duration: 1.0)

        case .jump:
            // Jump up and down
            var transform = entity.transform
            transform.translation.y += 0.2
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)

            let workItem = DispatchWorkItem { [weak self, weak entity] in
                guard let self = self, let entity = entity else { return }
                var transform = entity.transform
                transform.translation.y -= 0.2
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.4)
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)

        case .sparkle:
            // Scale pulse
            var transform = entity.transform
            transform.scale = [1.2, 1.2, 1.2]
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            let workItem = DispatchWorkItem { [weak self, weak entity] in
                guard let self = self, let entity = entity else { return }
                var transform = entity.transform
                transform.scale = [1, 1, 1]
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }
            pendingWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }

        // Reset to idle after animation
        let idleWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.currentAction = .idle
        }
        pendingWorkItems.append(idleWorkItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: idleWorkItem)
    }
}
