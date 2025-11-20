import Foundation
import AVFoundation

@MainActor
public class AudioAssetLoader {
    public static let shared = AudioAssetLoader()
    
    private var cache: [AudioCatalog: URL] = [:]
    
    private init() {}
    
    public func loadAudio(for type: AudioCatalog) async throws -> URL {
        if let cached = cache[type] {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: type.fileName, withExtension: type.fileExtension) else {
            // For Phase 1, we might not have files yet, so we can suppress error or log it
            // But `throws` is better.
            throw AssetError.fileNotFound("\(type.fileName).\(type.fileExtension)")
        }
        
        cache[type] = url
        return url
    }
    
    public func preloadAll() async {
        for type in AudioCatalog.allCases {
            try? await loadAudio(for: type)
        }
    }
}

