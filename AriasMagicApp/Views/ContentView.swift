import SwiftUI

struct ContentView: View {
    @State private var store = CharacterStore()
    @State private var sceneController = ARSceneController() // Held here to survive re-renders
    
    @State private var selectedCharacterType: CharacterType = .sparkleThePrincess
    @State private var selectedCharacterID: UUID?
    
    @State private var showOnboarding = false // Deferred
    @State private var showSettings = false // Deferred
    
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
                HStack {
                    Text("✨ Aria's Magic World")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
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
                .padding()
                
                Spacer()
                
                // Character Picker
                CharacterPickerView(selectedType: $selectedCharacterType)
                    .padding(.bottom, 12)
                
                // Action Buttons
                ActionButtonsView(store: store, selectedCharacterID: $selectedCharacterID)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            Text("Settings (Coming Soon)")
        }
    }
}

#Preview {
    ContentView()
}
