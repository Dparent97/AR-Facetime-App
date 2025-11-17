//
//  OnboardingView.swift
//  Aria's Magic SharePlay App
//
//  Simple onboarding for first launch
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    let pages = [
        OnboardingPage(
            emoji: "✨",
            title: "Welcome to Magic World!",
            description: "Tap anywhere to spawn magical princess characters"
        ),
        OnboardingPage(
            emoji: "😊",
            title: "Smile for Magic!",
            description: "Smile to create sparkles\nRaise your eyebrows to wave\nOpen your mouth to jump"
        ),
        OnboardingPage(
            emoji: "🎭",
            title: "Make Them Dance!",
            description: "Use the buttons to make your characters wave, dance, twirl, and jump"
        ),
        OnboardingPage(
            emoji: "👯",
            title: "Share with FaceTime!",
            description: "Use SharePlay during FaceTime to share the magic together"
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .pink]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text(pages[currentPage].emoji)
                    .font(.system(size: 100))

                Text(pages[currentPage].title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(pages[currentPage].description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }

                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                    }

                    Spacer()

                    Button(currentPage == pages.count - 1 ? "Start Magic!" : "Next") {
                        withAnimation {
                            if currentPage == pages.count - 1 {
                                isPresented = false
                            } else {
                                currentPage += 1
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
