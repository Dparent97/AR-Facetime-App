import SwiftUI

struct ActionButtonsView: View {
    @Bindable var store: CharacterStore
    @Binding var selectedCharacterID: UUID?
    
    // Grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if selectedCharacterID != nil {
                Text("Tap an action!")
                    .font(.caption)
                    .foregroundColor(.white)
                    .shadow(radius: 1)
            } else {
                Text("Tap a character to perform actions")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .shadow(radius: 1)
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ActionBtn(icon: "hand.wave.fill", label: "Wave", color: .blue) {
                    perform(.wave)
                }
                
                ActionBtn(icon: "figure.dance", label: "Dance", color: .purple) {
                    perform(.dance)
                }
                
                ActionBtn(icon: "arrow.triangle.2.circlepath", label: "Twirl", color: .orange) {
                    perform(.twirl)
                }
                
                ActionBtn(icon: "arrow.up.circle.fill", label: "Jump", color: .green) {
                    perform(.jump)
                }
                
                ActionBtn(icon: "sparkles", label: "Sparkle", color: .yellow) {
                    perform(.sparkle)
                }
            }
            .padding(.horizontal)
            .disabled(selectedCharacterID == nil)
            .opacity(selectedCharacterID == nil ? 0.5 : 1.0)
        }
    }
    
    private func perform(_ action: CharacterAction) {
        guard let id = selectedCharacterID else { return }
        store.performAction(id: id, action: action)
        HapticManager.shared.trigger(.light)
    }
}

struct ActionBtn: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .padding(.bottom, 4)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}
