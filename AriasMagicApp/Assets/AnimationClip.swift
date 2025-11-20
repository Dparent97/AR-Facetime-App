import Foundation

public struct AnimationClip: Sendable {
    public let name: String
    public let duration: TimeInterval
    public let isLooping: Bool
    
    public init(name: String, duration: TimeInterval, isLooping: Bool = false) {
        self.name = name
        self.duration = duration
        self.isLooping = isLooping
    }
    
    public static func forAction(_ action: CharacterAction) -> AnimationClip {
        switch action {
        case .idle:
            return AnimationClip(name: "idle", duration: 0, isLooping: true)
        case .wave:
            return AnimationClip(name: "wave", duration: 2.0)
        case .dance:
            return AnimationClip(name: "dance", duration: 3.0, isLooping: true)
        case .twirl:
            return AnimationClip(name: "twirl", duration: 1.5)
        case .jump:
            return AnimationClip(name: "jump", duration: 1.0)
        case .sparkle:
            return AnimationClip(name: "sparkle", duration: 2.0)
        }
    }
}

