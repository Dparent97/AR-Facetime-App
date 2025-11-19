//
//  CharacterPickerView.swift
//  Aria's Magic SharePlay App
//
//  Character selection UI for spawning different princesses
//

import SwiftUI

struct CharacterPickerView: View {
    @ObservedObject var viewModel: CharacterViewModel
    @Namespace private var animation

    let characterTypes: [CharacterType] = CharacterType.allCases

    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("Choose Your Princess")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)

            // Character cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(characterTypes, id: \.self) { type in
                        CharacterCard(
                            type: type,
                            isSelected: viewModel.selectedCharacterType == type,
                            namespace: animation
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedCharacterType = type
                                HapticManager.shared.trigger(.selection)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
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
            .cornerRadius(20, corners: [.topLeft, .topRight])
        )
    }
}

struct CharacterCard: View {
    let type: CharacterType
    let isSelected: Bool
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 8) {
            // Character preview (placeholder)
            ZStack {
                Circle()
                    .fill(characterColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color.white : Color.white.opacity(0.3),
                                lineWidth: isSelected ? 4 : 2
                            )
                    )
                    .shadow(
                        color: isSelected ? characterColor.opacity(0.6) : .clear,
                        radius: isSelected ? 12 : 0
                    )

                Text(characterEmoji)
                    .font(.system(size: 40))
            }

            // Character name
            Text(characterName)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 100)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .frame(width: 120, height: 140)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .opacity(isSelected ? 1.0 : 0.7)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

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

    private var characterEmoji: String {
        switch type {
        case .sparkleThePrincess: return "👸"
        case .lunaTheStarDancer: return "🌟"
        case .rosieTheDreamWeaver: return "🌹"
        case .crystalTheGemKeeper: return "💎"
        case .willowTheWishMaker: return "🌿"
        }
    }

    private var characterName: String {
        switch type {
        case .sparkleThePrincess: return "Sparkle"
        case .lunaTheStarDancer: return "Luna"
        case .rosieTheDreamWeaver: return "Rosie"
        case .crystalTheGemKeeper: return "Crystal"
        case .willowTheWishMaker: return "Willow"
        }
    }
}

// Helper extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    CharacterPickerView(viewModel: CharacterViewModel())
}
