import Foundation

public enum AudioCatalog: String, CaseIterable {
    case jump = "jump_sfx"
    case sparkle = "sparkle_sfx"
    case wave = "wave_sfx"
    case dance = "dance_sfx"
    case twirl = "twirl_sfx"
    case appearance = "appearance_sfx"
    case faceTracking = "face_tracking_sfx"
    
    public var fileName: String {
        return rawValue
    }
    
    public var fileExtension: String {
        return "mp3"
    }
}
