//
//  CharacterProtocols.swift
//  Aria's Magic SharePlay App
//
//  Protocols and interfaces for character system integration
//

import Foundation
import RealityKit
import Combine

// MARK: - AnimatableCharacter Protocol

/// Protocol that all character entities must conform to
/// This ensures consistent behavior across all 5 character types
protocol AnimatableCharacter {
    /// The character's type (Sparkle, Luna, Rosie, Crystal, Willow)
    var characterType: CharacterType { get }

    /// The underlying RealityKit entity
    var entity: Entity { get }

    /// Current animation state
    var currentAction: CharacterAction { get set }

    /// Perform a character action with completion callback
    /// - Parameters:
    ///   - action: The action to perform
    ///   - completion: Optional callback when animation completes
    func performAction(_ action: CharacterAction, completion: (() -> Void)?)

    /// Get the available animation names in the USDZ model
    /// - Returns: Array of animation resource names
    func getAvailableAnimations() -> [String]

    /// Check if a specific animation exists
    /// - Parameter action: The action to check
    /// - Returns: True if animation exists in model
    func hasAnimation(for action: CharacterAction) -> Bool

    /// Reset to idle state
    func resetToIdle()

    /// Get the character's current position in world space
    var worldPosition: SIMD3<Float> { get }

    /// Get the character's current scale
    var worldScale: SIMD3<Float> { get }
}

// MARK: - Default Protocol Implementations

extension AnimatableCharacter {
    /// Default implementation for getting available animations
    func getAvailableAnimations() -> [String] {
        guard let modelEntity = entity as? ModelEntity else { return [] }

        // In RealityKit, animations are stored as resources in the entity
        // This is a placeholder implementation - actual implementation depends on USDZ structure
        return CharacterAction.allCases.map { $0.animationName }
    }

    /// Default implementation for checking animation existence
    func hasAnimation(for action: CharacterAction) -> Bool {
        return getAvailableAnimations().contains(action.animationName)
    }

    /// Default implementation for resetting to idle
    func resetToIdle() {
        currentAction = .idle
        performAction(.idle, completion: nil)
    }

    /// Default implementation for world position
    var worldPosition: SIMD3<Float> {
        return entity.position(relativeTo: nil)
    }

    /// Default implementation for world scale
    var worldScale: SIMD3<Float> {
        return entity.scale(relativeTo: nil)
    }
}

// MARK: - CharacterAction Extensions

extension CharacterAction: CaseIterable {
    /// All available character actions
    static var allCases: [CharacterAction] {
        return [.idle, .wave, .dance, .twirl, .jump, .sparkle]
    }

    /// Get the animation resource name for this action
    /// This should match the animation names embedded in the USDZ files
    var animationName: String {
        switch self {
        case .idle:
            return "idle"
        case .wave:
            return "wave"
        case .dance:
            return "dance"
        case .twirl:
            return "twirl"
        case .jump:
            return "jump"
        case .sparkle:
            return "sparkle"
        }
    }

    /// Get the duration of this action in seconds
    var duration: TimeInterval {
        switch self {
        case .idle:
            return 2.5 // Looping
        case .wave:
            return 1.5
        case .dance:
            return 2.5 // Looping
        case .twirl:
            return 1.5
        case .jump:
            return 1.0
        case .sparkle:
            return 2.0
        }
    }

    /// Whether this animation should loop
    var shouldLoop: Bool {
        switch self {
        case .idle, .dance:
            return true
        case .wave, .twirl, .jump, .sparkle:
            return false
        }
    }

    /// Display name for UI
    var displayName: String {
        switch self {
        case .idle:
            return "Idle"
        case .wave:
            return "Wave"
        case .dance:
            return "Dance"
        case .twirl:
            return "Twirl"
        case .jump:
            return "Jump"
        case .sparkle:
            return "Sparkle"
        }
    }

    /// Emoji icon for UI buttons
    var emoji: String {
        switch self {
        case .idle:
            return "🧍"
        case .wave:
            return "👋"
        case .dance:
            return "💃"
        case .twirl:
            return "🌀"
        case .jump:
            return "⬆️"
        case .sparkle:
            return "✨"
        }
    }
}

// MARK: - Character Animation Helper

/// Helper class for managing character animations with RealityKit
class CharacterAnimationController {
    private weak var entity: Entity?
    private var currentAnimationResource: AnimationResource?
    private var animationPlaybackController: AnimationPlaybackController?

    init(entity: Entity) {
        self.entity = entity
    }

    /// Play an animation on the character
    /// - Parameters:
    ///   - action: The action to animate
    ///   - completion: Optional completion callback
    func playAnimation(_ action: CharacterAction, completion: (() -> Void)?) {
        guard let entity = entity else {
            completion?()
            return
        }

        // Try to find the animation in the entity's available animations
        let animationName = action.animationName

        // For USDZ models with embedded animations, we need to access them like this:
        // This is a simplified version - actual implementation depends on how animations are embedded
        if let modelEntity = entity as? ModelEntity,
           let availableAnimations = modelEntity.availableAnimations.first(where: { $0.name == animationName }) {

            // Configure animation playback
            let controller = modelEntity.playAnimation(
                availableAnimations.repeat(count: action.shouldLoop ? .infinity : 1)
            )

            animationPlaybackController = controller

            // If one-shot animation, call completion after duration
            if !action.shouldLoop {
                DispatchQueue.main.asyncAfter(deadline: .now() + action.duration) {
                    completion?()
                }
            }
        } else {
            // Fallback: animation not found, still call completion
            print("⚠️ Animation '\(animationName)' not found in character model")
            completion?()
        }
    }

    /// Stop current animation
    func stopAnimation() {
        animationPlaybackController?.stop()
        animationPlaybackController = nil
    }

    /// Pause current animation
    func pauseAnimation() {
        animationPlaybackController?.pause()
    }

    /// Resume paused animation
    func resumeAnimation() {
        animationPlaybackController?.resume()
    }
}

// MARK: - Character Loading Protocol

/// Protocol for objects that can load and manage characters
protocol CharacterLoader {
    /// Load a character of the specified type
    /// - Parameter type: The character type to load
    /// - Returns: An entity conforming to AnimatableCharacter
    func loadCharacter(type: CharacterType) async -> (any AnimatableCharacter)?

    /// Check if a character is loaded
    /// - Parameter type: The character type
    /// - Returns: True if character is loaded
    func isCharacterLoaded(type: CharacterType) -> Bool
}

// MARK: - Character Event Protocol

/// Protocol for objects that want to receive character events
protocol CharacterEventDelegate: AnyObject {
    /// Called when a character action begins
    /// - Parameters:
    ///   - character: The character performing the action
    ///   - action: The action being performed
    func characterDidBeginAction(_ character: any AnimatableCharacter, action: CharacterAction)

    /// Called when a character action completes
    /// - Parameters:
    ///   - character: The character that completed the action
    ///   - action: The action that completed
    func characterDidCompleteAction(_ character: any AnimatableCharacter, action: CharacterAction)

    /// Called when a character is spawned
    /// - Parameters:
    ///   - character: The spawned character
    ///   - position: The spawn position
    func characterDidSpawn(_ character: any AnimatableCharacter, at position: SIMD3<Float>)

    /// Called when a character is removed
    /// - Parameter character: The removed character
    func characterDidRemove(_ character: any AnimatableCharacter)
}

// MARK: - Optional Delegate Methods

extension CharacterEventDelegate {
    func characterDidBeginAction(_ character: any AnimatableCharacter, action: CharacterAction) {}
    func characterDidCompleteAction(_ character: any AnimatableCharacter, action: CharacterAction) {}
    func characterDidSpawn(_ character: any AnimatableCharacter, at position: SIMD3<Float>) {}
    func characterDidRemove(_ character: any AnimatableCharacter) {}
}
