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

    // Error tracking
    private var consecutiveErrors: Int = 0
    private let maxConsecutiveErrors: Int = 5
    private var isDisabled: Bool = false

    // Tracking state (for lifecycle management)
    private var isTrackingActive: Bool = true

    init(delegate: FaceTrackingDelegate? = nil) {
        self.delegate = delegate
        ErrorLoggingService.shared.logger.info("FaceTrackingService initialized")
    }

    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        // Check if service is disabled due to too many errors
        guard !isDisabled else { return }

        // Don't process if tracking is paused
        guard isTrackingActive else { return }

        do {
            // Validate face anchor data
            guard faceAnchor.isTracked else {
                throw AppError.faceTrackingFailed("Face not tracked")
            }

            // Check for smile
            if let leftSmile = faceAnchor.blendShapes[.mouthSmileLeft] as? Float,
               let rightSmile = faceAnchor.blendShapes[.mouthSmileRight] as? Float {
                let smileValue = (leftSmile + rightSmile) / 2.0

                if smileValue > smileThreshold {
                    triggerExpression(.smile, lastTime: &lastSmileTime)
                }
            } else {
                throw AppError.faceTrackingFailed("Could not read smile blend shapes")
            }

            // Check for raised eyebrows
            if let leftBrow = faceAnchor.blendShapes[.browInnerUp] as? Float,
               let rightBrow = faceAnchor.blendShapes[.browInnerUp] as? Float {
                let browValue = (leftBrow + rightBrow) / 2.0

                if browValue > eyebrowThreshold {
                    triggerExpression(.eyebrowsRaised, lastTime: &lastEyebrowTime)
                }
            } else {
                throw AppError.faceTrackingFailed("Could not read eyebrow blend shapes")
            }

            // Check for mouth open
            if let mouthOpen = faceAnchor.blendShapes[.jawOpen] as? Float {
                if mouthOpen > mouthOpenThreshold {
                    triggerExpression(.mouthOpen, lastTime: &lastMouthOpenTime)
                }
            } else {
                throw AppError.faceTrackingFailed("Could not read jaw blend shapes")
            }

            // Reset error counter on success
            if consecutiveErrors > 0 {
                ErrorLoggingService.shared.logger.info("Face tracking recovered after \(consecutiveErrors) errors")
                consecutiveErrors = 0
            }

        } catch let error as AppError {
            handleProcessingError(error)
        } catch {
            handleProcessingError(.faceTrackingFailed("Unexpected error: \(error.localizedDescription)"))
        }
    }

    private func handleProcessingError(_ error: AppError) {
        consecutiveErrors += 1

        // Only log every 5th error to avoid spam
        if consecutiveErrors % 5 == 0 {
            ErrorLoggingService.shared.logError(error)
        }

        // Disable service if too many consecutive errors
        if consecutiveErrors >= maxConsecutiveErrors {
            isDisabled = true
            let criticalError = AppError.faceTrackingFailed("Face tracking disabled after \(maxConsecutiveErrors) consecutive errors")
            ErrorLoggingService.shared.logError(criticalError)
        }
    }

    func reset() {
        consecutiveErrors = 0
        isDisabled = false
        ErrorLoggingService.shared.logger.info("Face tracking service reset")
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

    // MARK: - Lifecycle Management

    func pauseTracking() {
        isTrackingActive = false
    }

    func resumeTracking() {
        isTrackingActive = true
    }
}

// Extend coordinator to implement delegate
extension MagicARView.Coordinator: FaceTrackingDelegate {
    func didDetectExpression(_ expression: FaceExpression) {
        viewModel.handleFaceExpression(expression)
    }
}
