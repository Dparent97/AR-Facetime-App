//
//  CharacterProtocols.swift
//  Aria's Magic SharePlay App
//
//  Protocol definitions for animatable characters
//  Decouples core logic from 3D implementation
//

import Foundation
import RealityKit

/// Protocol defining the contract for all animatable characters in the AR experience.
/// This abstraction allows the 3D Engineer to provide custom implementations
/// while the core system remains unchanged.
protocol AnimatableCharacter: AnyObject {
    /// The underlying RealityKit entity that represents this character in AR space
    var modelEntity: ModelEntity { get }

    /// Character type identifier (e.g., Sparkle the Princess, Luna the Star Dancer)
    var characterType: CharacterType { get }

    /// Unique instance identifier for tracking and synchronization
    var id: UUID { get }

    /// Current action being performed by the character
    var currentAction: CharacterAction { get }

    /// Current position in AR world space
    var position: SIMD3<Float> { get set }

    /// Current scale of the character
    var scale: SIMD3<Float> { get set }

    /// Perform an action with animation and completion callback
    /// - Parameters:
    ///   - action: The action to perform (wave, dance, jump, etc.)
    ///   - completion: Called when the animation completes
    func performAction(_ action: CharacterAction, completion: @escaping () -> Void)

    /// Update the character's position in AR space
    /// - Parameter position: New position in world coordinates
    func setPosition(_ position: SIMD3<Float>)

    /// Update the character's scale
    /// - Parameter scale: New scale value (uniform scaling)
    func setScale(_ scale: Float)

    /// Clean up resources when character is removed
    /// Use this to deallocate animations, textures, or other resources
    func cleanup()
}

/// Factory protocol for creating character instances
/// Allows different implementations (placeholder vs. production 3D models)
protocol CharacterFactory {
    /// Create a new character instance
    /// - Parameters:
    ///   - type: The type of character to create
    ///   - position: Initial position in AR space
    ///   - scale: Initial scale
    /// - Returns: A new character instance conforming to AnimatableCharacter
    func createCharacter(
        type: CharacterType,
        position: SIMD3<Float>,
        scale: SIMD3<Float>
    ) -> AnimatableCharacter

    /// Returns the list of character types supported by this factory
    /// - Returns: Array of supported CharacterType values
    func supportedCharacterTypes() -> [CharacterType]
}

/// Default factory implementation using the current Character class
/// This can be replaced by a 3D asset factory later
class DefaultCharacterFactory: CharacterFactory {
    func createCharacter(
        type: CharacterType,
        position: SIMD3<Float> = [0, 0, -1],
        scale: SIMD3<Float> = [1, 1, 1]
    ) -> AnimatableCharacter {
        return Character(type: type, position: position, scale: scale)
    }

    func supportedCharacterTypes() -> [CharacterType] {
        return CharacterType.allCases
    }
}

// MARK: - Extension: Default Implementations

extension AnimatableCharacter {
    /// Convenience method for uniform scaling
    func setScale(_ scale: Float) {
        self.scale = SIMD3<Float>(repeating: scale)
    }
}
