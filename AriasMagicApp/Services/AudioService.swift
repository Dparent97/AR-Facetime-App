//
//  AudioService.swift
//  Aria's Magic SharePlay App
//
//  Manages sound effects for characters and actions
//

import Foundation
import AVFoundation
import Combine

/// Audio service for managing sound effects throughout the app
class AudioService: ObservableObject {

    // MARK: - Sound Effect Types

    enum SoundEffect: String, CaseIterable {
        // Character actions
        case characterSpawn = "character_spawn"
        case characterWave = "character_wave"
        case characterDance = "character_dance"
        case characterTwirl = "character_twirl"
        case characterJump = "character_jump"

        // Magic effects
        case sparkles = "effect_sparkles"
        case snow = "effect_snow"
        case bubbles = "effect_bubbles"

        // Face tracking
        case faceTracking = "face_detected"

        // UI sounds
        case buttonTap = "button_tap"
        case sharePlayConnected = "shareplay_connected"
        case sharePlayDisconnected = "shareplay_disconnected"

        var filename: String {
            return "\(self.rawValue).wav"
        }
    }

    // MARK: - Published Properties

    @Published var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                stopAllSounds()
            }
        }
    }

    @Published var volume: Float = 0.8 {
        didSet {
            updateVolume()
        }
    }

    @Published var isSpatialAudioEnabled: Bool = true

    // MARK: - Private Properties

    private var audioEngine: AVAudioEngine
    private var playerNodes: [SoundEffect: AVAudioPlayerNode] = [:]
    private var audioBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var mixerNode: AVAudioMixerNode
    private var isEngineConfigured = false

    // Sound playback tracking
    private var activePlayers: Set<AVAudioPlayerNode> = []

    // MARK: - Initialization

    init() {
        self.audioEngine = AVAudioEngine()
        self.mixerNode = audioEngine.mainMixerNode

        setupAudioSession()
        configureAudioEngine()
        preloadSounds()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try audioSession.setActive(true)
        } catch {
            print("AudioService: Failed to setup audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Audio Engine Configuration

    private func configureAudioEngine() {
        // Configure mixer node
        mixerNode.volume = volume

        // Start the engine
        do {
            try audioEngine.start()
            isEngineConfigured = true
        } catch {
            print("AudioService: Failed to start audio engine: \(error.localizedDescription)")
            isEngineConfigured = false
        }
    }

    // MARK: - Sound Preloading

    func preloadSounds() {
        // In a real app, this would load actual audio files from the bundle
        // For now, we create placeholder buffers to prevent crashes
        for effect in SoundEffect.allCases {
            preloadSound(effect)
        }
    }

    private func preloadSound(_ effect: SoundEffect) {
        // Try to load the audio file from bundle
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") else {
            print("AudioService: Sound file not found for \(effect.rawValue). Creating silent buffer.")
            createSilentBuffer(for: effect)
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

        } catch {
            print("AudioService: Failed to load \(effect.rawValue): \(error.localizedDescription)")
            createSilentBuffer(for: effect)
        }
    }

    private func createSilentBuffer(for effect: SoundEffect) {
        // Create a short silent buffer as placeholder
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100,
            channels: 2
        )!
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: 4410 // 0.1 seconds
        ) else { return }

        buffer.frameLength = 4410
        audioBuffers[effect] = buffer
    }

    // MARK: - Sound Playback

    func playSound(_ effect: SoundEffect, at position: SIMD3<Float>? = nil) {
        guard isEnabled, isEngineConfigured else { return }

        // Create a new player node for this sound
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        // Connect to mixer
        if let position = position, isSpatialAudioEnabled {
            // Use AVAudio3DMixerNode for spatial audio
            let spatialMixerNode = AVAudioEnvironmentNode()
            audioEngine.attach(spatialMixerNode)

            if let buffer = audioBuffers[effect] {
                audioEngine.connect(playerNode, to: spatialMixerNode, format: buffer.format)
                audioEngine.connect(spatialMixerNode, to: mixerNode, format: buffer.format)

                // Set 3D position
                spatialMixerNode.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
                playerNode.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
            }
        } else {
            // Standard stereo playback
            if let buffer = audioBuffers[effect] {
                audioEngine.connect(playerNode, to: mixerNode, format: buffer.format)
            }
        }

        // Play the sound
        guard let buffer = audioBuffers[effect] else {
            print("AudioService: No buffer available for \(effect.rawValue)")
            return
        }

        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.cleanupPlayer(playerNode)
            }
        })

        playerNode.volume = volume
        playerNode.play()
        activePlayers.insert(playerNode)
    }

    private func cleanupPlayer(_ player: AVAudioPlayerNode) {
        player.stop()
        audioEngine.detach(player)
        activePlayers.remove(player)
    }

    // MARK: - Volume Control

    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume)) // Clamp between 0 and 1
    }

    private func updateVolume() {
        mixerNode.volume = volume
        activePlayers.forEach { $0.volume = volume }
    }

    // MARK: - Sound Toggle

    func toggleSound() {
        isEnabled.toggle()
    }

    func enableSound() {
        isEnabled = true
    }

    func disableSound() {
        isEnabled = false
    }

    // MARK: - Spatial Audio

    func toggleSpatialAudio() {
        isSpatialAudioEnabled.toggle()
    }

    // MARK: - Stop Sounds

    func stopAllSounds() {
        activePlayers.forEach { player in
            player.stop()
            audioEngine.detach(player)
        }
        activePlayers.removeAll()
    }

    func stopSound(_ effect: SoundEffect) {
        // Note: This stops all instances of this sound effect
        // In a more advanced implementation, we could track individual instances
        activePlayers.forEach { player in
            player.stop()
        }
    }

    // MARK: - Convenience Methods

    func playCharacterAction(_ action: CharacterAction, at position: SIMD3<Float>? = nil) {
        let effect: SoundEffect
        switch action {
        case .wave:
            effect = .characterWave
        case .dance:
            effect = .characterDance
        case .twirl:
            effect = .characterTwirl
        case .jump:
            effect = .characterJump
        case .idle, .sparkle:
            return // No sound for idle or sparkle (sparkle uses effect sound)
        }
        playSound(effect, at: position)
    }

    func playMagicEffect(_ effectName: String, at position: SIMD3<Float>? = nil) {
        let effect: SoundEffect
        switch effectName.lowercased() {
        case "sparkles":
            effect = .sparkles
        case "snow":
            effect = .snow
        case "bubbles":
            effect = .bubbles
        default:
            return
        }
        playSound(effect, at: position)
    }

    // MARK: - Diagnostics

    func getAudioStats() -> AudioStats {
        return AudioStats(
            isEnabled: isEnabled,
            volume: volume,
            activeSounds: activePlayers.count,
            preloadedSounds: audioBuffers.count,
            isEngineRunning: audioEngine.isRunning,
            isSpatialAudioEnabled: isSpatialAudioEnabled
        )
    }

    // MARK: - Cleanup

    deinit {
        stopAllSounds()
        audioEngine.stop()
    }
}

// MARK: - Audio Stats

struct AudioStats {
    let isEnabled: Bool
    let volume: Float
    let activeSounds: Int
    let preloadedSounds: Int
    let isEngineRunning: Bool
    let isSpatialAudioEnabled: Bool

    var description: String {
        """
        Audio Service Stats:
        - Enabled: \(isEnabled)
        - Volume: \(Int(volume * 100))%
        - Active Sounds: \(activeSounds)
        - Preloaded: \(preloadedSounds)
        - Engine Running: \(isEngineRunning)
        - Spatial Audio: \(isSpatialAudioEnabled)
        """
    }
}
