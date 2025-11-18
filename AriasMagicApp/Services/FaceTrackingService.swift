//
//  FaceTrackingService.swift
//  Aria's Magic SharePlay App
//
//  Handles face tracking and expression detection
//

import Foundation
import ARKit

enum FaceExpression {
    case smile
    case eyebrowsRaised
    case mouthOpen
}

protocol FaceTrackingDelegate: AnyObject {
    func didDetectExpression(_ expression: FaceExpression)
}

class FaceTrackingService {
    weak var delegate: FaceTrackingDelegate?

    // Thresholds for expression detection
    private let smileThreshold: Float = 0.5
    private let eyebrowThreshold: Float = 0.5
    private let mouthOpenThreshold: Float = 0.4

    // Debouncing
    private var lastSmileTime: Date?
    private var lastEyebrowTime: Date?
    private var lastMouthOpenTime: Date?
    private let debounceInterval: TimeInterval = 1.0

    init(delegate: FaceTrackingDelegate? = nil) {
        self.delegate = delegate
    }

    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        // Check for smile
        if let leftSmile = faceAnchor.blendShapes[.mouthSmileLeft] as? Float,
           let rightSmile = faceAnchor.blendShapes[.mouthSmileRight] as? Float {
            let smileValue = (leftSmile + rightSmile) / 2.0

            if smileValue > smileThreshold {
                triggerExpression(.smile, lastTime: &lastSmileTime)
            }
        }

        // Check for raised eyebrows
        if let leftBrow = faceAnchor.blendShapes[.browInnerUp] as? Float,
           let rightBrow = faceAnchor.blendShapes[.browInnerUp] as? Float {
            let browValue = (leftBrow + rightBrow) / 2.0

            if browValue > eyebrowThreshold {
                triggerExpression(.eyebrowsRaised, lastTime: &lastEyebrowTime)
            }
        }

        // Check for mouth open
        if let mouthOpen = faceAnchor.blendShapes[.jawOpen] as? Float {
            if mouthOpen > mouthOpenThreshold {
                triggerExpression(.mouthOpen, lastTime: &lastMouthOpenTime)
            }
        }
    }

    private func triggerExpression(_ expression: FaceExpression, lastTime: inout Date?) {
        let now = Date()

        // Debounce to prevent rapid firing
        if let last = lastTime, now.timeIntervalSince(last) < debounceInterval {
            return
        }

        lastTime = now

        // Haptic feedback for successful face tracking trigger
        HapticManager.shared.faceTrackingSuccess()

        DispatchQueue.main.async {
            self.delegate?.didDetectExpression(expression)
        }
    }
}

// Extend coordinator to implement delegate
extension MagicARView.Coordinator: FaceTrackingDelegate {
    func didDetectExpression(_ expression: FaceExpression) {
        viewModel.handleFaceExpression(expression)
    }
}
