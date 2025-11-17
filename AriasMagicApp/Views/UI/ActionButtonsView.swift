//
//  ActionButtonsView.swift
//  Aria's Magic SharePlay App
//
//  Action buttons for character animations
//

import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var viewModel: CharacterViewModel

    let actions: [(CharacterAction, String, String)] = [
        (.wave, "👋", "Wave"),
        (.dance, "💃", "Dance"),
        (.twirl, "🌀", "Twirl"),
        (.jump, "⬆️", "Jump")
    ]

    let effects: [MagicEffect] = MagicEffect.allCases

    var body: some View {
        VStack(spacing: 12) {
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
                        viewModel.triggerEffect(effect)
                        HapticManager.shared.trigger(.medium)
                    }
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
                        viewModel.performAction(action)
                        HapticManager.shared.trigger(.medium)
                    }
                }
            }
        }
    }

    // Gradients for effect buttons
    private func effectGradient(for effect: MagicEffect) -> LinearGradient {
        switch effect {
        case .sparkles:
            return LinearGradient(
                colors: [Color.yellow, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snow:
            return LinearGradient(
                colors: [Color.cyan, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bubbles:
            return LinearGradient(
                colors: [Color.mint, Color.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // Gradients for action buttons
    private func actionGradient(for action: CharacterAction) -> LinearGradient {
        switch action {
        case .wave:
            return LinearGradient(
                colors: [Color.pink, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dance:
            return LinearGradient(
                colors: [Color.red, Color.pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .twirl:
            return LinearGradient(
                colors: [Color.purple, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .jump:
            return LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.gray, Color.gray.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Enhanced Magic Button with animations and feedback
struct MagicButton: View {
    let emoji: String
    let label: String
    let gradient: LinearGradient
    let isActive: Bool
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

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
                    .font(.system(size: 12, weight: .semibold))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(width: 75, height: 75)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isEnabled ? gradient : LinearGradient(
                        colors: [Color.gray.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(isActive ? 0.8 : 0.0), lineWidth: 3)
            )
            .shadow(
                color: .black.opacity(isPressed ? 0.1 : 0.3),
                radius: isPressed ? 2 : 6,
                x: 0,
                y: isPressed ? 1 : 3
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
        }
        .buttonStyle(MagicButtonStyle(isPressed: $isPressed))
        .disabled(!isEnabled)
        // Accessibility
        .accessibilityLabel("\(label) button")
        .accessibilityHint(isEnabled ? "Tap to \(label.lowercased())" : "No characters available")
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

// Custom button style for press animations
struct MagicButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = newValue
                }
            }
    }
}

#Preview {
    ActionButtonsView(viewModel: CharacterViewModel())
}
