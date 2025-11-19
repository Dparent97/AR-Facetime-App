//
//  HapticManager.swift
//  Aria's Magic SharePlay App
//
//  Manages haptic feedback for delightful interactions
//

import UIKit
import SwiftUI

enum HapticType {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
}

class HapticManager {
    static let shared = HapticManager()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private var isEnabled: Bool = true

    private init() {
        // Prepare generators for reduced latency
        light.prepare()
        medium.prepare()
        heavy.prepare()
        selection.prepare()
        notification.prepare()
    }

    func trigger(_ type: HapticType) {
        guard isEnabled else { return }

        // Respect reduce motion setting
        if UIAccessibility.isReduceMotionEnabled {
            return
        }

        switch type {
        case .light:
            light.impactOccurred()
            light.prepare()

        case .medium:
            medium.impactOccurred()
            medium.prepare()

        case .heavy:
            heavy.impactOccurred()
            heavy.prepare()

        case .selection:
            selection.selectionChanged()
            selection.prepare()

        case .success:
            notification.notificationOccurred(.success)
            notification.prepare()

        case .warning:
            notification.notificationOccurred(.warning)
            notification.prepare()

        case .error:
            notification.notificationOccurred(.error)
            notification.prepare()
        }
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
}

// SwiftUI View extension for easy haptic feedback
extension View {
    func hapticFeedback(_ type: HapticType, trigger: some Equatable) -> some View {
        self.onChange(of: trigger) { _, _ in
            HapticManager.shared.trigger(type)
        }
    }
}
