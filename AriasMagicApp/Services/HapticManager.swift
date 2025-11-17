//
//  HapticManager.swift
//  Aria's Magic SharePlay App
//
//  Provides haptic feedback for tactile interactions
//

import UIKit
import SwiftUI

enum HapticType {
    case light      // Character picker scroll, settings toggle
    case medium     // Button taps, character selection
    case heavy      // Character spawn, major actions
    case success    // Face tracking triggers, SharePlay connection
    case warning    // Error states, max characters reached
    case selection  // UI selections
}

class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    // Settings (will be connected to SettingsService later)
    var isEnabled: Bool = true
    var respectReduceMotion: Bool = true

    private init() {
        // Prepare generators for lower latency
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    func trigger(_ type: HapticType) {
        // Check if haptics are enabled
        guard isEnabled else { return }

        // Respect reduce motion accessibility setting if enabled
        if respectReduceMotion && UIAccessibility.isReduceMotionEnabled {
            return
        }

        switch type {
        case .light:
            lightImpact.impactOccurred()
            lightImpact.prepare()

        case .medium:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()

        case .heavy:
            heavyImpact.impactOccurred()
            heavyImpact.prepare()

        case .success:
            notificationFeedback.notificationOccurred(.success)
            notificationFeedback.prepare()

        case .warning:
            notificationFeedback.notificationOccurred(.warning)
            notificationFeedback.prepare()

        case .selection:
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        }
    }

    // Convenience method for rapid-fire haptics (like dragging)
    func triggerContinuous(_ type: HapticType, interval: TimeInterval = 0.1) {
        trigger(type)
    }
}

// SwiftUI View extension for easy haptic access
extension View {
    func hapticFeedback(_ type: HapticType) -> some View {
        self.onTapGesture {
            HapticManager.shared.trigger(type)
        }
    }
}
