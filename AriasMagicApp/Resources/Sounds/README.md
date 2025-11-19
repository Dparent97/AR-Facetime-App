# Sound Effects

This directory contains audio files for character actions and magic effects.

## Sound Files Required

### Character Action Sounds (6 files)
1. **character_spawn.m4a** - Magical "poof" or chime when character appears
2. **character_wave.m4a** - Light, friendly sound for waving
3. **character_dance.m4a** - Upbeat musical notes for dancing
4. **character_twirl.m4a** - Whoosh with sparkle for twirling
5. **character_jump.m4a** - Boing or bounce sound
6. **character_sparkle.m4a** - Magical shimmer/chime sound

### Magic Effect Sounds (3 files)
7. **effect_sparkles.m4a** - Twinkling sparkle sound
8. **effect_snow.m4a** - Gentle wind chimes or soft winter sound
9. **effect_bubbles.m4a** - Bubbly pops and water sounds

### Face Tracking Sounds (3 files)
10. **face_smile.m4a** - Happy chime when user smiles
11. **face_eyebrows.m4a** - Surprise sound for eyebrow raise
12. **face_mouth.m4a** - Playful note for mouth open

**Total:** 12 sound files

## Technical Specifications

### Audio Format
- **Primary Format:** .m4a (AAC compressed)
- **Alternative:** .wav (uncompressed, for higher quality)
- **Sample Rate:** 44.1 kHz
- **Bit Depth:** 16-bit
- **Channels:** Mono (spatial audio handled by RealityKit engine)
- **Duration:** 0.5 - 2 seconds per sound
- **File Size:** < 100 KB each (target: 50-75 KB)

### Quality Guidelines
- **Volume:** Normalized to consistent levels
- **Child-Safe:** No harsh, loud, or startling sounds
- **Clarity:** Clear and distinct from background
- **Repetition-Friendly:** Pleasant when heard multiple times
- **Spatial Audio:** Compatible with RealityKit's 3D audio

## Sound Design Guidelines

### Character Sounds
- **Magical Theme:** Whimsical, fantasy-inspired
- **Age-Appropriate:** Delightful for children 4-8 years
- **Personality Match:** Each sound should match the action
- **Energy Level:** Upbeat but not overwhelming

### Effect Sounds
- **Atmospheric:** Enhance the magical environment
- **Layerable:** Work well when multiple effects play simultaneously
- **Non-Intrusive:** Complement, don't dominate the experience

### Face Tracking Sounds
- **Rewarding:** Positive reinforcement for expressions
- **Subtle:** Don't distract from AR experience
- **Responsive:** Quick attack, no long tails

## Sources & Tools

### Option 1: Create Original
- **GarageBand** (iOS/Mac) - Free, beginner-friendly
- **Logic Pro** (Mac) - Professional audio production
- **Audacity** (Free) - Open-source audio editor

### Option 2: Licensed Libraries
- **FreeSound.org** - Free, Creative Commons sounds
- **AudioJungle** - Commercial sound effects library
- **Epidemic Sound** - Subscription-based library
- **Zapsplat** - Free and premium sound effects

### Option 3: AI Generation
- **ElevenLabs** - AI-generated sound effects
- **Soundraw** - AI music and sound generation

## Audio Processing Checklist

For each sound file:
- [ ] Trim silence from beginning and end
- [ ] Normalize volume to -3dB peak
- [ ] Apply gentle fade-in/fade-out (10-50ms)
- [ ] Remove background noise/hiss
- [ ] Convert to mono channel
- [ ] Compress to m4a format
- [ ] Test playback in app
- [ ] Verify file size < 100 KB

## Integration

Sounds are played via `AudioService.swift`:

```swift
AudioService.shared.playSound(.characterWave)
AudioService.shared.playSound(.effectSparkles, at: characterPosition)
```

## Licensing Notes

- Ensure all sounds are properly licensed for commercial use
- Document source and license for each file
- Include attribution in app credits if required
- Avoid copyrighted music or sounds

## Status

- [ ] character_spawn.m4a
- [ ] character_wave.m4a
- [ ] character_dance.m4a
- [ ] character_twirl.m4a
- [ ] character_jump.m4a
- [ ] character_sparkle.m4a
- [ ] effect_sparkles.m4a
- [ ] effect_snow.m4a
- [ ] effect_bubbles.m4a
- [ ] face_smile.m4a
- [ ] face_eyebrows.m4a
- [ ] face_mouth.m4a

**Note:** Sound integration requires `AudioService.swift` implementation.
