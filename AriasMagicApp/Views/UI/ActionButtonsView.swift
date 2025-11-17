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
                    Button(action: {
                        viewModel.triggerEffect(effect)
                    }) {
                        VStack(spacing: 4) {
                            Text(effect.emoji)
                                .font(.title)
                            Text(effect.rawValue.capitalized)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .frame(width: 70, height: 70)
                        .background(Color.purple.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
            }

            // Character actions row
            HStack(spacing: 12) {
                ForEach(actions, id: \.0) { action, emoji, label in
                    Button(action: {
                        viewModel.performAction(action)
                    }) {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.title)
                            Text(label)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .frame(width: 70, height: 70)
                        .background(Color.pink.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }
}

#Preview {
    ActionButtonsView(viewModel: CharacterViewModel())
}
