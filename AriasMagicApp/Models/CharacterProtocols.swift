//
//  CharacterProtocols.swift
//  Aria's Magic SharePlay App
//
//  Protocol abstraction for animatable characters
//  Decouples core logic from 3D implementation
//

import Foundation
import RealityKit

/// Protocol defining the contract for all animatable characters
/// This allows the 3D Engineer to implement real models while core logic remains unchanged
protocol AnimatableCharacter: AnyObject, Identifiable {
    /// Unique instance identifier
    var id: UUID { get }

    /// The underlying RealityKit entity for AR rendering
    var modelEntity: ModelEntity { get }

    /// Character type identifier (e.g., Sparkle, Luna, etc.)
    var characterType: CharacterType { get }

    /// Current action being performed
    var currentAction: CharacterAction { get }

    /// Current position in AR space
    var position: SIMD3<Float> { get set }

    /// Current scale of the character
    var scale: SIMD3<Float> { get set }

    /// Perform an action with completion callback
    /// - Parameters:
    ///   - action: The action to perform (wave, dance, jump, etc.)
    ///   - completion: Called when the animation completes
    func performAction(_ action: CharacterAction, completion: @escaping () -> Void)

    /// Update position in AR space
    /// - Parameter position: New position in 3D space
    func setPosition(_ position: SIMD3<Float>)

    /// Update scale uniformly
    /// - Parameter scale: New scale factor
    func setScale(_ scale: Float)

    /// Clean up resources when character is removed
    func cleanup()
}

/// Factory for creating character instances
/// This allows switching between placeholder cubes and real 3D models
protocol CharacterFactory {
    /// Create a character instance of the specified type
    /// - Parameters:
    ///   - type: The character type to create
    ///   - position: Initial position in AR space
    ///   - scale: Initial scale
    /// - Returns: A character conforming to AnimatableCharacter protocol
    func createCharacter(
        type: CharacterType,
        at position: SIMD3<Float>,
        scale: SIMD3<Float>
    ) -> AnimatableCharacter

    /// Get list of all supported character types
    /// - Returns: Array of character types this factory can create
    func supportedCharacterTypes() -> [CharacterType]
}

/// Extension providing default implementations
extension AnimatableCharacter {
    /// Default setPosition implementation
    func setPosition(_ position: SIMD3<Float>) {
        self.position = position
        self.modelEntity.position = position
    }

    /// Default setScale implementation (uniform scaling)
    func setScale(_ scale: Float) {
        let scaleVector = SIMD3<Float>(repeating: scale)
        self.scale = scaleVector
        self.modelEntity.scale = scaleVector
    }

    /// Default cleanup (can be overridden for custom cleanup)
    func cleanup() {
        modelEntity.removeFromParent()
    }
}

/// Convenience extension for batch operations
extension Collection where Element: AnimatableCharacter {
    /// Perform action on all characters in collection
    func performAction(_ action: CharacterAction, completion: (() -> Void)? = nil) {
        let group = DispatchGroup()

        forEach { character in
            group.enter()
            character.performAction(action) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion?()
        }
    }
}
