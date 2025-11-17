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

    init() {
        // Start with one default character
        spawnCharacter(at: [0, 0, -0.5])
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

    func spawnCharacter(at position: SIMD3<Float>) {
        let character = Character(type: selectedCharacterType, position: position)
        characters.append(character)
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
    }

    func triggerEffect(_ effect: MagicEffect) {
        activeEffect = effect

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
}
