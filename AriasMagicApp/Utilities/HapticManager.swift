//
//  HapticManager.swift
//  Aria's Magic SharePlay App
//
//  Centralized haptic feedback system for delightful tactile responses
//

import UIKit

/// Types of haptic feedback available in the app
enum HapticType {
    case light      // Subtle feedback (picker scroll, toggles)
    case medium     // Standard feedback (button taps, selections)
    case heavy      // Prominent feedback (character spawn, major actions)
    case success    // Positive confirmation (face tracking trigger, connection)
    case warning    // Alert user to issues (errors, limits reached)
    case error      // Critical issues
    case selection  // Selection change feedback
}

/// Manages haptic feedback throughout the app
/// Respects user accessibility preferences (reduce motion)
class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Haptic Generators

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        // Prepare generators for lower latency
        prepareGenerators()
    }

    // MARK: - Public Methods

    /// Trigger a haptic feedback of the specified type
    /// - Parameter type: The type of haptic feedback to trigger
    func trigger(_ type: HapticType) {
        // Respect reduce motion accessibility setting
        guard !UIAccessibility.isReduceMotionEnabled else {
            return
        }

        switch type {
        case .light:
            lightImpact.impactOccurred()

        case .medium:
            mediumImpact.impactOccurred()

        case .heavy:
            heavyImpact.impactOccurred()

        case .success:
            notificationFeedback.notificationOccurred(.success)

        case .warning:
            notificationFeedback.notificationOccurred(.warning)

        case .error:
            notificationFeedback.notificationOccurred(.error)

        case .selection:
            selectionFeedback.selectionChanged()
        }

        // Re-prepare generator for next use
        prepareGenerator(for: type)
    }

    /// Prepare haptic generators for immediate response
    /// Call this before expected haptic events for lowest latency
    func prepare(for type: HapticType) {
        prepareGenerator(for: type)
    }

    // MARK: - Private Methods

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    private func prepareGenerator(for type: HapticType) {
        switch type {
        case .light:
            lightImpact.prepare()
        case .medium:
            mediumImpact.prepare()
        case .heavy:
            heavyImpact.prepare()
        case .success, .warning, .error:
            notificationFeedback.prepare()
        case .selection:
            selectionFeedback.prepare()
        }
    }
}

// MARK: - Convenience Extensions

extension HapticManager {

    /// Trigger haptic for button tap
    func buttonTap() {
        trigger(.medium)
    }

    /// Trigger haptic for character selection
    func characterSelected() {
        trigger(.selection)
    }

    /// Trigger haptic for character spawn
    func characterSpawned() {
        trigger(.heavy)
    }

    /// Trigger haptic for action performed
    func actionPerformed() {
        trigger(.medium)
    }

    /// Trigger haptic for effect triggered
    func effectTriggered() {
        trigger(.light)
    }

    /// Trigger haptic for scroll snap
    func scrollSnap() {
        trigger(.light)
    }

    /// Trigger haptic for successful face tracking trigger
    func faceTrackingSuccess() {
        trigger(.success)
    }

    /// Trigger haptic for error state
    func errorOccurred() {
        trigger(.error)
    }

    /// Trigger haptic for reaching limit
    func limitReached() {
        trigger(.warning)
    }
}
