//
//  CharacterProtocols.swift
//  Aria's Magic SharePlay App
//
//  Protocol definitions for animatable characters
//  Decouples core logic from 3D implementation
//

import Foundation
import RealityKit

/// Protocol defining the contract for all animatable characters in the app.
///
/// This protocol abstracts the implementation details of character rendering and animation,
/// allowing the core logic to remain independent of specific 3D model implementations.
/// The 3D Engineer will create concrete implementations that conform to this protocol.
///
/// - Note: All methods are expected to be safe to call from the main thread.
/// - Important: Implementations must handle their own resource cleanup in `cleanup()`.
protocol AnimatableCharacter: AnyObject {
    /// The underlying RealityKit entity representing this character
    ///
    /// This entity should be added to an AR scene for rendering.
    var modelEntity: ModelEntity { get }

    /// The type identifier for this character (e.g., Sparkle the Princess)
    var characterType: CharacterType { get }

    /// Unique instance identifier
    ///
    /// Used for tracking individual characters across SharePlay sessions
    /// and managing character lifecycle.
    var id: UUID { get }

    /// The current action being performed by this character
    ///
    /// Updated when `performAction(_:completion:)` is called.
    var currentAction: CharacterAction { get }

    /// The current position of the character in 3D space
    ///
    /// This should reflect the actual position of the `modelEntity`.
    var position: SIMD3<Float> { get set }

    /// The current scale of the character
    ///
    /// This should reflect the actual scale of the `modelEntity`.
    var scale: Float { get set }

    /// Whether the character is currently hidden (for Hide and Seek)
    var isHidden: Bool { get set }

    /// Perform an action with optional completion callback
    ///
    /// This method triggers an animation corresponding to the given action.
    /// For skeletal animations, this should play the appropriate animation clip.
    /// For procedural animations, this should apply transforms/movements.
    ///
    /// - Parameters:
    ///   - action: The action to perform (wave, dance, jump, etc.)
    ///   - completion: Called when the animation completes. May be called on any thread.
    ///
    /// - Note: Multiple calls while an animation is in progress should queue or
    ///         interrupt gracefully without causing visual artifacts.
    func performAction(_ action: CharacterAction, completion: @escaping () -> Void)

    /// Update the character's position in AR space
    ///
    /// This should smoothly transition to the new position if animated,
    /// or snap instantly if the change is from external sync (SharePlay).
    ///
    /// - Parameters:
    ///   - position: New position in 3D space (meters)
    ///   - animated: Whether to animate the transition (default: true)
    func setPosition(_ position: SIMD3<Float>, animated: Bool)

    /// Update the character's scale
    ///
    /// - Parameters:
    ///   - scale: New uniform scale factor (1.0 = original size)
    ///   - animated: Whether to animate the transition (default: true)
    func setScale(_ scale: Float, animated: Bool)

    /// Clean up resources when the character is removed
    ///
    /// This should:
    /// - Stop all animations
    /// - Remove the entity from its parent
    /// - Release any retained resources (textures, audio, etc.)
    /// - Cancel any pending operations
    ///
    /// After calling this method, the character should not be used again.
    func cleanup()
}

/// Default implementations for common operations
extension AnimatableCharacter {
    /// Default animated transitions enabled
    func setPosition(_ position: SIMD3<Float>, animated: Bool = true) {
        self.setPosition(position, animated: animated)
    }

    func setScale(_ scale: Float, animated: Bool = true) {
        self.setScale(scale, animated: animated)
    }
}

// MARK: - Character Factory

/// Factory protocol for creating character instances
///
/// Implementations of this protocol handle the creation of characters
/// with their associated 3D models and resources. This abstraction allows
/// for different loading strategies (e.g., loading from Reality Composer,
/// procedural generation, or asset bundles).
protocol CharacterFactory {
    /// Create a new character instance of the specified type
    ///
    /// - Parameters:
    ///   - type: The type of character to create
    ///   - position: Initial position in 3D space
    ///   - scale: Initial scale factor
    ///
    /// - Returns: A fully initialized character conforming to `AnimatableCharacter`
    ///
    /// - Note: This method may perform I/O operations and should be called
    ///         from a background queue if loading is expensive.
    func createCharacter(
        type: CharacterType,
        at position: SIMD3<Float>,
        scale: Float
    ) -> AnimatableCharacter

    /// Returns the list of character types supported by this factory
    ///
    /// This can be used by the UI to show only available characters
    /// or to validate character types before creation.
    func supportedCharacterTypes() -> [CharacterType]

    /// Preload resources for faster character creation
    ///
    /// This method can be called during app initialization to load
    /// 3D models, textures, and animations into memory.
    ///
    /// - Parameter types: Character types to preload, or nil for all types
    func preloadResources(for types: [CharacterType]?) async throws
}

// MARK: - Character State Sync

/// Structure representing the syncable state of a character
///
/// Used for SharePlay synchronization to transmit character state
/// across devices efficiently.
struct CharacterSyncState: Codable, Equatable {
    /// Character unique identifier
    let id: UUID

    /// Character type
    let type: CharacterType

    /// Current position in 3D space
    let position: SIMD3<Float>

    /// Current scale factor
    let scale: Float

    /// Current action being performed
    let action: CharacterAction

    /// Timestamp of this state update (for conflict resolution)
    let timestamp: TimeInterval

    /// Participant who owns/created this character
    let ownerID: String?
    
    /// Whether the character is hidden
    let isHidden: Bool

    init(
        id: UUID,
        type: CharacterType,
        position: SIMD3<Float>,
        scale: Float,
        action: CharacterAction,
        isHidden: Bool = false,
        timestamp: TimeInterval = Date().timeIntervalSince1970,
        ownerID: String? = nil
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.action = action
        self.isHidden = isHidden
        self.timestamp = timestamp
        self.ownerID = ownerID
    }

    /// Create sync state from an animatable character
    static func from(_ character: AnimatableCharacter, ownerID: String? = nil) -> CharacterSyncState {
        return CharacterSyncState(
            id: character.id,
            type: character.characterType,
            position: character.position,
            scale: character.scale,
            action: character.currentAction,
            isHidden: character.isHidden,
            ownerID: ownerID
        )
    }
}

// MARK: - Codable Support for SIMD3

/// Codable wrapper for SIMD3<Float>
extension SIMD3: Codable where Scalar == Float {
    enum CodingKeys: String, CodingKey {
        case x, y, z
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Float.self, forKey: .x)
        let y = try container.decode(Float.self, forKey: .y)
        let z = try container.decode(Float.self, forKey: .z)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
        try container.encode(self.z, forKey: .z)
    }
}
