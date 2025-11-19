//
//  ActionButtonsView.swift
//  Aria's Magic SharePlay App
//
//  Action buttons for character animations and effects
//

import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var viewModel: CharacterViewModel

    let actions: [(CharacterAction, String, String, Color)] = [
        (.wave, "👋", "Wave", Color(red: 1.0, green: 0.6, blue: 0.8)),
        (.dance, "💃", "Dance", Color(red: 1.0, green: 0.4, blue: 0.8)),
        (.twirl, "🌀", "Twirl", Color(red: 0.8, green: 0.4, blue: 1.0)),
        (.jump, "⬆️", "Jump", Color(red: 0.6, green: 0.4, blue: 1.0))
    ]

    let effects: [(MagicEffect, Color)] = [
        (.sparkles, Color(red: 1.0, green: 0.8, blue: 0.2)),
        (.snow, Color(red: 0.7, green: 0.9, blue: 1.0)),
        (.bubbles, Color(red: 0.2, green: 0.8, blue: 1.0))
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Magic effects row
            HStack(spacing: 12) {
                ForEach(effects, id: \.0) { effect, color in
                    MagicButton(
                        emoji: effect.emoji,
                        label: effect.rawValue.capitalized,
                        color: color,
                        isActive: viewModel.activeEffect == effect,
                        isEnabled: !viewModel.characters.isEmpty
                    ) {
                        viewModel.triggerEffect(effect)
                    }
                }
            }

            // Character actions row
            HStack(spacing: 12) {
                ForEach(actions, id: \.0) { action, emoji, label, color in
                    MagicButton(
                        emoji: emoji,
                        label: label,
                        color: color,
                        isActive: false,
                        isEnabled: !viewModel.characters.isEmpty
                    ) {
                        viewModel.performAction(action)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct MagicButton: View {
    let emoji: String
    let label: String
    let color: Color
    let isActive: Bool
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            HapticManager.shared.trigger(.medium)
            action()
        }) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(width: 75, height: 75)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(isEnabled ? 0.9 : 0.4),
                        color.opacity(isEnabled ? 0.7 : 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(isEnabled ? .white : .white.opacity(0.5))
            .cornerRadius(18)
            .shadow(
                color: isActive ? color.opacity(0.6) : .black.opacity(0.2),
                radius: isActive ? 8 : 4,
                x: 0,
                y: isPressed ? 1 : 3
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isActive ? Color.white : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .opacity(isActive ? 1.0 : (isEnabled ? 1.0 : 0.6))
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && isEnabled {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        .disabled(!isEnabled)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        ActionButtonsView(viewModel: CharacterViewModel())
    }
}
