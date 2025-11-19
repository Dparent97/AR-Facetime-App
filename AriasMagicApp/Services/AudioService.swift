//
//  AudioService.swift
//  Aria's Magic SharePlay App
//
//  Audio service for playing sound effects with spatial audio support
//

import Foundation
import AVFoundation
import RealityKit

// MARK: - Sound Effect Types

/// All available sound effects in the app
enum SoundEffect: String, CaseIterable {
    // Character action sounds
    case characterSpawn = "character_spawn"
    case characterWave = "character_wave"
    case characterDance = "character_dance"
    case characterTwirl = "character_twirl"
    case characterJump = "character_jump"
    case characterSparkle = "character_sparkle"

    // Magic effect sounds
    case effectSparkles = "effect_sparkles"
    case effectSnow = "effect_snow"
    case effectBubbles = "effect_bubbles"

    // Face tracking sounds
    case faceSmile = "face_smile"
    case faceEyebrows = "face_eyebrows"
    case faceMouth = "face_mouth"

    /// The filename (without extension) for this sound
    var fileName: String {
        return rawValue
    }

    /// Display name for debugging
    var displayName: String {
        switch self {
        case .characterSpawn:
            return "Character Spawn"
        case .characterWave:
            return "Wave"
        case .characterDance:
            return "Dance"
        case .characterTwirl:
            return "Twirl"
        case .characterJump:
            return "Jump"
        case .characterSparkle:
            return "Sparkle"
        case .effectSparkles:
            return "Sparkles Effect"
        case .effectSnow:
            return "Snow Effect"
        case .effectBubbles:
            return "Bubbles Effect"
        case .faceSmile:
            return "Smile Detected"
        case .faceEyebrows:
            return "Eyebrows Raised"
        case .faceMouth:
            return "Mouth Open"
        }
    }

    /// Get sound effect for character action
    static func forAction(_ action: CharacterAction) -> SoundEffect? {
        switch action {
        case .idle:
            return nil // No sound for idle
        case .wave:
            return .characterWave
        case .dance:
            return .characterDance
        case .twirl:
            return .characterTwirl
        case .jump:
            return .characterJump
        case .sparkle:
            return .characterSparkle
        }
    }

    /// Get sound effect for magic effect
    static func forEffect(_ effect: MagicEffect) -> SoundEffect {
        switch effect {
        case .sparkles:
            return .effectSparkles
        case .snow:
            return .effectSnow
        case .bubbles:
            return .effectBubbles
        }
    }
}

// MARK: - Audio Service

/// Service for managing audio playback with spatial audio support
class AudioService: NSObject {
    /// Shared singleton instance
    static let shared = AudioService()

    // MARK: - Properties

    /// Audio players for background sounds
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]

    /// Audio engine for spatial audio (future enhancement)
    private var audioEngine: AVAudioEngine?

    /// Master volume (0.0 to 1.0)
    private(set) var masterVolume: Float = 0.7

    /// Whether sound effects are enabled
    private(set) var isSoundEnabled: Bool = true

    /// Sound effect cache status
    private var loadedSounds: Set<SoundEffect> = []

    // MARK: - Initialization

    private override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    /// Configure the audio session for the app
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Set category to allow audio with other apps (SharePlay, music, etc.)
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)

            print("✅ AudioService: Audio session configured")
        } catch {
            print("❌ AudioService: Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Sound Loading

    /// Preload all sound effects
    func preloadSounds() {
        print("🔄 AudioService: Preloading sounds...")

        for soundEffect in SoundEffect.allCases {
            preloadSound(soundEffect)
        }

        print("✅ AudioService: Preloaded \(loadedSounds.count)/\(SoundEffect.allCases.count) sounds")
    }

    /// Preload a specific sound effect
    /// - Parameter sound: The sound effect to preload
    private func preloadSound(_ sound: SoundEffect) {
        guard let url = soundURL(for: sound) else {
            print("⚠️ AudioService: Sound file not found: \(sound.fileName)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = masterVolume
            audioPlayers[sound] = player
            loadedSounds.insert(sound)
        } catch {
            print("❌ AudioService: Failed to load sound \(sound.fileName): \(error)")
        }
    }

    /// Get URL for sound file
    /// - Parameter sound: The sound effect
    /// - Returns: URL to the sound file, or nil if not found
    private func soundURL(for sound: SoundEffect) -> URL? {
        // Try .m4a first (preferred format)
        if let url = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a", subdirectory: "Resources/Sounds") {
            return url
        }

        // Fall back to .wav
        if let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav", subdirectory: "Resources/Sounds") {
            return url
        }

        return nil
    }

    // MARK: - Sound Playback

    /// Play a sound effect
    /// - Parameters:
    ///   - sound: The sound effect to play
    ///   - volume: Optional volume override (0.0 to 1.0)
    func playSound(_ sound: SoundEffect, volume: Float? = nil) {
        guard isSoundEnabled else { return }

        // If sound is already loaded, play it
        if let player = audioPlayers[sound] {
            player.volume = volume ?? masterVolume
            player.currentTime = 0 // Reset to beginning
            player.play()
            return
        }

        // Otherwise, load and play
        guard let url = soundURL(for: sound) else {
            print("⚠️ AudioService: Sound file not found: \(sound.fileName)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume ?? masterVolume
            player.play()
            audioPlayers[sound] = player
            loadedSounds.insert(sound)
        } catch {
            print("❌ AudioService: Failed to play sound \(sound.fileName): \(error)")
        }
    }

    /// Play a sound at a specific position in AR space (spatial audio)
    /// - Parameters:
    ///   - sound: The sound effect to play
    ///   - position: The 3D position in AR space
    ///   - volume: Optional volume override
    func playSound(_ sound: SoundEffect, at position: SIMD3<Float>, volume: Float? = nil) {
        // For now, play normally
        // TODO: Implement proper spatial audio with AudioEntity when USDZ models are ready
        playSound(sound, volume: volume)

        // Future implementation with RealityKit:
        // 1. Create AudioResource from sound file
        // 2. Create AudioPlaybackController with spatial audio
        // 3. Attach to entity at position
    }

    /// Play sound for character action
    /// - Parameters:
    ///   - action: The character action
    ///   - position: Optional position for spatial audio
    func playSoundForAction(_ action: CharacterAction, at position: SIMD3<Float>? = nil) {
        guard let sound = SoundEffect.forAction(action) else { return }

        if let position = position {
            playSound(sound, at: position)
        } else {
            playSound(sound)
        }
    }

    /// Play sound for magic effect
    /// - Parameters:
    ///   - effect: The magic effect
    ///   - position: Optional position for spatial audio
    func playSoundForEffect(_ effect: MagicEffect, at position: SIMD3<Float>? = nil) {
        let sound = SoundEffect.forEffect(effect)

        if let position = position {
            playSound(sound, at: position)
        } else {
            playSound(sound)
        }
    }

    // MARK: - Volume Control

    /// Set the master volume
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0.0, min(1.0, volume))

        // Update all loaded players
        for (_, player) in audioPlayers {
            player.volume = masterVolume
        }

        print("🔊 AudioService: Master volume set to \(Int(masterVolume * 100))%")
    }

    /// Enable or disable sound effects
    /// - Parameter enabled: Whether to enable sounds
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled

        if !enabled {
            stopAllSounds()
        }

        print("🔊 AudioService: Sound \(enabled ? "enabled" : "disabled")")
    }

    // MARK: - Playback Control

    /// Stop all currently playing sounds
    func stopAllSounds() {
        for (_, player) in audioPlayers {
            player.stop()
        }
    }

    /// Stop a specific sound
    /// - Parameter sound: The sound to stop
    func stopSound(_ sound: SoundEffect) {
        audioPlayers[sound]?.stop()
    }

    // MARK: - Cache Management

    /// Clear all loaded sound effects
    func clearCache() {
        stopAllSounds()
        audioPlayers.removeAll()
        loadedSounds.removeAll()
        print("🗑️ AudioService: Sound cache cleared")
    }

    /// Get loaded sounds count
    var loadedSoundsCount: Int {
        return loadedSounds.count
    }

    /// Check if a sound is loaded
    /// - Parameter sound: The sound effect to check
    /// - Returns: True if sound is loaded
    func isSoundLoaded(_ sound: SoundEffect) -> Bool {
        return loadedSounds.contains(sound)
    }

    /// Validate all sound files exist
    /// - Returns: Array of missing sound files
    func validateSounds() -> [String] {
        var missingSounds: [String] = []

        for sound in SoundEffect.allCases {
            if soundURL(for: sound) == nil {
                missingSounds.append(sound.fileName)
            }
        }

        return missingSounds
    }

    /// Print audio service status
    func printStatus() {
        print("📊 AudioService Status:")
        print("   Enabled: \(isSoundEnabled)")
        print("   Master Volume: \(Int(masterVolume * 100))%")
        print("   Loaded Sounds: \(loadedSoundsCount)/\(SoundEffect.allCases.count)")

        let missing = validateSounds()
        if !missing.isEmpty {
            print("   Missing: \(missing.joined(separator: ", "))")
        }
    }
}

// MARK: - Audio Entity Extension (Future Enhancement)

extension AudioService {
    /// Create an audio entity for spatial audio in RealityKit
    /// This will be used when we have proper USDZ models
    /// - Parameters:
    ///   - sound: The sound effect
    ///   - position: Position in AR space
    /// - Returns: An entity with audio component
    func createAudioEntity(for sound: SoundEffect, at position: SIMD3<Float>) -> Entity? {
        // This is a placeholder for future spatial audio implementation
        // When USDZ models are ready, we'll use AudioFileResource and AudioPlaybackController

        /*
        guard let url = soundURL(for: sound) else { return nil }

        do {
            let audioResource = try AudioFileResource.load(contentsOf: url)
            let audioEntity = Entity()
            audioEntity.position = position

            let audioController = audioEntity.prepareAudio(audioResource)
            audioController.play()

            return audioEntity
        } catch {
            print("❌ AudioService: Failed to create audio entity: \(error)")
            return nil
        }
        */

        return nil
    }
}
