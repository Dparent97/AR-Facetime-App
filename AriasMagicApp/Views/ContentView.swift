//
//  ContentView.swift
//  Aria's Magic SharePlay App
//
//  Main app view coordinating AR and UI
//

import SwiftUI

struct ContentView: View {
    @StateObject private var characterViewModel = CharacterViewModel()
    @StateObject private var sharePlayService = SharePlayService()
    @State private var showOnboarding = true

    init() {
        // Note: We can't configure here because StateObject hasn't been initialized yet
        // We'll do it in onAppear
    }

    var body: some View {
        ZStack {
            // AR View (main background)
            MagicARView(viewModel: characterViewModel)
                .edgesIgnoringSafeArea(.all)

            // UI Overlay
            VStack {
                // Top bar
                HStack {
                    Text("✨ Aria's Magic World")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                    Spacer()

                    if sharePlayService.isActive {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.green)
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                    }
                }
                .padding()

                Spacer()

                // Action buttons
                ActionButtonsView(viewModel: characterViewModel)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onAppear {
            // Connect SharePlayService and CharacterViewModel
            characterViewModel.configure(with: sharePlayService)
        }
    }
}

#Preview {
    ContentView()
}
