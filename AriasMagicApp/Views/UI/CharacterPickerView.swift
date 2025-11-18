//
//  CharacterPickerView.swift
//  Aria's Magic SharePlay App
//
//  Character selection UI with card-based horizontal picker
//

import SwiftUI

/// Card-based character picker for selecting which princess to spawn
struct CharacterPickerView: View {
    @ObservedObject var viewModel: CharacterViewModel

    // Character card data
    private let characterTypes = CharacterType.allCases

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Choose Your Princess")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)

            // Horizontal card scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(characterTypes, id: \.self) { type in
                        CharacterCard(
                            type: type,
                            isSelected: viewModel.selectedCharacterType == type
                        )
                        .onTapGesture {
                            selectCharacter(type)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .frame(height: 190)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.pink.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Actions

    private func selectCharacter(_ type: CharacterType) {
        // Haptic feedback for selection
        HapticManager.shared.characterSelected()

        // Animate selection change
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.selectedCharacterType = type
        }
    }
}

// MARK: - Character Card

/// Individual character card with preview and selection state
struct CharacterCard: View {
    let type: CharacterType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Character preview (colored circle placeholder)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isSelected ? Color.white : Color.white.opacity(0.3),
                                lineWidth: isSelected ? 4 : 2
                            )
                    )
                    .shadow(
                        color: isSelected ? Color.white.opacity(0.5) : Color.black.opacity(0.2),
                        radius: isSelected ? 12 : 6,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )

                // Character initial or emoji
                Text(characterEmoji)
                    .font(.system(size: 50))
            }

            // Character name
            Text(characterName)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: 100)
                .lineLimit(2)
        }
        .frame(width: 120)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .opacity(isSelected ? 1.0 : 0.75)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(characterName), character card")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select this character")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
    }

    // MARK: - Character Properties

    private var characterName: String {
        // Extract just the first name for cleaner UI
        let fullName = type.rawValue
        if let firstName = fullName.components(separatedBy: " ").first {
            return firstName
        }
        return fullName
    }

    private var characterEmoji: String {
        // Emoji representation for each character
        switch type {
        case .sparkleThePrincess:
            return "✨"
        case .lunaTheStarDancer:
            return "🌙"
        case .rosieTheDreamWeaver:
            return "🌹"
        case .crystalTheGemKeeper:
            return "💎"
        case .willowTheWishMaker:
            return "🌿"
        }
    }

    private var gradientColors: [Color] {
        // Gradient colors matching character themes
        switch type {
        case .sparkleThePrincess:
            return [Color(red: 1.0, green: 0.4, blue: 0.8), Color(red: 1.0, green: 0.6, blue: 0.9)]
        case .lunaTheStarDancer:
            return [Color(red: 0.5, green: 0.3, blue: 1.0), Color(red: 0.7, green: 0.5, blue: 1.0)]
        case .rosieTheDreamWeaver:
            return [Color(red: 1.0, green: 0.2, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.5)]
        case .crystalTheGemKeeper:
            return [Color(red: 0.2, green: 0.7, blue: 1.0), Color(red: 0.4, green: 0.9, blue: 1.0)]
        case .willowTheWishMaker:
            return [Color(red: 0.2, green: 1.0, blue: 0.6), Color(red: 0.4, green: 1.0, blue: 0.7)]
        }
    }
}

// MARK: - Preview

#Preview {
    CharacterPickerView(viewModel: CharacterViewModel())
        .previewLayout(.sizeThatFits)
}

#Preview("Selected States") {
    VStack(spacing: 20) {
        CharacterCard(type: .sparkleThePrincess, isSelected: true)
        CharacterCard(type: .lunaTheStarDancer, isSelected: false)
    }
    .padding()
    .background(Color.purple)
}
