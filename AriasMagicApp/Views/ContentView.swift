import SwiftUI

struct ContentView: View {
    @State private var store = CharacterStore()
    @State private var sceneController = ARSceneController()
    @StateObject private var sharePlay = SharePlayService.shared
    
    @State private var selectedCharacterType: CharacterType = .sparkleThePrincess
    @State private var selectedCharacterID: UUID?
    
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // AR View
            ARContainerView(
                store: store,
                selectedCharacterType: $selectedCharacterType,
                selectedCharacterID: $selectedCharacterID,
                sceneController: sceneController
            )
            .edgesIgnoringSafeArea(.all)
            .accessibilityIdentifier("ARView")
            
            // UI Overlay
            VStack {
                // Header
                headerView
                
                Spacer()
                
                // Controls
                VStack(spacing: 12) {
                    // Magic Effects
                    EffectsButtonsView(store: store)
                    
                    // Character Picker
                    CharacterPickerView(selectedType: $selectedCharacterType)
                    
                    // Action Buttons
                    ActionButtonsView(store: store, selectedCharacterID: $selectedCharacterID)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            Text("Settings (Coming Soon)")
        }
        .onAppear {
            sharePlay.bind(to: store)
        }
    }
    
    var headerView: some View {
        HStack {
            Text("✨ Aria's World")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            HStack(spacing: 12) {
                // SharePlay Button
                Button {
                    sharePlay.start()
                    HapticManager.shared.trigger(.medium)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: sharePlay.isActive ? "shareplay" : "shareplay.slash")
                        if sharePlay.isActive {
                            Text("\(sharePlay.participants.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(sharePlay.isActive ? .green : .white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Capsule())
                }
                
                // Settings Button
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
    }
}

#Preview {
    ContentView()
}
