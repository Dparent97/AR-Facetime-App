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
    @State private var showSkipButton = false

    let pages = [
        OnboardingPage(
            emoji: "👸",
            title: "Welcome to Aria's Magic World!",
            description: "Meet magical princess friends who love to play!",
            gradientColors: [Color.purple, Color.pink]
        ),
        OnboardingPage(
            emoji: "✨",
            title: "Tap to Bring Princesses to Life!",
            description: "Choose your favorite princess, then tap anywhere to make her appear. You can move her around and make her bigger or smaller!",
            gradientColors: [Color.pink, Color.orange]
        ),
        OnboardingPage(
            emoji: "😊",
            title: "Your Face is Magic!",
            description: "😊 Smile → Sparkles appear!\n😮 Open mouth → Princess jumps!\n🤨 Raise eyebrows → Princess waves!",
            gradientColors: [Color.orange, Color.yellow]
        ),
        OnboardingPage(
            emoji: "🎭",
            title: "Make Them Dance & Play!",
            description: "Tap the colorful buttons to make your princesses wave, dance, twirl, and jump. Add sparkles, snow, or bubbles too!",
            gradientColors: [Color.cyan, Color.blue]
        ),
        OnboardingPage(
            emoji: "📱",
            title: "Share the Magic on FaceTime!",
            description: "Play together with friends during FaceTime! Your princesses will appear in both screens at the same time!",
            gradientColors: [Color.blue, Color.purple]
        )
    ]

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: pages[currentPage].gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.trigger(.light)
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Skip")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                .opacity(showSkipButton ? 1 : 0)

                Spacer()

                // Main content
                VStack(spacing: 24) {
                    // Emoji with bounce animation
                    Text(pages[currentPage].emoji)
                        .font(.system(size: 120))
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)

                    // Title
                    Text(pages[currentPage].title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .fixedSize(horizontal: false, vertical: true)

                    // Description
                    Text(pages[currentPage].description)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentPage)

                Spacer()

                // Page indicator
                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 30)

                // Navigation buttons
                HStack(spacing: 20) {
                    // Back button
                    if currentPage > 0 {
                        Button(action: {
                            HapticManager.shared.trigger(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 18, weight: .semibold))
                            }
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
                    Button(action: {
                        HapticManager.shared.trigger(.medium)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if currentPage == pages.count - 1 {
                                HapticManager.shared.trigger(.success)
                                isPresented = false
                            } else {
                                currentPage += 1
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage == pages.count - 1 ? "Start the Magic! ✨" : "Next")
                                .font(.system(size: 18, weight: .bold))
                            if currentPage < pages.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(pages[currentPage].gradientColors[0])
                        .padding(.horizontal, currentPage == pages.count - 1 ? 32 : 28)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Show skip button after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSkipButton = true
                }
            }
        }
    }
}

struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let gradientColors: [Color]
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
