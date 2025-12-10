import Foundation
import GroupActivities

public struct AriaMagicMoment: GroupActivity {
    public static let activityIdentifier = "com.ariasmagic.shareplay.moment"
    
    public var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Aria's Magic World"
        metadata.subtitle = "Playing with princesses!"
        metadata.type = .generic
        return metadata
    }
    
    public init() {}
}

public enum SyncMessage: Codable, Sendable {
    case characterSpawned(CharacterState)
    case characterUpdated(CharacterState)
    case characterRemoved(UUID)
    case characterAction(UUID, CharacterAction)
    case effectSpawned(EffectState)
    case requestState // Late joiner requests current state
}


