# Sound Effects Library

This directory contains sound effect files for character actions and magical effects.

## Required Sound Files

### Character Action Sounds
- `character_spawn.m4a` - Magical "poof" or chime when character appears
- `character_wave.m4a` - Light, friendly sound for waving gesture
- `character_dance.m4a` - Upbeat musical notes for dancing
- `character_twirl.m4a` - Whoosh with sparkle for spinning
- `character_jump.m4a` - Boing or bounce sound for jumping
- `character_sparkle.m4a` - Magical shimmer sound for sparkle action

### Magical Effect Sounds
- `effect_sparkles.m4a` - Twinkling sound for sparkle particles
- `effect_snow.m4a` - Gentle wind chimes for snow effect
- `effect_bubbles.m4a` - Bubbly pops for bubble effect

### Face Tracking Interaction Sounds
- `face_smile.m4a` - Happy chime when user smiles
- `face_eyebrows.m4a` - Surprise sound when eyebrows raise
- `face_mouth.m4a` - Playful note when mouth opens

## Technical Specifications

### Audio Format
- **Primary Format:** .m4a (AAC encoded)
- **Alternative:** .wav (uncompressed)
- **Sample Rate:** 44.1 kHz
- **Bit Depth:** 16-bit
- **Channels:** Mono (spatial audio handled by RealityKit)

### Duration Guidelines
- Character sounds: 0.5 - 2 seconds
- Effect sounds: 1 - 3 seconds (can loop)
- Face tracking sounds: 0.3 - 1 second

### Volume & Safety
- Normalized audio levels
- Child-safe volume (no sudden loud sounds)
- Pleasant, not annoying
- Appropriate for repeated playback

### File Size
- Target: < 100 KB per file
- Maximum: < 200 KB per file
- Total library: < 2 MB

## Sound Design Guidelines

### Style
- Magical and whimsical
- Child-friendly (ages 4-8)
- Clear and recognizable
- Non-startling, gentle

### Sources
1. **Create Custom:** GarageBand, Logic Pro, or similar DAW
2. **Licensed Libraries:** FreeSound.org, AudioJungle (properly licensed)
3. **AI Generation:** ElevenLabs, other AI sound tools

### Important
- Ensure all assets are properly licensed
- Document sources and licenses
- Include attribution if required
- No copyrighted material

## Current Status
**Status:** Placeholder - Awaiting sound creation

Sound playback will be handled by `AudioService.swift`.

## Integration
```swift
// Example usage:
AudioService.shared.playSound(.characterWave)
AudioService.shared.playEffect(.sparkles)
```

See `AudioService.swift` for implementation details.
