import Foundation

public enum EffectType: String, CaseIterable, Codable, Sendable {
    case sparkles
    case snow
    case bubbles
    
    public var displayName: String {
        switch self {
        case .sparkles: return "✨ Sparkles"
        case .snow: return "❄️ Snow"
        case .bubbles: return "🫧 Bubbles"
        }
    }
    
    public var emoji: String {
        switch self {
        case .sparkles: return "✨"
        case .snow: return "❄️"
        case .bubbles: return "🫧"
        }
    }
}

