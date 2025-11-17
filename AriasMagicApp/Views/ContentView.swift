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
    @State private var showErrorAlert = false
    @State private var currentAlert: ErrorAlert?

    var body: some View {
        ZStack {
            // AR View (main background)
            MagicARView(viewModel: characterViewModel) { error in
                handleError(error)
            }
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
        .alert(item: $currentAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    characterViewModel.dismissError()
                }
            )
        }
        .onReceive(characterViewModel.$currentError) { errorState in
            if let errorState = errorState, !errorState.isDismissed {
                currentAlert = ErrorAlert(from: errorState.error)
            }
        }
        .onReceive(sharePlayService.$lastError) { error in
            if let error = error {
                handleError(error)
            }
        }
        .onAppear {
            // Set up error handlers
            sharePlayService.onError = { error in
                handleError(error)
            }
        }
    }

    private func handleError(_ error: AppError) {
        // Determine if we should show an alert based on severity
        switch error.severity {
        case .info:
            // Just log, no alert needed
            ErrorLoggingService.shared.logError(error)
        case .warning:
            // Show non-intrusive alert for warnings
            currentAlert = ErrorAlert(from: error)
        case .error, .critical:
            // Show full alert for errors
            currentAlert = ErrorAlert(from: error)
        }
    }
}

// MARK: - Error Alert Helper

struct ErrorAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String

    init(from error: AppError) {
        self.title = error.errorDescription ?? "Error"
        var messageText = error.failureReason ?? ""
        if let recovery = error.recoverySuggestion {
            messageText += "\n\n\(recovery)"
        }
        self.message = messageText
    }
}

#Preview {
    ContentView()
}
