//
//  Character.swift
//  Aria's Magic SharePlay App
//
//  Character model with animations
//

import Foundation
import RealityKit
import Combine

/// Enumeration of character themes and personalities.
///
/// Each character type represents a unique princess-inspired theme with distinct visual
/// representation and personality traits. In production, each type should map to a specific
/// 3D model asset.
///
/// - Note: Currently uses colored cubes as placeholders. Replace with USDZ models in production.
///
/// Example:
/// ```swift
/// let characterType: CharacterType = .sparkleThePrincess
/// let character = Character(type: characterType)
/// ```
enum CharacterType: String, CaseIterable, Codable {
    /// Pink princess with sparkle magic
    case sparkleThePrincess = "Sparkle the Princess"

    /// Purple celestial dancer with starlight
    case lunaTheStarDancer = "Luna the Star Dancer"

    /// Red dream creator with rosy magic
    case rosieTheDreamWeaver = "Rosie the Dream Weaver"

    /// Cyan crystal guardian with gem powers
    case crystalTheGemKeeper = "Crystal the Gem Keeper"

    /// Green wish granter with nature magic
    case willowTheWishMaker = "Willow the Wish Maker"
}

/// Enumeration of character animation actions.
///
/// Defines the available animations that characters can perform. Each action has a specific
/// duration and visual behavior implemented in the ``Character/performAction(_:)`` method.
///
/// - SeeAlso: ``Character/performAction(_:)``
enum CharacterAction: String, Codable {
    /// Default resting state with no animation
    case idle

    /// Rotation animation (0.5s) - characters wave hello
    case wave

    /// Bouncing animation (0.6s) - characters bounce up and down
    case dance

    /// Full rotation animation (1.0s) - characters spin 360°
    case twirl

    /// Jumping animation (0.8s) - characters jump high
    case jump

    /// Scale pulse animation (0.6s) - characters pulse with energy
    case sparkle
}

/// An AR character instance with animations, spatial properties, and visual representation.
///
/// `Character` represents a single character in the AR scene, managing its RealityKit entity,
/// position, scale, and animation state. Each character has a unique identity and can perform
/// various actions like waving, dancing, and jumping.
///
/// The character's state is published via Combine, making it observable for SwiftUI views.
///
/// - Note: Currently uses colored cube meshes as placeholders. In production, replace with
///   proper 3D character models loaded from USDZ files.
///
/// Example:
/// ```swift
/// // Create a character
/// let sparkle = Character(
///     type: .sparkleThePrincess,
///     position: [0, 0, -0.5]
/// )
///
/// // Add to AR scene
/// if let entity = sparkle.entity {
///     arView.scene.addChild(entity)
/// }
///
/// // Trigger an animation
/// sparkle.performAction(.wave)
/// ```
///
/// - SeeAlso: ``CharacterType``, ``CharacterAction``
class Character: Identifiable, ObservableObject {
    /// Unique identifier for the character instance.
    ///
    /// Used for identifying characters in collections and during SharePlay synchronization.
    /// Automatically generated on initialization.
    let id: UUID

    /// The character's theme and personality type.
    ///
    /// Determines the character's color (in current placeholder implementation) and will
    /// determine the 3D model in production builds.
    let type: CharacterType

    /// The character's 3D world position in AR space (measured in meters).
    ///
    /// Components:
    /// - x: Left/right (negative = left, positive = right)
    /// - y: Up/down (negative = down, positive = up)
    /// - z: Depth (negative = toward user, positive = away)
    ///
    /// Changes are published and trigger SwiftUI view updates.
    @Published var position: SIMD3<Float>

    /// The character's size scaling factor.
    ///
    /// Use uniform scaling (e.g., `[2, 2, 2]`) for consistent proportions.
    /// Non-uniform scaling may distort the character model.
    ///
    /// Default: `[1, 1, 1]` (normal size)
    @Published var scale: SIMD3<Float>

    /// The character's current animation state.
    ///
    /// Automatically set to `.idle` after action animations complete (1.5 seconds).
    /// Use ``performAction(_:)`` method instead of setting directly.
    @Published var currentAction: CharacterAction

    /// The RealityKit visual representation of the character.
    ///
    /// Contains the 3D mesh, materials, and collision components. Created automatically
    /// during initialization. May be nil if entity creation fails.
    ///
    /// - Note: Currently a colored cube. Replace with USDZ model loading in production.
    var entity: ModelEntity?

    /// Initializes a new character instance.
    ///
    /// Creates the character with specified properties and generates its RealityKit entity.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - type: The character's theme/personality type.
    ///   - position: Initial 3D position in meters. Defaults to `[0, 0, -1]` (1m in front).
    ///   - scale: Initial size scaling. Defaults to `[1, 1, 1]` (normal size).
    ///
    /// Example:
    /// ```swift
    /// let character = Character(
    ///     type: .lunaTheStarDancer,
    ///     position: [0.5, 0, -0.5],
    ///     scale: [1.5, 1.5, 1.5]
    /// )
    /// ```
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

    /// Performs an animated action on the character.
    ///
    /// The character transitions from its current state to perform the specified action,
    /// then automatically returns to idle state after 1.5 seconds. Animations use
    /// RealityKit's `move(to:relativeTo:duration:)` API for smooth transitions.
    ///
    /// - Parameter action: The action to perform. See ``CharacterAction`` for available actions.
    ///
    /// - Note: Actions cannot be interrupted once started. Subsequent calls will override
    ///   the current animation.
    ///
    /// Action details:
    /// - `.idle` - No animation
    /// - `.wave` - 45° rotation (0.5s)
    /// - `.dance` - Bounce up 0.1m and down (0.6s)
    /// - `.twirl` - Full 360° rotation (1.0s)
    /// - `.jump` - Jump up 0.2m and down (0.8s)
    /// - `.sparkle` - Scale pulse to 1.2x (0.6s)
    ///
    /// Example:
    /// ```swift
    /// let character = Character(type: .sparkleThePrincess)
    /// character.performAction(.wave)
    ///
    /// // Chain actions with delays
    /// character.performAction(.wave)
    /// DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    ///     character.performAction(.dance)
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CharacterAction``
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
            transform.scale = [1.2, 1.2, 1.2]
            entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transform.scale = [1, 1, 1]
                entity.move(to: transform, relativeTo: entity.parent, duration: 0.3)
            }
        }

        // Reset to idle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentAction = .idle
        }
    }
}
