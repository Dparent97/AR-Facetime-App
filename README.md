# ✨ Aria's Magic SharePlay App

A magical AR experience for children to use during FaceTime with face tracking, character interactions, and SharePlay support.

## 🎯 Features

- **AR Characters**: 5 unique princess-inspired characters with distinct personalities
- **Face Tracking**: Smile for sparkles, raise eyebrows to wave, open mouth to jump
- **Interactive Gestures**: Tap to spawn, drag to move, pinch to scale
- **Character Actions**: Wave, dance, twirl, and jump animations
- **Magic Effects**: Sparkles, snow, and bubbles
- **SharePlay Support**: Synchronize the magical experience across FaceTime calls
- **Child-Safe**: Designed specifically for young children

## 📱 Requirements

- iOS 17.0 or later
- iPhone or iPad with TrueDepth camera (for face tracking)
- ARKit support

## 🏗️ Project Structure

```
AriasMagicApp/
├── App/
│   └── AriasMagicAppApp.swift          # App entry point
├── Views/
│   ├── ContentView.swift                # Main coordinator view
│   ├── AR/
│   │   └── MagicARView.swift           # AR view with RealityKit
│   └── UI/
│       ├── ActionButtonsView.swift      # Action buttons overlay
│       └── OnboardingView.swift         # First-launch tutorial
├── Models/
│   ├── Character.swift                  # Character model & animations
│   └── MagicEffect.swift               # Particle effects
├── ViewModels/
│   └── CharacterViewModel.swift         # Character state management
├── Services/
│   ├── FaceTrackingService.swift       # Face expression detection
│   └── SharePlayService.swift          # SharePlay synchronization
└── Info.plist                          # App configuration
```

## 🎭 Characters

1. **Sparkle the Princess** 💗 - Pink princess with sparkle magic
2. **Luna the Star Dancer** 💜 - Purple celestial dancer
3. **Rosie the Dream Weaver** ❤️ - Red dream creator
4. **Crystal the Gem Keeper** 💙 - Cyan crystal guardian
5. **Willow the Wish Maker** 💚 - Green wish granter

*Note: Currently using colored cubes as placeholders. Replace with 3D models in production.*

## 🎮 How to Use

### Spawning Characters
- Tap anywhere in the AR space to spawn a character
- Characters appear at the tap location

### Moving & Scaling
- Drag characters to move them around
- Pinch to scale characters larger or smaller

### Face Tracking
- **Smile** 😊 → Triggers sparkle effect
- **Raise eyebrows** 🤨 → Characters wave
- **Open mouth** 😮 → Characters jump

### Action Buttons
- **👋 Wave** - Characters wave hello
- **💃 Dance** - Characters bounce and dance
- **🌀 Twirl** - Characters spin around
- **⬆️ Jump** - Characters jump up

### Magic Effects
- **✨ Sparkles** - Golden sparkle particles
- **❄️ Snow** - Falling snowflakes
- **🫧 Bubbles** - Floating bubbles

### SharePlay
1. Start a FaceTime call
2. Open the app
3. Tap the SharePlay button
4. Both users can now interact with the same characters in sync

## 🛠️ Setup Instructions

1. Open the project in Xcode 15 or later
2. Select your development team in Signing & Capabilities
3. Ensure the following capabilities are enabled:
   - ARKit
   - Camera access
   - Group Activities (for SharePlay)
4. Build and run on a physical device (AR requires a real device)

## 🔐 Privacy & Permissions

The app requests the following permissions:
- **Camera**: Required for AR and face tracking
- **Face Tracking**: Used to detect expressions for magical interactions
- **Group Activities**: Enables SharePlay for synchronized experiences

All processing is done on-device. No data is collected or transmitted.

## 🚀 Next Steps

### Immediate Improvements
- [ ] Replace placeholder cubes with actual 3D character models
- [ ] Add sound effects for actions and magic
- [ ] Implement proper RealityKit particle systems
- [ ] Add character selection UI
- [ ] Improve SharePlay message handling

### Future Enhancements
- [ ] More character types and costumes
- [ ] Recording and playback of magical moments
- [ ] Mini-games and challenges
- [ ] Customizable character appearances
- [ ] Achievement system

## 📝 Development Notes

### Current Implementation
- Characters are represented as colored cubes (placeholders)
- Animations use simple transforms (scale, rotation, translation)
- Effects use basic particle generation
- Face tracking uses ARKit's blend shapes

### Production Recommendations
1. **3D Models**: Use Reality Composer or Blender to create actual 3D princess characters
2. **Animations**: Create proper skeletal animations in Reality Composer
3. **Particles**: Use RealityKit's built-in particle system
4. **Audio**: Add spatial audio for immersive experience
5. **Testing**: Test extensively with children for UX feedback

## 🎨 Design Philosophy

- **Simple**: Easy for young children to understand
- **Magical**: Delightful interactions and effects
- **Safe**: No in-app purchases, ads, or data collection
- **Joyful**: Designed to create moments of wonder and connection

---

Built with ❤️ for Aria
