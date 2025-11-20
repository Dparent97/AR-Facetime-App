import Foundation
import UIKit

public enum AssetCatalog {
    case character(CharacterType)
    
    public var resourceName: String {
        switch self {
        case .character(let type):
            // Sanitize the raw value or map to specific filenames
            return type.rawValue.replacingOccurrences(of: " ", with: "_")
        }
    }
    
    public var placeholderColor: UIColor {
        switch self {
        case .character(let type):
            switch type {
            case .sparkleThePrincess: return .systemPink
            case .lunaTheStarDancer: return .systemPurple
            case .rosieTheDreamWeaver: return .systemRed
            case .crystalTheGemKeeper: return .systemCyan
            case .willowTheWishMaker: return .systemGreen
            }
        }
    }
}

