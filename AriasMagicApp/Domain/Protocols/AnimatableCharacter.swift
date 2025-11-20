import Foundation

public protocol AnimatableCharacter: Sendable {
    var id: UUID { get }
    var type: CharacterType { get }
    var state: CharacterState { get }
    func canPerformAction(_ action: CharacterAction) -> Bool
}

// Default implementation
public extension AnimatableCharacter {
    func canPerformAction(_ action: CharacterAction) -> Bool {
        // By default all characters can perform all actions
        // This can be customized per character type if needed
        return true
    }
}

