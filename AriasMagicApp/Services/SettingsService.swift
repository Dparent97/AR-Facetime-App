//
//  SettingsService.swift
//  Aria's Magic SharePlay App
//
//  User preferences and settings management
//

import Foundation
import SwiftUI

/// Service for managing user preferences and app settings
///
/// Uses @AppStorage for automatic persistence to UserDefaults
/// All settings are observable and can be bound directly to SwiftUI views
class SettingsService: ObservableObject {
    // MARK: - Onboarding

    /// Whether the user has completed onboarding
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false

    // MARK: - Audio Settings

    /// Whether sound effects are enabled
    @AppStorage("soundEnabled") var soundEnabled = true {
        didSet {
            notifyAudioServiceOfChange()
        }
    }

    /// Sound volume (0.0 to 1.0)
    @AppStorage("soundVolume") var soundVolume = 0.8 {
        didSet {
            notifyAudioServiceOfChange()
        }
    }

    // MARK: - Face Tracking Settings

    /// Whether face tracking is enabled
    @AppStorage("faceTrackingEnabled") var faceTrackingEnabled = true

    /// Face tracking sensitivity (0.0 = very sensitive, 1.0 = less sensitive)
    @AppStorage("faceTrackingSensitivity") var faceTrackingSensitivity = 0.5

    // MARK: - Character Settings

    /// Default character type to spawn
    @AppStorage("defaultCharacterType") var defaultCharacterType: String = CharacterType.sparkleThePrincess.rawValue

    /// Maximum number of characters allowed in scene
    @AppStorage("maxCharacters") var maxCharacters = 10

    // MARK: - Visual Settings

    /// Selected theme/color scheme
    @AppStorage("selectedTheme") var selectedTheme = "default"

    /// Whether to show performance stats overlay
    @AppStorage("showPerformanceStats") var showPerformanceStats = false

    /// Whether to show tutorial hints
    @AppStorage("showHints") var showHints = true

    // MARK: - SharePlay Settings

    /// Whether to auto-join SharePlay sessions
    @AppStorage("autoJoinSharePlay") var autoJoinSharePlay = false

    /// Whether to sync all actions in SharePlay (or only spawns)
    @AppStorage("syncAllActions") var syncAllActions = true

    // MARK: - Accessibility

    /// Reduce motion effects
    @AppStorage("reduceMotion") var reduceMotion = false

    /// Increase contrast
    @AppStorage("increaseContrast") var increaseContrast = false

    // MARK: - Developer Settings

    /// Whether developer mode is enabled
    @AppStorage("developerMode") var developerMode = false

    /// Show debug logs in console
    @AppStorage("showDebugLogs") var showDebugLogs = false

    // MARK: - Dependencies

    private weak var audioService: AudioService?

    // MARK: - Initialization

    init(audioService: AudioService? = nil) {
        self.audioService = audioService
    }

    /// Set the audio service for automatic updates
    func setAudioService(_ service: AudioService) {
        self.audioService = service
        notifyAudioServiceOfChange()
    }

    // MARK: - Settings Management

    /// Reset all settings to default values
    func resetToDefaults() {
        hasSeenOnboarding = false
        soundEnabled = true
        soundVolume = 0.8
        faceTrackingEnabled = true
        faceTrackingSensitivity = 0.5
        defaultCharacterType = CharacterType.sparkleThePrincess.rawValue
        maxCharacters = 10
        selectedTheme = "default"
        showPerformanceStats = false
        showHints = true
        autoJoinSharePlay = false
        syncAllActions = true
        reduceMotion = false
        increaseContrast = false
        developerMode = false
        showDebugLogs = false

        print("✅ Settings: Reset to defaults")
    }

    /// Export all settings as a dictionary (for debugging/backup)
    func exportSettings() -> [String: Any] {
        return [
            "hasSeenOnboarding": hasSeenOnboarding,
            "soundEnabled": soundEnabled,
            "soundVolume": soundVolume,
            "faceTrackingEnabled": faceTrackingEnabled,
            "faceTrackingSensitivity": faceTrackingSensitivity,
            "defaultCharacterType": defaultCharacterType,
            "maxCharacters": maxCharacters,
            "selectedTheme": selectedTheme,
            "showPerformanceStats": showPerformanceStats,
            "showHints": showHints,
            "autoJoinSharePlay": autoJoinSharePlay,
            "syncAllActions": syncAllActions,
            "reduceMotion": reduceMotion,
            "increaseContrast": increaseContrast,
            "developerMode": developerMode,
            "showDebugLogs": showDebugLogs
        ]
    }

    /// Import settings from a dictionary
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
        if let value = settings["defaultCharacterType"] as? String {
            defaultCharacterType = value
        }
        if let value = settings["maxCharacters"] as? Int {
            maxCharacters = value
        }
        if let value = settings["selectedTheme"] as? String {
            selectedTheme = value
        }
        if let value = settings["showPerformanceStats"] as? Bool {
            showPerformanceStats = value
        }
        if let value = settings["showHints"] as? Bool {
            showHints = value
        }
        if let value = settings["autoJoinSharePlay"] as? Bool {
            autoJoinSharePlay = value
        }
        if let value = settings["syncAllActions"] as? Bool {
            syncAllActions = value
        }
        if let value = settings["reduceMotion"] as? Bool {
            reduceMotion = value
        }
        if let value = settings["increaseContrast"] as? Bool {
            increaseContrast = value
        }
        if let value = settings["developerMode"] as? Bool {
            developerMode = value
        }
        if let value = settings["showDebugLogs"] as? Bool {
            showDebugLogs = value
        }

        print("✅ Settings: Imported settings")
    }

    // MARK: - Computed Properties

    /// Get the selected character type enum
    var selectedCharacterType: CharacterType {
        CharacterType(rawValue: defaultCharacterType) ?? .sparkleThePrincess
    }

    /// Get face tracking sensitivity as a multiplier
    var faceTrackingSensitivityMultiplier: Float {
        // Convert 0-1 range to 0.5-2.0 range (inverted)
        // Higher sensitivity value = lower threshold
        Float(1.5 - faceTrackingSensitivity)
    }

    // MARK: - Private Helpers

    private func notifyAudioServiceOfChange() {
        guard let audioService = audioService else { return }

        audioService.isEnabled = soundEnabled
        audioService.volume = Float(soundVolume)
    }
}

// MARK: - Convenience Extensions

extension SettingsService {
    /// Check if character spawn limit has been reached
    func canSpawnMoreCharacters(currentCount: Int) -> Bool {
        return currentCount < maxCharacters
    }

    /// Get appropriate animation duration based on reduce motion setting
    func animationDuration(_ baseDuration: Double) -> Double {
        return reduceMotion ? baseDuration * 0.5 : baseDuration
    }
}
