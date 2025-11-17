//
//  AudioService.swift
//  Aria's Magic SharePlay App
//
//  Service for playing sound effects and managing audio
//

import Foundation
import AVFoundation
import Combine

/// Sound effect types for character actions
enum CharacterSound: String {
    case spawn = "character_spawn"
    case wave = "character_wave"
    case dance = "character_dance"
    case twirl = "character_twirl"
    case jump = "character_jump"
    case sparkle = "character_sparkle"
}

/// Sound effect types for magical effects
enum EffectSound: String {
    case sparkles = "effect_sparkles"
    case snow = "effect_snow"
    case bubbles = "effect_bubbles"
}

/// Sound effect types for face tracking interactions
enum FaceTrackingSound: String {
    case smile = "face_smile"
    case eyebrows = "face_eyebrows"
    case mouth = "face_mouth"
}

/// Manages audio playback for the app
class AudioService: ObservableObject {

    // MARK: - Singleton

    static let shared = AudioService()

    // MARK: - Published Properties

    /// Master volume (0.0 to 1.0)
    @Published var masterVolume: Float = 0.7

    /// Whether sound effects are enabled
    @Published var soundEffectsEnabled: Bool = true

    /// Whether spatial audio is enabled
    @Published var spatialAudioEnabled: Bool = true

    // MARK: - Private Properties

    /// Active audio players for simultaneous playback
    private var activePlayers: [UUID: AVAudioPlayer] = [:]

    /// Lock for thread-safe player management
    private let playerLock = NSLock()

    /// Audio session configuration
    private let audioSession = AVAudioSession.sharedInstance()

    // MARK: - Initialization

    private init() {
        setupAudioSession()
        preloadSounds()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            // Configure audio session for playback with other audio
            try audioSession.setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try audioSession.setActive(true)
            print("AudioService: Audio session configured successfully")
        } catch {
            print("AudioService: Failed to setup audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Sound Preloading

    /// Preload all sound effects at app launch
    private func preloadSounds() {
        AssetLoader.shared.preloadSounds { success in
            if success {
                print("AudioService: Sound effects preloaded")
            } else {
                print("AudioService: Some sound effects failed to preload (files may not exist yet)")
            }
        }
    }

    // MARK: - Sound Playback

    /// Play a character action sound
    /// - Parameters:
    ///   - sound: The character sound to play
    ///   - volume: Optional volume override (0.0 to 1.0)
    func playSound(_ sound: CharacterSound, volume: Float? = nil) {
        guard soundEffectsEnabled else { return }
        playAudio(named: sound.rawValue, volume: volume)
    }

    /// Play a magical effect sound
    /// - Parameters:
    ///   - sound: The effect sound to play
    ///   - volume: Optional volume override (0.0 to 1.0)
    func playEffect(_ sound: EffectSound, volume: Float? = nil) {
        guard soundEffectsEnabled else { return }
        playAudio(named: sound.rawValue, volume: volume)
    }

    /// Play a face tracking sound
    /// - Parameters:
    ///   - sound: The face tracking sound to play
    ///   - volume: Optional volume override (0.0 to 1.0)
    func playFaceSound(_ sound: FaceTrackingSound, volume: Float? = nil) {
        guard soundEffectsEnabled else { return }
        playAudio(named: sound.rawValue, volume: volume)
    }

    /// Core audio playback function
    private func playAudio(named soundName: String, volume: Float? = nil) {
        // Get sound from asset loader
        guard let cachedPlayer = AssetLoader.shared.getSound(named: soundName) else {
            print("AudioService: Sound not found: \(soundName)")
            return
        }

        // Create a copy of the player for concurrent playback
        guard let soundData = try? Data(contentsOf: cachedPlayer.url!),
              let player = try? AVAudioPlayer(data: soundData) else {
            print("AudioService: Failed to create player for: \(soundName)")
            return
        }

        // Configure player
        player.volume = volume ?? masterVolume
        player.prepareToPlay()

        // Store player reference
        let playerId = UUID()
        playerLock.lock()
        activePlayers[playerId] = player
        playerLock.unlock()

        // Play sound
        player.play()

        // Clean up after playback
        DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.5) { [weak self] in
            self?.playerLock.lock()
            self?.activePlayers.removeValue(forKey: playerId)
            self?.playerLock.unlock()
        }
    }

    // MARK: - Spatial Audio

    /// Play a sound with spatial audio positioning
    /// - Parameters:
    ///   - sound: The character sound to play
    ///   - position: 3D position in world space
    func playSpatialSound(_ sound: CharacterSound, at position: SIMD3<Float>) {
        guard soundEffectsEnabled && spatialAudioEnabled else {
            // Fall back to regular playback
            playSound(sound)
            return
        }

        // For now, fall back to regular playback
        // TODO: Implement true spatial audio with RealityKit's audio capabilities
        playSound(sound, volume: calculateVolumeForDistance(to: position))
    }

    /// Calculate volume based on distance from camera/listener
    private func calculateVolumeForDistance(to position: SIMD3<Float>) -> Float {
        let distance = length(position)
        let maxDistance: Float = 5.0 // Maximum hearing distance

        if distance >= maxDistance {
            return 0.0
        }

        // Linear falloff
        let volumeMultiplier = 1.0 - (distance / maxDistance)
        return masterVolume * max(0.0, min(1.0, volumeMultiplier))
    }

    // MARK: - Volume Control

    /// Set master volume for all sound effects
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0.0, min(1.0, volume))

        // Update all active players
        playerLock.lock()
        for player in activePlayers.values {
            player.volume = masterVolume
        }
        playerLock.unlock()
    }

    /// Toggle sound effects on/off
    func toggleSoundEffects() {
        soundEffectsEnabled.toggle()

        if !soundEffectsEnabled {
            stopAllSounds()
        }
    }

    /// Stop all currently playing sounds
    func stopAllSounds() {
        playerLock.lock()
        for player in activePlayers.values {
            player.stop()
        }
        activePlayers.removeAll()
        playerLock.unlock()
    }

    // MARK: - Testing & Debug

    /// Test a sound by name (for debugging)
    func testSound(named soundName: String) {
        print("AudioService: Testing sound: \(soundName)")
        playAudio(named: soundName)
    }

    /// Get list of all loaded sounds
    func getLoadedSounds() -> [String] {
        // This would require tracking loaded sounds
        // For now, return expected sound list
        return [
            "character_spawn", "character_wave", "character_dance",
            "character_twirl", "character_jump", "character_sparkle",
            "effect_sparkles", "effect_snow", "effect_bubbles",
            "face_smile", "face_eyebrows", "face_mouth"
        ]
    }
}

// MARK: - Character Action Integration

extension Character {

    /// Play sound for character action
    func playActionSound() {
        let sound: CharacterSound

        switch currentAction {
        case .idle:
            return // No sound for idle
        case .wave:
            sound = .wave
        case .dance:
            sound = .dance
        case .twirl:
            sound = .twirl
        case .jump:
            sound = .jump
        case .sparkle:
            sound = .sparkle
        }

        AudioService.shared.playSound(sound)
    }
}
