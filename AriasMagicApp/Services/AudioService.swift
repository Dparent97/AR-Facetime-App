//
//  AudioService.swift
//  Aria's Magic SharePlay App
//
//  Audio service for managing sound effects and spatial audio
//

import Foundation
import AVFoundation
import Combine

/// Sound effects available in the app
enum SoundEffect: String, CaseIterable {
    // Character actions
    case characterSpawn = "character_spawn"
    case characterWave = "character_wave"
    case characterDance = "character_dance"
    case characterTwirl = "character_twirl"
    case characterJump = "character_jump"
    case characterRemove = "character_remove"

    // Magic effects
    case sparkles = "sparkles"
    case snow = "snow"
    case bubbles = "bubbles"

    // UI interactions
    case faceTracking = "face_tracking"
    case buttonTap = "button_tap"
    case sharePlayConnected = "shareplay_connected"

    /// Filename for the sound effect (without extension)
    var filename: String { rawValue }
}

/// Audio service for playing sound effects with volume control and spatial audio support
class AudioService: ObservableObject {
    static let shared = AudioService()

    // MARK: - Published Properties

    /// Whether sound effects are enabled
    @Published var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                stopAllSounds()
            }
        }
    }

    /// Master volume for all sound effects (0.0 to 1.0)
    @Published var volume: Float = 0.8 {
        didSet {
            updateVolume()
        }
    }

    /// Published subject for loud noise detection (e.g. claps)
    let loudNoiseDetected = PassthroughSubject<Void, Never>()

    // MARK: - Private Properties

    /// Audio engine for low-latency playback
    private let audioEngine = AVAudioEngine()

    /// Audio players for each sound effect
    private var audioPlayers: [SoundEffect: AVAudioPlayerNode] = [:]

    /// Audio buffers (preloaded for fast playback)
    private var audioBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]

    /// Mixer node for volume control
    private let mixerNode = AVAudioMixerNode()

    /// Is the audio engine running
    private var isEngineRunning = false

    /// Queue for audio operations
    private let audioQueue = DispatchQueue(label: "com.ariasmagic.audio", qos: .userInitiated)

    // MARK: - Initialization

    init() {
        setupAudioEngine()
        preloadSounds()
    }

    // MARK: - Audio Engine Setup

    private func setupAudioEngine() {
        // Attach mixer node
        audioEngine.attach(mixerNode)

        // Connect mixer to output
        audioEngine.connect(
            mixerNode,
            to: audioEngine.mainMixerNode,
            format: nil
        )

        // Set initial volume
        mixerNode.outputVolume = volume

        // Configure audio session
        configureAudioSession()

        // Start engine
        startEngine()
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Configure for ambient playback (mix with other audio)
            try audioSession.setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )

            try audioSession.setActive(true)
        } catch {
            print("⚠️ AudioService: Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func startEngine() {
        guard !isEngineRunning else { return }

        do {
            try audioEngine.start()
            isEngineRunning = true
        } catch {
            print("⚠️ AudioService: Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    // MARK: - Microphone Monitoring (Clap Detection)

    /// Start monitoring microphone for loud noises (claps)
    func startMicrophoneMonitoring() {
        guard isEngineRunning else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, time) in
            self?.analyzeAudioBuffer(buffer)
        }

        print("🎤 AudioService: Microphone monitoring started")
    }

    /// Stop monitoring microphone
    func stopMicrophoneMonitoring() {
        audioEngine.inputNode.removeTap(onBus: 0)
        print("🎤 AudioService: Microphone monitoring stopped")
    }

    private func analyzeAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }

        // Calculate RMS (Root Mean Square) amplitude
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))

        // Threshold for clap detection (adjustable)
        let clapThreshold: Float = 0.5

        if rms > clapThreshold {
            // Debounce slightly
            DispatchQueue.main.async { [weak self] in
                self?.loudNoiseDetected.send()
            }
        }
    }

    // MARK: - Sound Preloading

    /// Preload all sound effects for immediate playback
    func preloadSounds() {
        audioQueue.async { [weak self] in
            guard let self = self else { return }

            for effect in SoundEffect.allCases {
                self.preloadSound(effect)
            }

            print("✅ AudioService: Preloaded \(SoundEffect.allCases.count) sound effects")
        }
    }

    private func preloadSound(_ effect: SoundEffect) {
        // For prototype: Create silent placeholder buffers
        // In production, the 3D Engineer will provide actual sound files

        guard let buffer = createPlaceholderBuffer() else {
            print("⚠️ AudioService: Failed to create buffer for \(effect.rawValue)")
            return
        }

        audioBuffers[effect] = buffer

        // Create player node for this effect
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixerNode, format: buffer.format)

        audioPlayers[effect] = playerNode
    }

    /// Create a placeholder silent buffer for prototype
    /// TODO: Replace with actual sound file loading when assets are available
    private func createPlaceholderBuffer() -> AVAudioPCMBuffer? {
        // Create a short silent buffer as placeholder
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100,
            channels: 2
        )

        guard let format = format else { return nil }

        // 0.1 second buffer
        let frameCount = AVAudioFrameCount(format.sampleRate * 0.1)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else {
            return nil
        }

        buffer.frameLength = frameCount

        return buffer
    }

    /// Load sound from file (for production use)
    private func loadSoundFile(_ effect: SoundEffect) -> AVAudioPCMBuffer? {
        // Get file URL (m4a or wav)
        guard let fileURL = Bundle.main.url(
            forResource: effect.filename,
            withExtension: "m4a"
        ) else {
            // Try wav format
            guard let fileURL = Bundle.main.url(
                forResource: effect.filename,
                withExtension: "wav"
            ) else {
                print("⚠️ AudioService: Sound file not found: \(effect.filename)")
                return nil
            }

            return loadAudioFile(fileURL)
        }

        return loadAudioFile(fileURL)
    }

    private func loadAudioFile(_ url: URL) -> AVAudioPCMBuffer? {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat

            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                return nil
            }

            try audioFile.read(into: buffer)
            buffer.frameLength = AVAudioFrameCount(audioFile.length)

            return buffer
        } catch {
            print("⚠️ AudioService: Failed to load audio file: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Playback

    /// Play a sound effect
    ///
    /// - Parameters:
    ///   - effect: The sound effect to play
    ///   - volume: Optional volume override (0.0 to 1.0)
    func playSound(_ effect: SoundEffect, volume: Float? = nil) {
        guard isEnabled else { return }

        audioQueue.async { [weak self] in
            guard let self = self else { return }
            guard let playerNode = self.audioPlayers[effect] else { return }
            guard let buffer = self.audioBuffers[effect] else { return }

            // Stop if already playing
            playerNode.stop()

            // Set volume
            let effectiveVolume = volume ?? self.volume
            playerNode.volume = effectiveVolume

            // Schedule buffer
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)

            // Start playback if not already playing
            if !playerNode.isPlaying {
                playerNode.play()
            }
        }
    }

    /// Play sound with spatial audio positioning
    ///
    /// - Parameters:
    ///   - effect: The sound effect to play
    ///   - position: 3D position for spatial audio
    func playSoundAt(_ effect: SoundEffect, position: SIMD3<Float>) {
        // For now, just play normally
        // TODO: Implement spatial audio with AVAudio3DMixing when 3D models are ready
        playSound(effect)
    }

    // MARK: - Volume Control

    /// Set the master volume
    ///
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
    }

    private func updateVolume() {
        mixerNode.outputVolume = volume
    }

    /// Toggle sound on/off
    func toggleSound() {
        isEnabled.toggle()
    }

    // MARK: - Cleanup

    /// Stop all currently playing sounds
    func stopAllSounds() {
        audioQueue.async { [weak self] in
            guard let self = self else { return }

            for (_, player) in self.audioPlayers {
                player.stop()
            }
        }
    }

    deinit {
        stopAllSounds()
        audioEngine.stop()
    }
}

// MARK: - Integration Helpers

extension AudioService {
    /// Play sound for character action
    func playCharacterAction(_ action: CharacterAction) {
        let effect: SoundEffect
        switch action {
        case .idle:
            return // No sound for idle
        case .wave:
            effect = .characterWave
        case .dance:
            effect = .characterDance
        case .twirl:
            effect = .characterTwirl
        case .jump:
            effect = .characterJump
        case .sparkle:
            effect = .sparkles
        }

        playSound(effect)
    }

    /// Play sound for magic effect
    func playMagicEffect(_ effect: MagicEffect) {
        let soundEffect: SoundEffect
        switch effect {
        case .sparkles:
            soundEffect = .sparkles
        case .snow:
            soundEffect = .snow
        case .bubbles:
            soundEffect = .bubbles
        }

        playSound(soundEffect)
    }

    /// Play character spawn sound
    func playCharacterSpawn() {
        playSound(.characterSpawn)
    }

    /// Play character remove sound
    func playCharacterRemove() {
        playSound(.characterRemove)
    }

    /// Play face tracking trigger sound
    func playFaceTracking() {
        playSound(.faceTracking, volume: volume * 0.6) // Quieter for face tracking
    }

    /// Play button tap sound
    func playButtonTap() {
        playSound(.buttonTap, volume: volume * 0.4) // Very quiet for UI
    }

    /// Play SharePlay connected sound
    func playSharePlayConnected() {
        playSound(.sharePlayConnected)
    }
}
