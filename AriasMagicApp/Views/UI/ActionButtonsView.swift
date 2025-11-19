//
//  ActionButtonsView.swift
//  Aria's Magic SharePlay App
//
//  Action buttons for character animations with delightful interactions
//

import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var viewModel: CharacterViewModel

    // Track button press states for animations
    @State private var pressedButton: String?

    let actions: [(CharacterAction, String, String)] = [
        (.wave, "👋", "Wave"),
        (.dance, "💃", "Dance"),
        (.twirl, "🌀", "Twirl"),
        (.jump, "⬆️", "Jump")
    ]

    let effects: [MagicEffect] = MagicEffect.allCases

    var body: some View {
        VStack(spacing: 16) {
            // Magic effects row
            HStack(spacing: 12) {
                ForEach(effects, id: \.self) { effect in
                    MagicButton(
                        emoji: effect.emoji,
                        label: effect.rawValue.capitalized,
                        gradient: effectGradient(for: effect),
                        isActive: viewModel.activeEffect == effect,
                        isEnabled: !viewModel.characters.isEmpty
                    ) {
                        triggerEffect(effect)
                    }
                    .accessibilityLabel("\(effect.rawValue.capitalized) effect")
                    .accessibilityHint(hasCharacters ? "Trigger magical \(effect.rawValue) effect" : "No characters available")
                    .accessibilityAddTraits(.isButton)
                }
            }

            // Character actions row
            HStack(spacing: 12) {
                ForEach(actions, id: \.0) { action, emoji, label in
                    MagicButton(
                        emoji: emoji,
                        label: label,
                        gradient: actionGradient(for: action),
                        isActive: false,
                        isEnabled: !viewModel.characters.isEmpty
                    ) {
                        performAction(action)
                    }
                    .accessibilityLabel("\(label) action")
                    .accessibilityHint(hasCharacters ? "Make characters \(label.lowercased())" : "No characters available")
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Computed Properties

    private var hasCharacters: Bool {
        !viewModel.characters.isEmpty
    }

    // MARK: - Actions

    private func performAction(_ action: CharacterAction) {
        guard hasCharacters else {
            HapticManager.shared.limitReached()
            return
        }

        HapticManager.shared.actionPerformed()
        viewModel.performAction(action)
    }

    private func triggerEffect(_ effect: MagicEffect) {
        guard hasCharacters else {
            HapticManager.shared.limitReached()
            return
        }

        HapticManager.shared.effectTriggered()
        viewModel.triggerEffect(effect)
    }

    // MARK: - Gradients

    private func effectGradient(for effect: MagicEffect) -> LinearGradient {
        switch effect {
        case .sparkles:
            return LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .snow:
            return LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .bubbles:
            return LinearGradient(colors: [Color.mint, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private func actionGradient(for action: CharacterAction) -> LinearGradient {
        switch action {
        case .wave:
            return LinearGradient(colors: [Color.pink, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dance:
            return LinearGradient(colors: [Color.red, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .twirl:
            return LinearGradient(colors: [Color.purple, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .jump:
            return LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color.gray, Color.gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Magic Button Component

struct MagicButton: View {
    let emoji: String
    let label: String
    let gradient: LinearGradient
    let isActive: Bool
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressing = false

    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(width: 75, height: 75)
            .background(
                gradient
                    .opacity(isEnabled ? 1.0 : 0.5)
            )
            .foregroundColor(.white)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(isActive ? 0.6 : 0), lineWidth: 2)
            )
            .shadow(
                color: isEnabled ? Color.black.opacity(0.3) : Color.clear,
                radius: isPressing ? 2 : 6,
                x: 0,
                y: isPressing ? 1 : 3
            )
            .scaleEffect(isPressing ? 0.95 : (isActive ? 1.05 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
        }
        .buttonStyle(PressableButtonStyle(isPressing: $isPressing))
        .disabled(!isEnabled)
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressing: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressing = newValue
            }
    }
}
