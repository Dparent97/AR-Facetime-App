import Foundation
import AVFoundation
import Combine

@MainActor
public class AudioService: ObservableObject {
    public static let shared = AudioService()

    @Published public var isEnabled: Bool = true
    @Published public var volume: Float = 1.0 {
        didSet {
            mixerNode.volume = volume
        }
    }

    private let audioEngine = AVAudioEngine()
    private let mixerNode = AVAudioMixerNode()
    private var audioPlayers: [AudioCatalog: AVAudioPlayerNode] = [:]
    private var audioBuffers: [AudioCatalog: AVAudioPCMBuffer] = [:]
    
    private init() {
        setupAudioEngine()
        Task {
            await preloadSounds()
        }
    }

    private func setupAudioEngine() {
        audioEngine.attach(mixerNode)
        audioEngine.connect(mixerNode, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
        } catch {
            print("Audio engine setup failed: \(error)")
        }
    }
    
    public func preloadSounds() async {
        for type in AudioCatalog.allCases {
            if let url = try? await AudioAssetLoader.shared.loadAudio(for: type) {
                if let buffer = loadBuffer(from: url) {
                    audioBuffers[type] = buffer
                    
                    let player = AVAudioPlayerNode()
                    audioEngine.attach(player)
                    audioEngine.connect(player, to: mixerNode, format: buffer.format)
                    audioPlayers[type] = player
                }
            } else {
                // Create silent buffer as fallback
                if let buffer = createSilentBuffer() {
                    audioBuffers[type] = buffer
                    let player = AVAudioPlayerNode()
                    audioEngine.attach(player)
                    audioEngine.connect(player, to: mixerNode, format: buffer.format)
                    audioPlayers[type] = player
                }
            }
        }
    }
    
    private func loadBuffer(from url: URL) -> AVAudioPCMBuffer? {
        try? AVAudioPCMBuffer(url: url)
    }
    
    private func createSilentBuffer() -> AVAudioPCMBuffer? {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2) else { return nil }
        return AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4410) // 0.1s
    }
    
    public func play(_ type: AudioCatalog) {
        guard isEnabled, let player = audioPlayers[type], let buffer = audioBuffers[type] else { return }
        
        if player.isPlaying {
            player.stop()
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }
    
    public func playForAction(_ action: CharacterAction) {
        switch action {
        case .idle: break
        case .wave: play(.wave)
        case .dance: play(.dance)
        case .twirl: play(.twirl)
        case .jump: play(.jump)
        case .sparkle: play(.sparkle)
        }
    }
}

extension AVAudioPCMBuffer {
    convenience init?(url: URL) throws {
        let file = try AVAudioFile(forReading: url)
        self.init(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        try file.read(into: self)
    }
}
