import SwiftUI

struct CharacterPickerView: View {
    @Binding var selectedType: CharacterType

    let characterTypes = CharacterType.allCases

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("Choose Your Princess")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.top, 8)
                .padding(.bottom, 12)

            // Character cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(characterTypes, id: \.self) { type in
                        CharacterCard(
                            type: type,
                            isSelected: selectedType == type
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedType = type
                                HapticManager.shared.trigger(.selection)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.pink.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }
}

struct CharacterCard: View {
    let type: CharacterType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Character preview
            ZStack {
                // Background circle
                Circle()
                    .fill(characterColor.opacity(0.3))
                    .frame(width: 80, height: 80)

                // Character placeholder (will be replaced with actual images)
                Text(characterEmoji)
                    .font(.system(size: 40))
            }
            .overlay(
                Circle()
                    .strokeBorder(
                        isSelected ? characterColor : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 4 : 2
                    )
                    .frame(width: 84, height: 84)
            )

            // Character name
            Text(shortName)
                .font(.system(size: 14, weight: isSelected ? .bold : .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 100)
        }
        .frame(width: 120, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        // Accessibility
        .accessibilityLabel("\(type.rawValue), \(isSelected ? "selected" : "not selected")")
        .accessibilityHint("Tap to select this character")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // Character-specific colors
    private var characterColor: Color {
        switch type {
        case .sparkleThePrincess:
            return Color(red: 1.0, green: 0.4, blue: 0.8) // Pink
        case .lunaTheStarDancer:
            return Color(red: 0.6, green: 0.4, blue: 1.0) // Purple
        case .rosieTheDreamWeaver:
            return Color(red: 1.0, green: 0.2, blue: 0.4) // Red
        case .crystalTheGemKeeper:
            return Color(red: 0.2, green: 0.8, blue: 1.0) // Cyan
        case .willowTheWishMaker:
            return Color(red: 0.2, green: 1.0, blue: 0.6) // Green
        }
    }

    // Character emojis (placeholders until 3D renders are ready)
    private var characterEmoji: String {
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

    // Shortened names for better display
    private var shortName: String {
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
}
