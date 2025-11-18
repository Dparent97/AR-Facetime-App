//
//  CharacterProtocols.swift
//  Aria's Magic SharePlay App
//
//  Protocols defining the contract for animatable characters
//  This decouples core logic from 3D implementation
//

import Foundation
import RealityKit

/// Protocol defining the contract for all animatable characters
/// Allows 3D Engineer to implement real models while core systems work with abstractions
protocol AnimatableCharacter: AnyObject {
    /// Unique instance identifier
    var id: UUID { get }

    /// Character type identifier
    var characterType: CharacterType { get }

    /// The underlying RealityKit entity
    var modelEntity: ModelEntity { get }

    /// Current action being performed
    var currentAction: CharacterAction { get }

    /// Current position in AR space
    var position: SIMD3<Float> { get set }

    /// Current scale of the character
    var scale: SIMD3<Float> { get set }

    /// Perform an action with completion callback
    /// - Parameters:
    ///   - action: The action to perform (wave, dance, twirl, jump, sparkle)
    ///   - completion: Called when animation completes
    func performAction(_ action: CharacterAction, completion: @escaping () -> Void)

    /// Update position in AR space
    /// - Parameter position: New position in world coordinates
    func setPosition(_ position: SIMD3<Float>)

    /// Update scale of the character
    /// - Parameter scale: New scale factor (uniform)
    func setScale(_ scale: SIMD3<Float>)

    /// Clean up resources when character is removed
    func cleanup()
}

/// Factory protocol for creating character instances
/// Allows dependency injection and easier testing
protocol CharacterFactory {
    /// Create a new character instance
    /// - Parameter type: The type of character to create
    /// - Returns: A new character conforming to AnimatableCharacter
    func createCharacter(type: CharacterType) -> AnimatableCharacter

    /// Get list of supported character types
    /// - Returns: Array of character types this factory can create
    func supportedCharacterTypes() -> [CharacterType]

    /// Check if a character type is supported
    /// - Parameter type: The character type to check
    /// - Returns: True if this factory can create the character
    func supportsCharacterType(_ type: CharacterType) -> Bool
}

/// Default implementation of CharacterFactory protocol
/// Provides common functionality for all factory implementations
extension CharacterFactory {
    func supportsCharacterType(_ type: CharacterType) -> Bool {
        return supportedCharacterTypes().contains(type)
    }
}

/// Protocol for character state synchronization
/// Used by SharePlay to sync character state across devices
protocol CharacterSyncable {
    /// Encode character state for network transmission
    /// - Returns: Dictionary of character state
    func encodeState() -> [String: Any]

    /// Decode and apply character state from network
    /// - Parameter state: Dictionary of character state
    func decodeState(_ state: [String: Any])
}

/// Protocol for audio-enabled characters
/// Characters that play sounds when performing actions
protocol AudioCharacter {
    /// Get the sound effect name for a specific action
    /// - Parameter action: The action being performed
    /// - Returns: Sound effect identifier, or nil if action has no sound
    func soundEffectForAction(_ action: CharacterAction) -> String?

    /// Get ambient sound for this character (optional)
    /// - Returns: Ambient sound identifier, or nil if no ambient sound
    func ambientSound() -> String?
}
