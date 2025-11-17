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

    weak var sharePlayService: SharePlayService?

    private var cancellables = Set<AnyCancellable>()
    private var isReceivingRemoteUpdate = false  // Flag to prevent sync loops

    init() {
        // Start with one default character
        spawnCharacter(at: [0, 0, -0.5])
    }

    func configure(with sharePlayService: SharePlayService) {
        self.sharePlayService = sharePlayService
        sharePlayService.delegate = self
    }

    func spawnCharacter(at position: SIMD3<Float>) {
        let character = Character(type: selectedCharacterType, position: position)
        characters.append(character)

        // Send sync message if SharePlay is active and not receiving remote update
        if !isReceivingRemoteUpdate {
            sharePlayService?.sendCharacterSpawn(id: character.id, type: character.type, position: position)
        }
    }

    func removeCharacter(_ character: Character) {
        characters.removeAll { $0.id == character.id }
    }

    func performAction(_ action: CharacterAction, on character: Character? = nil) {
        if let character = character {
            character.performAction(action)
        } else {
            // Perform action on all characters
            characters.forEach { $0.performAction(action) }
        }

        // Send sync message if SharePlay is active and not receiving remote update
        if !isReceivingRemoteUpdate {
            sharePlayService?.sendCharacterAction(action, for: character?.id)
        }
    }

    func triggerEffect(_ effect: MagicEffect) {
        activeEffect = effect

        // Send sync message if SharePlay is active and not receiving remote update
        if !isReceivingRemoteUpdate {
            sharePlayService?.sendEffect(effect)
        }

        // Auto-dismiss effect after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if self.activeEffect == effect {
                self.activeEffect = nil
            }
        }
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

    // Helper method to spawn character from remote (with specific ID)
    private func spawnCharacterFromRemote(id: UUID, type: CharacterType, position: SIMD3<Float>) {
        // Check if character with this ID already exists (conflict resolution)
        if characters.contains(where: { $0.id == id }) {
            print("Character with ID \(id) already exists, ignoring remote spawn")
            return
        }

        isReceivingRemoteUpdate = true
        let character = Character(id: id, type: type, position: position)
        characters.append(character)
        isReceivingRemoteUpdate = false
    }

    // Helper method to perform action from remote
    private func performActionFromRemote(_ action: CharacterAction, characterID: UUID?) {
        isReceivingRemoteUpdate = true

        if let characterID = characterID {
            // Perform action on specific character
            if let character = characters.first(where: { $0.id == characterID }) {
                character.performAction(action)
            }
        } else {
            // Perform action on all characters
            characters.forEach { $0.performAction(action) }
        }

        isReceivingRemoteUpdate = false
    }

    // Helper method to trigger effect from remote
    private func triggerEffectFromRemote(_ effect: MagicEffect) {
        isReceivingRemoteUpdate = true
        activeEffect = effect

        // Auto-dismiss effect after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if self.activeEffect == effect {
                self.activeEffect = nil
            }
        }

        isReceivingRemoteUpdate = false
    }
}

// MARK: - SharePlayServiceDelegate
extension CharacterViewModel: SharePlayServiceDelegate {
    func sharePlayService(_ service: SharePlayService, didReceiveCharacterSpawn characterID: UUID, type: CharacterType, position: SIMD3<Float>) {
        print("SharePlay: Received character spawn - ID: \(characterID), Type: \(type)")
        spawnCharacterFromRemote(id: characterID, type: type, position: position)
    }

    func sharePlayService(_ service: SharePlayService, didReceiveAction action: CharacterAction, for characterID: UUID?) {
        print("SharePlay: Received action - \(action), Character ID: \(characterID?.uuidString ?? "all")")
        performActionFromRemote(action, characterID: characterID)
    }

    func sharePlayService(_ service: SharePlayService, didReceiveEffect effect: MagicEffect) {
        print("SharePlay: Received effect - \(effect)")
        triggerEffectFromRemote(effect)
    }
}
