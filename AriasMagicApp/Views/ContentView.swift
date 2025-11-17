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
    @State private var showSettings = false

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

                    HStack(spacing: 12) {
                        if sharePlayService.isActive {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                        }

                        Button {
                            HapticManager.shared.trigger(.light)
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()

                Spacer()

                // Character picker
                CharacterPickerView(viewModel: characterViewModel)
                    .padding(.bottom, 12)

                // Action buttons
                ActionButtonsView(viewModel: characterViewModel)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
