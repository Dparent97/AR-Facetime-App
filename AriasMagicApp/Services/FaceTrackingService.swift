import Foundation
import ARKit

public enum FaceExpression: Sendable {
    case smile
    case eyebrowsRaised
    case mouthOpen
}

@MainActor
public class FaceTrackingService {
    // Callbacks
    public var onExpressionDetected: ((FaceExpression) -> Void)?
    
    // Thresholds
    private let smileThreshold: Float = 0.5
    private let eyebrowThreshold: Float = 0.5
    private let mouthOpenThreshold: Float = 0.4
    
    // State
    private var lastExpressionTime: [FaceExpression: Date] = [:]
    private let debounceInterval: TimeInterval = 1.0
    
    public init() {}
    
    public func processFaceAnchor(_ anchor: ARFaceAnchor) {
        // Smile
        if let left = anchor.blendShapes[.mouthSmileLeft] as? Float,
           let right = anchor.blendShapes[.mouthSmileRight] as? Float,
           (left + right) / 2 > smileThreshold {
            trigger(.smile)
        }
        
        // Eyebrows
        if let left = anchor.blendShapes[.browInnerUp] as? Float,
           let right = anchor.blendShapes[.browInnerUp] as? Float,
           (left + right) / 2 > eyebrowThreshold {
            trigger(.eyebrowsRaised)
        }
        
        // Mouth Open
        if let open = anchor.blendShapes[.jawOpen] as? Float,
           open > mouthOpenThreshold {
            trigger(.mouthOpen)
        }
    }
    
    private func trigger(_ expression: FaceExpression) {
        let now = Date()
        if let last = lastExpressionTime[expression], now.timeIntervalSince(last) < debounceInterval {
            return
        }
        
        lastExpressionTime[expression] = now
        onExpressionDetected?(expression)
    }
}
