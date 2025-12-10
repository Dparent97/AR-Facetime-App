import SwiftUI

struct EffectsButtonsView: View {
    @Bindable var store: CharacterStore
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                EffectBtn(emoji: "✨", label: "Sparkles", color: .yellow) {
                    spawn(.sparkles)
                }
                
                EffectBtn(emoji: "❄️", label: "Snow", color: .cyan) {
                    spawn(.snow)
                }
                
                EffectBtn(emoji: "🫧", label: "Bubbles", color: .blue) {
                    spawn(.bubbles)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func spawn(_ type: EffectType) {
        // Spawn 1 meter in front of camera (approx, need camera position?)
        // For now, we spawn at (0,0,-1) or random nearby if we don't have camera pos in UI.
        // Ideally ARSceneController spawns it relative to camera, but UI controls Store.
        // Store just stores position.
        // Let's spawn at (0, 0, -0.5) + random offset
        
        let randomX = Float.random(in: -0.2...0.2)
        let position = SIMD3<Float>(randomX, 0, -0.5)
        store.spawnEffect(type: type, at: position)
        HapticManager.shared.trigger(.medium)
    }
}

struct EffectBtn: View {
    let emoji: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(emoji)
                    .font(.system(size: 30))
                Text(label)
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(width: 70, height: 70)
            .background(color.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}


