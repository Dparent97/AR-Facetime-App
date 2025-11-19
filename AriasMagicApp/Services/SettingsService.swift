//
//  SettingsService.swift
//  Aria's Magic SharePlay App
//
//  Manages app settings and user preferences
//

import Foundation
import Combine
import SwiftUI

class SettingsService: ObservableObject {
    static let shared = SettingsService()

    // Audio settings
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }

    @Published var soundVolume: Double {
        didSet {
            UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
        }
    }

    // Face tracking settings
    @Published var faceTrackingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(faceTrackingEnabled, forKey: "faceTrackingEnabled")
        }
    }

    @Published var faceTrackingSensitivity: Double {
        didSet {
            UserDefaults.standard.set(faceTrackingSensitivity, forKey: "faceTrackingSensitivity")
        }
    }

    // Accessibility settings
    @Published var reduceMotion: Bool {
        didSet {
            UserDefaults.standard.set(reduceMotion, forKey: "reduceMotion")
            updateHapticManager()
        }
    }

    @Published var highContrast: Bool {
        didSet {
            UserDefaults.standard.set(highContrast, forKey: "highContrast")
        }
    }

    @Published var uiScale: Double {
        didSet {
            UserDefaults.standard.set(uiScale, forKey: "uiScale")
        }
    }

    // App info
    let appVersion: String
    let buildNumber: String

    private init() {
        // Load settings from UserDefaults with sensible defaults
        self.soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.soundVolume = UserDefaults.standard.object(forKey: "soundVolume") as? Double ?? 0.8

        self.faceTrackingEnabled = UserDefaults.standard.object(forKey: "faceTrackingEnabled") as? Bool ?? true
        self.faceTrackingSensitivity = UserDefaults.standard.object(forKey: "faceTrackingSensitivity") as? Double ?? 0.5

        self.reduceMotion = UserDefaults.standard.object(forKey: "reduceMotion") as? Bool ?? UIAccessibility.isReduceMotionEnabled
        self.highContrast = UserDefaults.standard.object(forKey: "highContrast") as? Bool ?? false
        self.uiScale = UserDefaults.standard.object(forKey: "uiScale") as? Double ?? 1.0

        // Get app version info
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        // Set up accessibility observers
        setupAccessibilityObservers()
        updateHapticManager()
    }

    private func setupAccessibilityObservers() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reduceMotion = UIAccessibility.isReduceMotionEnabled
        }
    }

    private func updateHapticManager() {
        HapticManager.shared.setEnabled(!reduceMotion)
    }

    func resetToDefaults() {
        soundEnabled = true
        soundVolume = 0.8
        faceTrackingEnabled = true
        faceTrackingSensitivity = 0.5
        reduceMotion = UIAccessibility.isReduceMotionEnabled
        highContrast = false
        uiScale = 1.0
    }
}
