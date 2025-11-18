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
                        colors: gradientForEffect(effect),
                        isPressed: pressedButton == effect.rawValue,
                        isEnabled: hasCharacters,
                        isActive: viewModel.activeEffect == effect
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
                        colors: gradientForAction(action),
                        isPressed: pressedButton == label,
                        isEnabled: hasCharacters,
                        isActive: false
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
            // Provide feedback that action isn't available
            HapticManager.shared.limitReached()
            return
        }

        // Haptic feedback
        HapticManager.shared.actionPerformed()

        // Visual feedback
        pressedButton = action.rawValue
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            pressedButton = nil
        }

        // Perform the action
        viewModel.performAction(action)
    }

    private func triggerEffect(_ effect: MagicEffect) {
        guard hasCharacters else {
            // Provide feedback that effect isn't available
            HapticManager.shared.limitReached()
            return
        }

        // Haptic feedback
        HapticManager.shared.effectTriggered()

        // Visual feedback
        pressedButton = effect.rawValue
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            pressedButton = nil
        }

        // Trigger the effect
        viewModel.triggerEffect(effect)
    }

    // MARK: - Color Schemes

    private func gradientForEffect(_ effect: MagicEffect) -> [Color] {
        switch effect {
        case .sparkles:
            return [Color(red: 1.0, green: 0.8, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.0)]
        case .snow:
            return [Color(red: 0.7, green: 0.9, blue: 1.0), Color(red: 0.5, green: 0.7, blue: 1.0)]
        case .bubbles:
            return [Color(red: 0.4, green: 0.8, blue: 1.0), Color(red: 0.2, green: 0.6, blue: 1.0)]
        }
    }

    private func gradientForAction(_ action: CharacterAction) -> [Color] {
        switch action {
        case .wave:
            return [Color(red: 1.0, green: 0.4, blue: 0.8), Color(red: 0.9, green: 0.2, blue: 0.6)]
        case .dance:
            return [Color(red: 0.8, green: 0.3, blue: 1.0), Color(red: 0.6, green: 0.2, blue: 0.9)]
        case .twirl:
            return [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 0.9, green: 0.1, blue: 0.4)]
        case .jump:
            return [Color(red: 1.0, green: 0.5, blue: 0.3), Color(red: 1.0, green: 0.3, blue: 0.2)]
        default:
            return [Color.pink, Color.purple]
        }
    }
}

// MARK: - Magic Button Component

/// Reusable button component with delightful animations and feedback
struct MagicButton: View {
    let emoji: String
    let label: String
    let colors: [Color]
    let isPressed: Bool
    let isEnabled: Bool
    let isActive: Bool
    let action: () -> Void

    @State private var isPressing = false

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            action()
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
                LinearGradient(
                    colors: isEnabled ? colors : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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
            .opacity(isEnabled ? 1.0 : 0.4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isActive)
        }
        .buttonStyle(PressableButtonStyle(isPressing: $isPressing))
        .disabled(!isEnabled)
    }
}

// MARK: - Button Style with Press Detection

/// Custom button style that provides press state feedback
struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressing: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressing = newValue
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.purple.opacity(0.1).ignoresSafeArea()
        VStack {
            Spacer()
            ActionButtonsView(viewModel: CharacterViewModel())
        }
    }
}

#Preview("Single Button") {
    MagicButton(
        emoji: "✨",
        label: "Sparkles",
        colors: [Color.yellow, Color.orange],
        isPressed: false,
        isEnabled: true,
        isActive: false
    ) {
        print("Button tapped")
    }
    .padding()
}
