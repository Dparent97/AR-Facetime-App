//
//  OnboardingView.swift
//  Aria's Magic SharePlay App
//
//  Child-friendly onboarding for first launch
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var bounceAnimation = false

    let pages = [
        OnboardingPage(
            emoji: "✨",
            title: "Welcome to Aria's Magic App!",
            subtitle: "Create magical moments with princess friends",
            description: "Meet 5 amazing princesses who love to play!",
            gradient: [Color.purple, Color.pink]
        ),
        OnboardingPage(
            emoji: "👆",
            title: "Tap to Bring Princesses to Life!",
            subtitle: "It's easy and fun",
            description: "• Tap screen to add a princess\n• Drag to move her around\n• Pinch to make her bigger or smaller",
            gradient: [Color.pink, Color.orange]
        ),
        OnboardingPage(
            emoji: "😊",
            title: "Your Face is Magic!",
            subtitle: "Make magic with your expressions",
            description: "😊 Smile → Sparkles appear!\n😲 Raise eyebrows → They wave!\n😮 Open mouth → They jump!",
            gradient: [Color.cyan, Color.blue]
        ),
        OnboardingPage(
            emoji: "📱",
            title: "Share the Magic on FaceTime!",
            subtitle: "Play together with friends",
            description: "Start a FaceTime call and use SharePlay to share your magical world!",
            gradient: [Color.green, Color.mint]
        )
    ]

    var body: some View {
        ZStack {
            // Animated background
            LinearGradient(
                gradient: Gradient(colors: pages[currentPage].gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            // Skip button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        HapticManager.shared.trigger(.light)
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    }
                    .padding()
                }
                Spacer()
            }

            // Main content
            VStack(spacing: 20) {
                Spacer()

                // Large emoji with bounce animation
                Text(pages[currentPage].emoji)
                    .font(.system(size: 120))
                    .scaleEffect(bounceAnimation ? 1.1 : 1.0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.5)
                        .repeatForever(autoreverses: true),
                        value: bounceAnimation
                    )
                    .onAppear {
                        bounceAnimation = true
                    }

                // Title
                Text(pages[currentPage].title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // Subtitle
                Text(pages[currentPage].subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // Description
                Text(pages[currentPage].description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                    )
                    .padding(.horizontal, 30)

                Spacer()

                // Page indicator with animation
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 30 : 10, height: 10)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 10)

                // Navigation buttons
                HStack(spacing: 20) {
                    // Back button
                    if currentPage > 0 {
                        Button {
                            HapticManager.shared.trigger(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentPage -= 1
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(25)
                        }
                    } else {
                        Spacer()
                            .frame(width: 100)
                    }

                    Spacer()

                    // Next/Start button
                    Button {
                        HapticManager.shared.trigger(.medium)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if currentPage == pages.count - 1 {
                                isPresented = false
                            } else {
                                currentPage += 1
                            }
                        }
                    } label: {
                        HStack {
                            Text(currentPage == pages.count - 1 ? "Start Magic!" : "Next")
                            if currentPage < pages.count - 1 {
                                Image(systemName: "chevron.right")
                            } else {
                                Image(systemName: "sparkles")
                            }
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(pages[currentPage].gradient[0])
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .onChange(of: currentPage) { _ in
            // Reset bounce animation when page changes
            bounceAnimation = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                bounceAnimation = true
            }
        }
    }
}

struct OnboardingPage {
    let emoji: String
    let title: String
    let subtitle: String
    let description: String
    let gradient: [Color]
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
