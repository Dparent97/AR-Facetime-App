//
//  AudioService.swift
//  Aria's Magic SharePlay App
//
//  Manages sound effects and audio playback
//

import Foundation
import AVFoundation
import Combine

/// Service for managing sound effects and audio playback
/// Handles preloading, volume control, and spatial audio
class AudioService: ObservableObject {

    // MARK: - Published Properties

    /// Whether sound effects are enabled
    @Published var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                stopAllSounds()
            }
        }
    }

    /// Volume level (0.0 to 1.0)
    @Published var volume: Float = 0.8 {
        didSet {
            updateVolume()
        }
    }

    // MARK: - Sound Effect Definitions

    enum SoundEffect: String, CaseIterable {
        // Character actions
        case characterSpawn = "character_spawn"
        case characterWave = "character_wave"
        case characterDance = "character_dance"
        case characterTwirl = "character_twirl"
        case characterJump = "character_jump"
        case characterSparkle = "character_sparkle"

        // Magic effects
        case sparkles = "effect_sparkles"
        case snow = "effect_snow"
        case bubbles = "effect_bubbles"

        // Face tracking
        case faceTracking = "face_detected"

        // UI sounds
        case buttonTap = "ui_tap"
        case success = "ui_success"
        case error = "ui_error"

        /// File extension for sound files
        var fileExtension: String {
            return "wav"  // Can be changed to m4a or other formats
        }
    }

    // MARK: - Private Properties

    private var audioEngine: AVAudioEngine
    private var audioPlayers: [SoundEffect: AVAudioPlayerNode] = [:]
    private var audioBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Singleton

    static let shared = AudioService()

    // MARK: - Initialization

    private init() {
        self.audioEngine = AVAudioEngine()
        setupAudioSession()
        setupAudioEngine()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("AudioService: Failed to setup audio session: \(error)")
        }
    }

    private func setupAudioEngine() {
        do {
            try audioEngine.start()
        } catch {
            print("AudioService: Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Preloading

    /// Preload all sound effects into memory for immediate playback
    func preloadSounds() {
        for effect in SoundEffect.allCases {
            preloadSound(effect)
        }
    }

    /// Preload a specific sound effect
    /// - Parameter effect: The sound effect to preload
    private func preloadSound(_ effect: SoundEffect) {
        // In a real implementation, load from app bundle
        // For now, we'll create placeholder buffers
        // When 3D Engineer provides sound files, update this to load actual files

        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: effect.fileExtension) else {
            print("AudioService: Sound file not found: \(effect.rawValue).\(effect.fileExtension)")
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: url)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                print("AudioService: Failed to create buffer for \(effect.rawValue)")
                return
            }

            try audioFile.read(into: buffer)
            audioBuffers[effect] = buffer

            // Create player node
            let playerNode = AVAudioPlayerNode()
            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: buffer.format)
            audioPlayers[effect] = playerNode

            print("AudioService: Preloaded \(effect.rawValue)")
        } catch {
            print("AudioService: Failed to load sound \(effect.rawValue): \(error)")
        }
    }

    // MARK: - Playback

    /// Play a sound effect
    /// - Parameter effect: The sound effect to play
    func playSound(_ effect: SoundEffect) {
        guard isEnabled else { return }

        // If sound not preloaded, try to load it now
        if audioBuffers[effect] == nil {
            preloadSound(effect)
        }

        guard let buffer = audioBuffers[effect],
              let player = audioPlayers[effect] else {
            print("AudioService: Sound not available: \(effect.rawValue)")
            return
        }

        // Schedule and play
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            // Completion handler
        }

        if !player.isPlaying {
            player.play()
        }
    }

    /// Play a sound effect with spatial audio at a specific position
    /// - Parameters:
    ///   - effect: The sound effect to play
    ///   - position: 3D position in AR space
    func playSound(_ effect: SoundEffect, at position: SIMD3<Float>) {
        // For Phase 2: Implement spatial audio with AVAudioEnvironmentNode
        // For now, just play the sound normally
        playSound(effect)
    }

    /// Stop all currently playing sounds
    func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
    }

    /// Stop a specific sound effect
    /// - Parameter effect: The sound effect to stop
    func stopSound(_ effect: SoundEffect) {
        audioPlayers[effect]?.stop()
    }

    // MARK: - Volume Control

    /// Update volume for all players
    private func updateVolume() {
        audioEngine.mainMixerNode.outputVolume = volume
    }

    /// Set volume level
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
    }

    /// Toggle sound on/off
    func toggleSound() {
        isEnabled.toggle()
    }

    // MARK: - Cleanup

    /// Clean up resources
    func cleanup() {
        stopAllSounds()
        for player in audioPlayers.values {
            audioEngine.detach(player)
        }
        audioPlayers.removeAll()
        audioBuffers.removeAll()
        audioEngine.stop()
    }
}

// MARK: - Convenience Extensions

extension AudioService {
    /// Play sound for a character action
    /// - Parameter action: The character action
    func playSoundForAction(_ action: CharacterAction) {
        switch action {
        case .idle:
            break
        case .wave:
            playSound(.characterWave)
        case .dance:
            playSound(.characterDance)
        case .twirl:
            playSound(.characterTwirl)
        case .jump:
            playSound(.characterJump)
        case .sparkle:
            playSound(.characterSparkle)
        }
    }

    /// Play sound for a magic effect
    /// - Parameter effect: The magic effect
    func playSoundForEffect(_ effect: MagicEffect) {
        switch effect {
        case .sparkles:
            playSound(.sparkles)
        case .snow:
            playSound(.snow)
        case .bubbles:
            playSound(.bubbles)
        }
    }
}
