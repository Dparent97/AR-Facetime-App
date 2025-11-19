//
//  AssetLoader.swift
//  Aria's Magic SharePlay App
//
//  Asset loading and caching system for 3D models, textures, and sounds
//

import Foundation
import RealityKit
import UIKit
import AVFoundation

/// Manages loading and caching of 3D character models, particle textures, and sound effects
class AssetLoader {

    // MARK: - Singleton

    static let shared = AssetLoader()

    // MARK: - Cache Storage

    /// In-memory cache for loaded character entities
    private var characterCache: [CharacterType: Entity] = [:]

    /// Cache for particle textures
    private var textureCache: [String: TextureResource] = [:]

    /// Cache for sound effects
    private var soundCache: [String: AVAudioPlayer] = [:]

    /// Lock for thread-safe cache access
    private let cacheLock = NSLock()

    // MARK: - Configuration

    private let characterDirectory = "Characters"
    private let particleDirectory = "Particles"
    private let soundDirectory = "Sounds"

    // MARK: - Initialization

    private init() {
        // Private initializer for singleton
        setupNotificationObservers()
    }

    // MARK: - Memory Management

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        clearCache()
        print("AssetLoader: Cache cleared due to memory warning")
    }

    /// Clear all cached assets
    func clearCache() {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        characterCache.removeAll()
        textureCache.removeAll()
        soundCache.removeAll()
    }

    /// Estimate total cache size in bytes (approximate)
    func estimateCacheSize() -> Int {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        // Rough estimation:
        // - Each character entity: ~2-5 MB
        // - Each texture: ~100-500 KB
        // - Each sound: ~50-200 KB

        let characterSize = characterCache.count * 3_500_000 // 3.5 MB average
        let textureSize = textureCache.count * 300_000 // 300 KB average
        let soundSize = soundCache.count * 125_000 // 125 KB average

        return characterSize + textureSize + soundSize
    }

    // MARK: - Character Loading

    /// Preload all character models at app launch
    /// - Parameter completion: Callback with success status
    func preloadCharacters(completion: @escaping (Bool) -> Void) {
        Task {
            var loadedSuccessfully = 0

            for characterType in CharacterType.allCases {
                if let _ = await loadCharacter(type: characterType) {
                    loadedSuccessfully += 1
                }
            }

            let allLoaded = loadedSuccessfully == CharacterType.allCases.count

            await MainActor.run {
                completion(allLoaded)
                if allLoaded {
                    print("AssetLoader: All \(loadedSuccessfully) characters preloaded successfully")
                } else {
                    print("AssetLoader: Loaded \(loadedSuccessfully)/\(CharacterType.allCases.count) characters")
                }
            }
        }
    }

    /// Load a specific character model (from cache if available)
    /// - Parameter type: The character type to load
    /// - Returns: Entity with the character model, or nil if loading fails
    func loadCharacter(type: CharacterType) async -> Entity? {
        // Check cache first
        cacheLock.lock()
        if let cachedEntity = characterCache[type] {
            cacheLock.unlock()
            print("AssetLoader: Loaded \(type.rawValue) from cache")
            return cachedEntity.clone(recursive: true)
        }
        cacheLock.unlock()

        // Try to load USDZ file
        let filename = filenameForCharacterType(type)

        if let entity = await loadUSDZFile(named: filename) {
            // Cache the entity
            cacheLock.lock()
            characterCache[type] = entity
            cacheLock.unlock()

            print("AssetLoader: Loaded \(type.rawValue) from file: \(filename)")
            return entity.clone(recursive: true)
        } else {
            // Fallback to placeholder if USDZ not found
            print("AssetLoader: USDZ not found for \(type.rawValue), using placeholder")
            let placeholder = createPlaceholderCharacter(for: type)

            // Cache placeholder too
            cacheLock.lock()
            characterCache[type] = placeholder
            cacheLock.unlock()

            return placeholder.clone(recursive: true)
        }
    }

    /// Load USDZ file from Resources/Characters/
    private func loadUSDZFile(named filename: String) async -> Entity? {
        // Check if file exists in bundle
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "usdz",
            subdirectory: "Resources/\(characterDirectory)"
        ) else {
            return nil
        }

        do {
            let entity = try await Entity.load(contentsOf: url)
            return entity
        } catch {
            print("AssetLoader: Error loading USDZ \(filename): \(error.localizedDescription)")
            return nil
        }
    }

    /// Create a placeholder character entity (colored cube)
    private func createPlaceholderCharacter(for type: CharacterType) -> Entity {
        let mesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: colorForCharacterType(type), isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Add collision for interaction
        entity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
        entity.name = type.rawValue

        return entity
    }

    /// Get the filename for a character type
    private func filenameForCharacterType(_ type: CharacterType) -> String {
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

    // MARK: - Particle Texture Loading

    /// Load particle textures (sparkle, snow, bubble)
    func loadParticleTextures() async {
        let textureNames = ["sparkle_texture", "snow_texture", "bubble_texture"]

        for textureName in textureNames {
            if let texture = await loadTexture(named: textureName) {
                cacheLock.lock()
                textureCache[textureName] = texture
                cacheLock.unlock()
                print("AssetLoader: Loaded texture: \(textureName)")
            } else {
                print("AssetLoader: Could not load texture: \(textureName)")
            }
        }
    }

    /// Load a specific texture from Resources/Particles/
    private func loadTexture(named name: String) async -> TextureResource? {
        // Check cache first
        cacheLock.lock()
        if let cachedTexture = textureCache[name] {
            cacheLock.unlock()
            return cachedTexture
        }
        cacheLock.unlock()

        // Try to load from bundle
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "png",
            subdirectory: "Resources/\(particleDirectory)"
        ) else {
            return nil
        }

        do {
            let texture = try await TextureResource.load(contentsOf: url)
            return texture
        } catch {
            print("AssetLoader: Error loading texture \(name): \(error.localizedDescription)")
            return nil
        }
    }

    /// Get a loaded particle texture
    func getParticleTexture(named name: String) -> TextureResource? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return textureCache[name]
    }

    // MARK: - Sound Loading

    /// Preload all sound effects
    func preloadSounds(completion: @escaping (Bool) -> Void) {
        let soundFiles = [
            "character_spawn",
            "character_wave",
            "character_dance",
            "character_twirl",
            "character_jump",
            "character_sparkle",
            "effect_sparkles",
            "effect_snow",
            "effect_bubbles",
            "face_smile",
            "face_eyebrows",
            "face_mouth"
        ]

        var loadedCount = 0

        for soundName in soundFiles {
            if loadSound(named: soundName) != nil {
                loadedCount += 1
            }
        }

        let success = loadedCount > 0
        print("AssetLoader: Loaded \(loadedCount)/\(soundFiles.count) sound effects")
        completion(success)
    }

    /// Load a sound file from Resources/Sounds/
    private func loadSound(named name: String) -> AVAudioPlayer? {
        // Check cache first
        cacheLock.lock()
        if let cachedSound = soundCache[name] {
            cacheLock.unlock()
            return cachedSound
        }
        cacheLock.unlock()

        // Try to load from bundle
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "m4a",
            subdirectory: "Resources/\(soundDirectory)"
        ) else {
            // Try .wav extension
            guard let wavUrl = Bundle.main.url(
                forResource: name,
                withExtension: "wav",
                subdirectory: "Resources/\(soundDirectory)"
            ) else {
                return nil
            }
            return createAudioPlayer(from: wavUrl, named: name)
        }

        return createAudioPlayer(from: url, named: name)
    }

    private func createAudioPlayer(from url: URL, named name: String) -> AVAudioPlayer? {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()

            cacheLock.lock()
            soundCache[name] = player
            cacheLock.unlock()

            return player
        } catch {
            print("AssetLoader: Error loading sound \(name): \(error.localizedDescription)")
            return nil
        }
    }

    /// Get a loaded sound effect
    func getSound(named name: String) -> AVAudioPlayer? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return soundCache[name]
    }
}

// MARK: - Asset Loading Extensions

extension AssetLoader {

    /// Load a preview image for a character
    func loadCharacterPreview(for type: CharacterType) -> UIImage? {
        let filename = filenameForCharacterType(type) + "_preview"

        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "png",
            subdirectory: "Resources/Previews"
        ) else {
            // Return placeholder image with character color
            return createPlaceholderPreview(for: type)
        }

        return UIImage(contentsOfFile: url.path)
    }

    /// Create a placeholder preview image
    private func createPlaceholderPreview(for type: CharacterType) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let color = colorForCharacterType(type)
            color.setFill()

            let circlePath = UIBezierPath(
                ovalIn: CGRect(x: 64, y: 64, width: 384, height: 384)
            )
            circlePath.fill()
        }
    }
}
