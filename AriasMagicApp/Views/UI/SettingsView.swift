//
//  SettingsView.swift
//  Aria's Magic SharePlay App
//
//  User preferences and app configuration
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = AppSettings.shared

    var body: some View {
        NavigationView {
            Form {
                // Audio Section
                Section {
                    Toggle("Sound Effects", isOn: $settings.soundEnabled)
                        .onChange(of: settings.soundEnabled) { _ in
                            HapticManager.shared.trigger(.light)
                        }

                    if settings.soundEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "speaker.wave.1.fill")
                                    .foregroundColor(.secondary)
                                Text("Volume")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(settings.soundVolume * 100))%")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.soundVolume, in: 0...1)
                                .tint(.pink)
                        }
                    }
                } header: {
                    Label("Audio", systemImage: "speaker.wave.2.fill")
                }

                // Face Tracking Section
                Section {
                    Toggle("Face Tracking", isOn: $settings.faceTrackingEnabled)
                        .onChange(of: settings.faceTrackingEnabled) { _ in
                            HapticManager.shared.trigger(.light)
                        }

                    if settings.faceTrackingEnabled {
                        Picker("Sensitivity", selection: $settings.faceTrackingSensitivity) {
                            Text("Easy").tag(0.3)
                            Text("Medium").tag(0.5)
                            Text("Hard").tag(0.7)
                        }
                        .pickerStyle(.segmented)

                        Text("Easy: Triggers with subtle expressions\nMedium: Balanced sensitivity\nHard: Needs clear expressions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("Face Tracking", systemImage: "face.smiling.fill")
                } footer: {
                    Text("Smile for sparkles, raise eyebrows to wave, open mouth to jump!")
                }

                // Haptics Section
                Section {
                    Toggle("Haptic Feedback", isOn: $settings.hapticsEnabled)
                        .onChange(of: settings.hapticsEnabled) { newValue in
                            HapticManager.shared.isEnabled = newValue
                            if newValue {
                                HapticManager.shared.trigger(.success)
                            }
                        }
                } header: {
                    Label("Haptics", systemImage: "hand.tap.fill")
                } footer: {
                    Text("Feel tactile feedback when interacting with characters")
                }

                // Accessibility Section
                Section {
                    Toggle("Reduce Motion", isOn: $settings.reduceMotion)
                        .onChange(of: settings.reduceMotion) { _ in
                            HapticManager.shared.trigger(.light)
                        }

                    Toggle("High Contrast", isOn: $settings.highContrast)
                        .onChange(of: settings.highContrast) { _ in
                            HapticManager.shared.trigger(.light)
                        }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("UI Scale")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(settings.uiScale * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $settings.uiScale, in: 0.8...1.2, step: 0.1)
                            .tint(.pink)
                    }
                } header: {
                    Label("Accessibility", systemImage: "accessibility.fill")
                } footer: {
                    Text("Customize the app for better visibility and comfort")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Interactive Help", systemImage: "book.fill")
                    }

                    NavigationLink {
                        SupportView()
                    } label: {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }

                    NavigationLink {
                        CreditsView()
                    } label: {
                        Label("Credits", systemImage: "star.fill")
                    }
                } header: {
                    Label("About", systemImage: "info.circle.fill")
                }

                // Reset Section
                Section {
                    Button(role: .destructive) {
                        resetSettings()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Settings")
                        }
                    }
                } footer: {
                    Text("This will restore all settings to their default values")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticManager.shared.trigger(.light)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func resetSettings() {
        HapticManager.shared.trigger(.warning)

        withAnimation {
            settings.soundEnabled = true
            settings.soundVolume = 0.7
            settings.faceTrackingEnabled = true
            settings.faceTrackingSensitivity = 0.5
            settings.hapticsEnabled = true
            settings.reduceMotion = false
            settings.highContrast = false
            settings.uiScale = 1.0
        }
    }
}

// App Settings Model
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    // Audio
    @Published var soundEnabled: Bool = true
    @Published var soundVolume: Double = 0.7

    // Face Tracking
    @Published var faceTrackingEnabled: Bool = true
    @Published var faceTrackingSensitivity: Double = 0.5

    // Haptics
    @Published var hapticsEnabled: Bool = true

    // Accessibility
    @Published var reduceMotion: Bool = false
    @Published var highContrast: Bool = false
    @Published var uiScale: Double = 1.0

    private init() {
        // Load saved settings (UserDefaults integration can be added here)
    }
}

// Placeholder views for About section
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                Text("Your Privacy Matters")
                    .font(.headline)

                Text("Aria's Magic SharePlay App is designed with child safety and privacy as our top priority. We do not collect, store, or share any personal data.")
                    .font(.body)

                Text("Camera & Face Tracking")
                    .font(.headline)

                Text("Face tracking data is processed entirely on your device and is never stored or transmitted. The camera is only used for AR and face tracking features, and all processing happens locally.")
                    .font(.body)

                Text("SharePlay")
                    .font(.headline)

                Text("When using SharePlay on FaceTime, only the AR content is shared with other participants. No personal data is transmitted through our app.")
                    .font(.body)

                Text("Data Collection")
                    .font(.headline)

                Text("We do not collect any personal information, analytics, or usage data. Everything stays on your device.")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportView: View {
    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "mailto:support@ariasmagic.app")!) {
                    Label("Email Support", systemImage: "envelope.fill")
                }

                Link(destination: URL(string: "https://ariasmagic.app/faq")!) {
                    Label("FAQ", systemImage: "questionmark.circle.fill")
                }

                Link(destination: URL(string: "https://ariasmagic.app/troubleshooting")!) {
                    Label("Troubleshooting", systemImage: "wrench.and.screwdriver.fill")
                }
            } header: {
                Text("Get Help")
            }

            Section {
                NavigationLink {
                    Text("Tutorial content coming soon")
                } label: {
                    Label("How to Use SharePlay", systemImage: "person.2.fill")
                }

                NavigationLink {
                    Text("Tutorial content coming soon")
                } label: {
                    Label("Face Tracking Tips", systemImage: "face.smiling.fill")
                }
            } header: {
                Text("Tutorials")
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                    .padding(.top, 20)

                Text("Aria's Magic SharePlay App")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    CreditSection(
                        title: "Created By",
                        items: [
                            "Multi-Agent Development Team",
                            "iOS Core Engineer",
                            "3D Engineer",
                            "UI/UX Engineer",
                            "QA Engineer",
                            "Technical Writer"
                        ]
                    )

                    CreditSection(
                        title: "Special Thanks",
                        items: [
                            "All the children who inspired this app",
                            "Apple's ARKit & RealityKit teams",
                            "The SwiftUI community"
                        ]
                    )

                    CreditSection(
                        title: "Technologies",
                        items: [
                            "SwiftUI",
                            "ARKit",
                            "RealityKit",
                            "GroupActivities (SharePlay)"
                        ]
                    )
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreditSection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.pink)

            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
