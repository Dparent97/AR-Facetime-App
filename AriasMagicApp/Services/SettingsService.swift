//
//  SettingsService.swift
//  Aria's Magic SharePlay App
//
//  Manages user preferences and settings
//

import Foundation
import SwiftUI
import Combine

/// Service for managing user preferences and app settings
/// Uses UserDefaults for persistence with SwiftUI @AppStorage integration
class SettingsService: ObservableObject {

    // MARK: - Singleton

    static let shared = SettingsService()

    // MARK: - Onboarding

    /// Whether the user has completed onboarding
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    // MARK: - Audio Settings

    /// Whether sound effects are enabled
    @AppStorage("soundEnabled") var soundEnabled: Bool = true {
        didSet {
            AudioService.shared.isEnabled = soundEnabled
        }
    }

    /// Sound volume (0.0 to 1.0)
    @AppStorage("soundVolume") var soundVolume: Double = 0.8 {
        didSet {
            AudioService.shared.volume = Float(soundVolume)
        }
    }

    // MARK: - Face Tracking Settings

    /// Whether face tracking is enabled
    @AppStorage("faceTrackingEnabled") var faceTrackingEnabled: Bool = true

    /// Face tracking sensitivity (0.0 = less sensitive, 1.0 = more sensitive)
    @AppStorage("faceTrackingSensitivity") var faceTrackingSensitivity: Double = 0.5

    /// Face tracking debounce interval in seconds
    @AppStorage("faceTrackingDebounce") var faceTrackingDebounce: Double = 1.0

    // MARK: - Character Settings

    /// Last selected character type
    @AppStorage("lastSelectedCharacterType") var lastSelectedCharacterType: String = CharacterType.sparkleThePrincess.rawValue

    /// Maximum number of characters allowed in scene
    @AppStorage("maxCharacters") var maxCharacters: Int = 10

    // MARK: - Visual Settings

    /// Whether to show performance stats
    @AppStorage("showPerformanceStats") var showPerformanceStats: Bool = false

    /// Whether to enable debug mode
    @AppStorage("debugModeEnabled") var debugModeEnabled: Bool = false

    /// Selected theme (for future customization)
    @AppStorage("selectedTheme") var selectedTheme: String = "default"

    // MARK: - Accessibility Settings

    /// Whether to enable reduced motion
    @AppStorage("reduceMotion") var reduceMotion: Bool = false

    /// Whether to use high contrast mode
    @AppStorage("highContrast") var highContrast: Bool = false

    // MARK: - SharePlay Settings

    /// Whether SharePlay is automatically enabled
    @AppStorage("autoSharePlay") var autoSharePlay: Bool = false

    /// Whether to show SharePlay notifications
    @AppStorage("sharePlayNotifications") var sharePlayNotifications: Bool = true

    // MARK: - Initialization

    private init() {
        // Apply settings on initialization
        applySavedSettings()
    }

    // MARK: - Apply Settings

    /// Apply all saved settings to relevant services
    private func applySavedSettings() {
        AudioService.shared.isEnabled = soundEnabled
        AudioService.shared.volume = Float(soundVolume)
    }

    // MARK: - Reset

    /// Reset all settings to default values
    func resetToDefaults() {
        hasSeenOnboarding = false
        soundEnabled = true
        soundVolume = 0.8
        faceTrackingEnabled = true
        faceTrackingSensitivity = 0.5
        faceTrackingDebounce = 1.0
        lastSelectedCharacterType = CharacterType.sparkleThePrincess.rawValue
        maxCharacters = 10
        showPerformanceStats = false
        debugModeEnabled = false
        selectedTheme = "default"
        reduceMotion = false
        highContrast = false
        autoSharePlay = false
        sharePlayNotifications = true

        applySavedSettings()
    }

    // MARK: - Export/Import

    /// Export all settings as a dictionary
    /// - Returns: Dictionary of all settings
    func exportSettings() -> [String: Any] {
        return [
            "hasSeenOnboarding": hasSeenOnboarding,
            "soundEnabled": soundEnabled,
            "soundVolume": soundVolume,
            "faceTrackingEnabled": faceTrackingEnabled,
            "faceTrackingSensitivity": faceTrackingSensitivity,
            "faceTrackingDebounce": faceTrackingDebounce,
            "lastSelectedCharacterType": lastSelectedCharacterType,
            "maxCharacters": maxCharacters,
            "showPerformanceStats": showPerformanceStats,
            "debugModeEnabled": debugModeEnabled,
            "selectedTheme": selectedTheme,
            "reduceMotion": reduceMotion,
            "highContrast": highContrast,
            "autoSharePlay": autoSharePlay,
            "sharePlayNotifications": sharePlayNotifications
        ]
    }

    /// Import settings from a dictionary
    /// - Parameter settings: Dictionary of settings to import
    func importSettings(_ settings: [String: Any]) {
        if let value = settings["hasSeenOnboarding"] as? Bool {
            hasSeenOnboarding = value
        }
        if let value = settings["soundEnabled"] as? Bool {
            soundEnabled = value
        }
        if let value = settings["soundVolume"] as? Double {
            soundVolume = value
        }
        if let value = settings["faceTrackingEnabled"] as? Bool {
            faceTrackingEnabled = value
        }
        if let value = settings["faceTrackingSensitivity"] as? Double {
            faceTrackingSensitivity = value
        }
        if let value = settings["faceTrackingDebounce"] as? Double {
            faceTrackingDebounce = value
        }
        if let value = settings["lastSelectedCharacterType"] as? String {
            lastSelectedCharacterType = value
        }
        if let value = settings["maxCharacters"] as? Int {
            maxCharacters = value
        }
        if let value = settings["showPerformanceStats"] as? Bool {
            showPerformanceStats = value
        }
        if let value = settings["debugModeEnabled"] as? Bool {
            debugModeEnabled = value
        }
        if let value = settings["selectedTheme"] as? String {
            selectedTheme = value
        }
        if let value = settings["reduceMotion"] as? Bool {
            reduceMotion = value
        }
        if let value = settings["highContrast"] as? Bool {
            highContrast = value
        }
        if let value = settings["autoSharePlay"] as? Bool {
            autoSharePlay = value
        }
        if let value = settings["sharePlayNotifications"] as? Bool {
            sharePlayNotifications = value
        }

        applySavedSettings()
    }

    // MARK: - Computed Properties

    /// Get face tracking threshold based on sensitivity
    /// Higher sensitivity = lower threshold
    var faceTrackingThreshold: Float {
        return Float(1.0 - faceTrackingSensitivity) * 0.5 + 0.2
    }

    /// Get character type from last selected
    var lastCharacterType: CharacterType? {
        return CharacterType(rawValue: lastSelectedCharacterType)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension SettingsService {
    /// Create a mock settings service for previews
    static var mock: SettingsService {
        let service = SettingsService.shared
        service.debugModeEnabled = true
        return service
    }
}
#endif
