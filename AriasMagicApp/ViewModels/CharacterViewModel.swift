//
//  CharacterViewModel.swift
//  Aria's Magic SharePlay App
//
//  Manages character state and actions
//

import Foundation
import Combine
import RealityKit

class CharacterViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var selectedCharacterType: CharacterType = .sparkleThePrincess
    @Published var activeEffect: MagicEffect?
    @Published var currentError: ErrorState?

    private var cancellables = Set<AnyCancellable>()
    private weak var sharePlayService: SharePlayService?

    init(sharePlayService: SharePlayService? = nil) {
        self.sharePlayService = sharePlayService
        sharePlayService?.delegate = self

        // Start with one default character
        spawnCharacter(at: [0, 0, -0.5])

        // Start audio monitoring for clap detection
        setupAudioMonitoring()
    }

    private func setupAudioMonitoring() {
        AudioService.shared.loudNoiseDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleLoudNoise()
            }
            .store(in: &cancellables)
            
        // Start the microphone
        AudioService.shared.startMicrophoneMonitoring()
    }
    
    private func handleLoudNoise() {
        // Trigger jump action on all characters
        performAction(.jump)
        print("👏 Clap detected! Jumping!")
    }

    func handleError(_ error: AppError) {
        DispatchQueue.main.async {
            self.currentError = ErrorState(error: error)
            ErrorLoggingService.shared.logError(error)
        }
    }

    func dismissError() {
        currentError = nil
    }

    /// Set the SharePlay service for synchronization
    func setSharePlayService(_ service: SharePlayService) {
        self.sharePlayService = service
        service.delegate = self
    }

    func spawnCharacter(at position: SIMD3<Float>) {
        let character = Character(type: selectedCharacterType, position: position)
        characters.append(character)

        // Sync to SharePlay
        sharePlayService?.sendCharacterSpawned(character)
    }

    func removeCharacter(_ character: Character) {
        let characterID = character.id
        
        // Cancel all pending animations before removing to prevent memory leaks
        character.cancelAllAnimations()
        
        characters.removeAll { $0.id == characterID }
        character.cleanup()

        // Sync to SharePlay
        sharePlayService?.sendCharacterRemoved(id: characterID)
    }

    func performAction(_ action: CharacterAction, on character: Character? = nil) {
        if let character = character {
            character.performAction(action)
            sharePlayService?.sendCharacterAction(action, characterID: character.id)
        } else {
            // Perform action on all characters
            characters.forEach {
                $0.performAction(action)
                sharePlayService?.sendCharacterAction(action, characterID: $0.id)
            }
        }
    }

    func triggerEffect(_ effect: MagicEffect) {
        activeEffect = effect

        // Sync to SharePlay
        sharePlayService?.sendEffectTriggered(effect)

        // Auto-dismiss effect after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            if self.activeEffect == effect {
                self.activeEffect = nil
            }
        }
    }

    /// Update character position (called by UI gestures)
    func updateCharacterPosition(_ character: Character, to position: SIMD3<Float>) {
        character.setPosition(position, animated: true)

        // Sync to SharePlay with throttling
        sharePlayService?.sendCharacterUpdated(character)
    }

    /// Update character scale (called by UI gestures)
    func updateCharacterScale(_ character: Character, to scale: Float) {
        character.setScale(scale, animated: true)

        // Sync to SharePlay with throttling
        sharePlayService?.sendCharacterUpdated(character)
    }

    func handleFaceExpression(_ expression: FaceExpression) {
        switch expression {
        case .smile:
            triggerEffect(.sparkles)
        case .eyebrowsRaised:
            performAction(.wave)
        case .mouthOpen:
            performAction(.jump)
        }
    }
}

// MARK: - SharePlay Sync Delegate

extension CharacterViewModel: SharePlaySyncDelegate {
    func sharePlayDidSpawnCharacter(_ state: CharacterSyncState) {
        // Check if character already exists
        guard !characters.contains(where: { $0.id == state.id }) else { return }

        // Create character from sync state
        let character = Character(
            id: state.id,
            type: state.type,
            position: state.position,
            scale: state.scale
        )
        characters.append(character)

        print("✅ SharePlay: Spawned character \(state.type.rawValue)")
    }

    func sharePlayDidUpdateCharacter(_ state: CharacterSyncState) {
        // Find and update existing character
        guard let character = characters.first(where: { $0.id == state.id }) else {
            // Character doesn't exist locally, spawn it
            sharePlayDidSpawnCharacter(state)
            return
        }

        // Update without animation for remote changes (smoother sync)
        character.setPosition(state.position, animated: false)
        character.setScale(state.scale, animated: false)
    }

    func sharePlayDidRemoveCharacter(id: UUID) {
        if let character = characters.first(where: { $0.id == id }) {
            characters.removeAll { $0.id == id }
            character.cleanup()
            print("✅ SharePlay: Removed character")
        }
    }

    func sharePlayDidTriggerAction(_ action: CharacterAction, characterID: UUID) {
        guard let character = characters.first(where: { $0.id == characterID }) else { return }
        character.performAction(action)
        print("✅ SharePlay: Triggered action \(action.rawValue)")
    }

    func sharePlayDidTriggerEffect(_ effect: String) {
        if let magicEffect = MagicEffect(rawValue: effect) {
            // Set effect without syncing back (prevent loop)
            activeEffect = magicEffect

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if self.activeEffect == magicEffect {
                    self.activeEffect = nil
                }
            }
            print("✅ SharePlay: Triggered effect \(effect)")
        }
    }
}
