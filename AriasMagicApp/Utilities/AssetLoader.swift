//
//  AssetLoader.swift
//  Aria's Magic SharePlay App
//
//  Asset loading and caching system for 3D models and resources
//

import Foundation
import RealityKit
import Combine

/// Errors that can occur during asset loading
enum AssetLoadError: Error {
    case fileNotFound(String)
    case invalidFormat(String)
    case loadingFailed(String)
    case insufficientMemory
}

/// Asset loader with caching for efficient 3D model and resource management
class AssetLoader {
    /// Shared singleton instance
    static let shared = AssetLoader()

    // MARK: - Properties

    /// Cache for loaded character entities
    private var characterCache: [CharacterType: Entity] = [:]

    /// Cache for particle textures
    private var textureCache: [String: TextureResource] = [:]

    /// Loading state tracking
    private var isPreloading = false
    private var preloadCompletion: ((Bool) -> Void)?

    /// Memory management
    private let maxCacheSize: Int = 100 * 1024 * 1024 // 100 MB
    private var currentCacheSize: Int = 0

    /// Cancellables for async operations
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        setupMemoryWarningObserver()
    }

    // MARK: - Character Loading

    /// Preload all character models at app launch
    /// - Parameter completion: Callback with success status
    func preloadCharacters(completion: @escaping (Bool) -> Void) {
        guard !isPreloading else {
            print("⚠️ AssetLoader: Preloading already in progress")
            return
        }

        isPreloading = true
        preloadCompletion = completion

        print("🔄 AssetLoader: Starting character preload...")

        Task {
            var loadedCount = 0
            var failedCount = 0

            for characterType in CharacterType.allCases {
                do {
                    let entity = try await loadCharacterModel(type: characterType)
                    await MainActor.run {
                        characterCache[characterType] = entity
                        loadedCount += 1
                        print("✅ AssetLoader: Loaded \(characterType.rawValue)")
                    }
                } catch {
                    failedCount += 1
                    print("❌ AssetLoader: Failed to load \(characterType.rawValue): \(error)")
                }
            }

            await MainActor.run {
                isPreloading = false
                let success = failedCount == 0
                print("🎯 AssetLoader: Preload complete - \(loadedCount) loaded, \(failedCount) failed")
                preloadCompletion?(success)
                preloadCompletion = nil
            }
        }
    }

    /// Load a specific character (from cache if available)
    /// - Parameter type: The character type to load
    /// - Returns: The loaded entity, or nil if loading fails
    func loadCharacter(type: CharacterType) async -> Entity? {
        // Check cache first
        if let cachedEntity = characterCache[type] {
            print("📦 AssetLoader: Using cached \(type.rawValue)")
            return cachedEntity.clone(recursive: true)
        }

        // Load from disk
        do {
            let entity = try await loadCharacterModel(type: type)
            await MainActor.run {
                characterCache[type] = entity
            }
            print("✅ AssetLoader: Loaded \(type.rawValue) from disk")
            return entity.clone(recursive: true)
        } catch {
            print("❌ AssetLoader: Failed to load \(type.rawValue): \(error)")
            return nil
        }
    }

    /// Load character model from bundle
    private func loadCharacterModel(type: CharacterType) async throws -> Entity {
        let fileName = fileNameForCharacter(type)

        // Check if USDZ file exists in bundle
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "usdz", subdirectory: "Resources/Characters") else {
            // Fall back to placeholder for development
            print("⚠️ AssetLoader: USDZ not found for \(type.rawValue), using placeholder")
            return createPlaceholderEntity(for: type)
        }

        // Load the USDZ model
        do {
            let entity = try await Entity(contentsOf: fileURL)
            return entity
        } catch {
            print("⚠️ AssetLoader: USDZ load failed for \(type.rawValue), using placeholder")
            return createPlaceholderEntity(for: type)
        }
    }

    /// Create placeholder entity for development/testing
    private func createPlaceholderEntity(for type: CharacterType) -> Entity {
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: colorForCharacterType(type), isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])

        // Add collision for interaction
        modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])

        return modelEntity
    }

    /// Get filename for character type
    private func fileNameForCharacter(_ type: CharacterType) -> String {
        switch type {
        case .sparkleThePrincess:
            return "Sparkle"
        case .lunaTheStarDancer:
            return "Luna"
        case .rosieTheDreamWeaver:
            return "Rosie"
        case .crystalTheGemKeeper:
            return "Crystal"
        case .willowTheWishMaker:
            return "Willow"
        }
    }

    /// Get color for character type (for placeholders)
    private func colorForCharacterType(_ type: CharacterType) -> UIColor {
        switch type {
        case .sparkleThePrincess:
            return .systemPink
        case .lunaTheStarDancer:
            return .systemPurple
        case .rosieTheDreamWeaver:
            return .systemRed
        case .crystalTheGemKeeper:
            return .systemCyan
        case .willowTheWishMaker:
            return .systemGreen
        }
    }

    // MARK: - Texture Loading

    /// Load particle textures
    func loadParticleTextures() async {
        let textureNames = ["sparkle_texture", "snow_texture", "bubble_texture"]

        for textureName in textureNames {
            do {
                if let texture = try? await TextureResource(named: textureName) {
                    await MainActor.run {
                        textureCache[textureName] = texture
                    }
                    print("✅ AssetLoader: Loaded texture \(textureName)")
                } else {
                    print("⚠️ AssetLoader: Texture not found: \(textureName)")
                }
            }
        }
    }

    /// Get a cached particle texture
    /// - Parameter name: Texture name
    /// - Returns: The texture resource if available
    func getTexture(named name: String) -> TextureResource? {
        return textureCache[name]
    }

    // MARK: - Memory Management

    /// Clear all cached assets
    func clearCache() {
        characterCache.removeAll()
        textureCache.removeAll()
        currentCacheSize = 0
        print("🗑️ AssetLoader: Cache cleared")
    }

    /// Estimate current cache size in bytes
    /// - Returns: Estimated size in bytes
    func estimateCacheSize() -> Int {
        // Rough estimation: each character ~5MB, each texture ~50KB
        let characterSize = characterCache.count * 5 * 1024 * 1024
        let textureSize = textureCache.count * 50 * 1024
        return characterSize + textureSize
    }

    /// Setup memory warning observer
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("⚠️ AssetLoader: Memory warning received, clearing cache")
            self?.clearCache()
        }
    }

    // MARK: - Cache Status

    /// Check if a character is cached
    /// - Parameter type: Character type to check
    /// - Returns: True if character is in cache
    func isCharacterCached(_ type: CharacterType) -> Bool {
        return characterCache[type] != nil
    }

    /// Get cache statistics
    /// - Returns: Dictionary with cache stats
    func getCacheStats() -> [String: Any] {
        return [
            "charactersCached": characterCache.count,
            "texturesCached": textureCache.count,
            "estimatedSize": estimateCacheSize(),
            "estimatedSizeMB": Double(estimateCacheSize()) / (1024.0 * 1024.0)
        ]
    }

    /// Print cache status to console
    func printCacheStatus() {
        let stats = getCacheStats()
        print("📊 AssetLoader Cache Status:")
        print("   Characters: \(stats["charactersCached"] ?? 0)")
        print("   Textures: \(stats["texturesCached"] ?? 0)")
        print("   Size: \(String(format: "%.2f", stats["estimatedSizeMB"] as? Double ?? 0)) MB")
    }
}

// MARK: - Asset Loading Extensions

extension AssetLoader {
    /// Preload specific characters (useful for on-demand loading)
    /// - Parameter types: Array of character types to preload
    func preloadSpecificCharacters(_ types: [CharacterType]) async {
        for type in types {
            _ = await loadCharacter(type: type)
        }
    }

    /// Validate all asset files exist in bundle
    /// - Returns: Dictionary of missing assets
    func validateAssets() -> [String: [String]] {
        var missingAssets: [String: [String]] = [:]
        var missingCharacters: [String] = []
        var missingTextures: [String] = []

        // Check characters
        for type in CharacterType.allCases {
            let fileName = fileNameForCharacter(type)
            if Bundle.main.url(forResource: fileName, withExtension: "usdz", subdirectory: "Resources/Characters") == nil {
                missingCharacters.append(fileName + ".usdz")
            }
        }

        // Check textures
        let textureNames = ["sparkle_texture", "snow_texture", "bubble_texture"]
        for textureName in textureNames {
            if Bundle.main.url(forResource: textureName, withExtension: "png", subdirectory: "Resources/Particles") == nil {
                missingTextures.append(textureName + ".png")
            }
        }

        if !missingCharacters.isEmpty {
            missingAssets["characters"] = missingCharacters
        }
        if !missingTextures.isEmpty {
            missingAssets["textures"] = missingTextures
        }

        return missingAssets
    }
}
