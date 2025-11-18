//
//  FaceTrackingService.swift
//  Aria's Magic SharePlay App
//
//  Handles face tracking and expression detection
//

import Foundation
import ARKit
import Combine

enum FaceExpression: String {
    case smile
    case eyebrowsRaised
    case mouthOpen

    var displayName: String {
        switch self {
        case .smile:
            return "Smile"
        case .eyebrowsRaised:
            return "Eyebrows Raised"
        case .mouthOpen:
            return "Mouth Open"
        }
    }
}

protocol FaceTrackingDelegate: AnyObject {
    func didDetectExpression(_ expression: FaceExpression)
}

class FaceTrackingService: ObservableObject {
    weak var delegate: FaceTrackingDelegate?

    // MARK: - Published Properties

    @Published var isEnabled: Bool = true
    @Published var lastDetectedExpression: FaceExpression?
    @Published var confidenceLevel: Float = 0.0

    // MARK: - Settings

    private var settings: SettingsService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Thresholds (configurable via settings)

    private var smileThreshold: Float {
        return settings.faceTrackingThreshold
    }

    private var eyebrowThreshold: Float {
        return settings.faceTrackingThreshold
    }

    private var mouthOpenThreshold: Float {
        return settings.faceTrackingThreshold * 0.8  // Slightly easier to trigger
    }

    private var debounceInterval: TimeInterval {
        return settings.faceTrackingDebounce
    }

    // MARK: - Debouncing

    private var lastSmileTime: Date?
    private var lastEyebrowTime: Date?
    private var lastMouthOpenTime: Date?

    // MARK: - Expression Tracking

    private var expressionHistory: [FaceExpression: [Float]] = [:]
    private let historySize = 5

    // MARK: - Initialization

    init(delegate: FaceTrackingDelegate? = nil, settings: SettingsService = .shared) {
        self.delegate = delegate
        self.settings = settings

        // Subscribe to settings changes
        settings.$faceTrackingEnabled
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Face Processing

    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        guard isEnabled else { return }

        // Check for smile
        if let leftSmile = faceAnchor.blendShapes[.mouthSmileLeft] as? Float,
           let rightSmile = faceAnchor.blendShapes[.mouthSmileRight] as? Float {
            let smileValue = (leftSmile + rightSmile) / 2.0
            let smoothedValue = smoothExpression(.smile, value: smileValue)

            if smoothedValue > smileThreshold {
                triggerExpression(.smile, confidence: smoothedValue, lastTime: &lastSmileTime)
            }
        }

        // Check for raised eyebrows
        if let leftBrow = faceAnchor.blendShapes[.browInnerUp] as? Float,
           let rightBrow = faceAnchor.blendShapes[.browInnerUp] as? Float {
            let browValue = (leftBrow + rightBrow) / 2.0
            let smoothedValue = smoothExpression(.eyebrowsRaised, value: browValue)

            if smoothedValue > eyebrowThreshold {
                triggerExpression(.eyebrowsRaised, confidence: smoothedValue, lastTime: &lastEyebrowTime)
            }
        }

        // Check for mouth open
        if let mouthOpen = faceAnchor.blendShapes[.jawOpen] as? Float {
            let smoothedValue = smoothExpression(.mouthOpen, value: mouthOpen)

            if smoothedValue > mouthOpenThreshold {
                triggerExpression(.mouthOpen, confidence: smoothedValue, lastTime: &lastMouthOpenTime)
            }
        }
    }

    // MARK: - Expression Smoothing

    /// Smooth expression values over time to reduce jitter
    /// - Parameters:
    ///   - expression: The expression being detected
    ///   - value: Current value from face anchor
    /// - Returns: Smoothed value
    private func smoothExpression(_ expression: FaceExpression, value: Float) -> Float {
        // Initialize history if needed
        if expressionHistory[expression] == nil {
            expressionHistory[expression] = []
        }

        // Add to history
        expressionHistory[expression]?.append(value)

        // Keep only recent history
        if let count = expressionHistory[expression]?.count, count > historySize {
            expressionHistory[expression]?.removeFirst()
        }

        // Calculate moving average
        guard let history = expressionHistory[expression], !history.isEmpty else {
            return value
        }

        return history.reduce(0, +) / Float(history.count)
    }

    private func triggerExpression(_ expression: FaceExpression, confidence: Float, lastTime: inout Date?) {
        let now = Date()

        // Debounce to prevent rapid firing
        if let last = lastTime, now.timeIntervalSince(last) < debounceInterval {
            return
        }

        lastTime = now

        DispatchQueue.main.async {
            self.lastDetectedExpression = expression
            self.confidenceLevel = confidence
            self.delegate?.didDetectExpression(expression)

            // Play sound effect if enabled
            if self.settings.soundEnabled {
                AudioService.shared.playSound(.faceTracking)
            }
        }
    }

    // MARK: - Manual Control

    /// Enable face tracking
    func enable() {
        isEnabled = true
    }

    /// Disable face tracking
    func disable() {
        isEnabled = false
    }

    /// Reset tracking state
    func reset() {
        lastSmileTime = nil
        lastEyebrowTime = nil
        lastMouthOpenTime = nil
        expressionHistory.removeAll()
        lastDetectedExpression = nil
        confidenceLevel = 0.0
    }

    // MARK: - Configuration

    /// Update sensitivity (convenience method)
    /// - Parameter sensitivity: Value from 0.0 (less sensitive) to 1.0 (more sensitive)
    func setSensitivity(_ sensitivity: Double) {
        settings.faceTrackingSensitivity = sensitivity
    }

    /// Update debounce interval (convenience method)
    /// - Parameter interval: Time interval in seconds
    func setDebounceInterval(_ interval: Double) {
        settings.faceTrackingDebounce = interval
    }

    // MARK: - Diagnostics

    /// Get current threshold values for debugging
    func getCurrentThresholds() -> [String: Float] {
        return [
            "smile": smileThreshold,
            "eyebrow": eyebrowThreshold,
            "mouthOpen": mouthOpenThreshold
        ]
    }

    /// Get expression history for debugging
    func getExpressionHistory() -> [FaceExpression: [Float]] {
        return expressionHistory
    }
}

// Extend coordinator to implement delegate
extension MagicARView.Coordinator: FaceTrackingDelegate {
    func didDetectExpression(_ expression: FaceExpression) {
        viewModel.handleFaceExpression(expression)
    }
}
