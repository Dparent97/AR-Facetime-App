# Character Assets

This directory contains 3D character models in USDZ format for RealityKit.

## Character Files

### Required Characters (5 total)
1. **Sparkle.usdz** - Sparkle the Princess (Pink/Magenta)
2. **Luna.usdz** - Luna the Star Dancer (Purple/Lavender)
3. **Rosie.usdz** - Rosie the Dream Weaver (Red/Pink with gold)
4. **Crystal.usdz** - Crystal the Gem Keeper (Cyan/Blue)
5. **Willow.usdz** - Willow the Wish Maker (Green/Emerald)

## Technical Specifications

### Model Requirements
- **Format:** USDZ (Universal Scene Description)
- **Polygon Count:** 5,000-15,000 triangles per character
- **Textures:** 1024x1024 or 2048x2048 (single texture atlas)
- **File Size:** < 5 MB per character
- **Rig:** Humanoid skeleton with standard bone hierarchy
- **Height:** ~30cm when spawned in AR space

### Animation Requirements
Each character USDZ must include 6 embedded animations:

1. **idle** (loop, 2-3 sec) - Subtle breathing, slight sway
2. **wave** (one-shot, 1.5 sec) - Arm raise and wave
3. **dance** (loop, 2-3 sec) - Bouncy, energetic movement
4. **twirl** (one-shot, 1.5 sec) - 360° spin
5. **jump** (one-shot, 1 sec) - Jump with squash/stretch
6. **sparkle** (one-shot, 2 sec) - Magical pose with wand flourish

### Optimization Guidelines
- Use single material/texture atlas per character
- Compress textures using ASTC format
- Bake animations into USDZ file
- Remove unused vertices/bones
- Test performance at 60 FPS

## Character Design Guidelines

### Style Direction
- **Target Audience:** Children ages 4-8
- **Art Style:** Cute, friendly, Disney/Pixar junior aesthetic
- **Personality:** Each character should have distinct visual personality
- **Safety:** No scary, aggressive, or inappropriate elements

### Color Palettes
- **Sparkle:** Pink, magenta, warm tones with sparkles
- **Luna:** Purple, lavender, silver stars, night sky theme
- **Rosie:** Red, pink, gold accents, dreams theme
- **Crystal:** Cyan, blue, white, ice/crystal theme
- **Willow:** Green, emerald, earth tones, nature theme

## Tools & Workflow

### Recommended Tools
1. **Reality Composer Pro** (free with Xcode) - Primary workflow
2. **Blender** + Reality Composer Pro - Advanced modeling
3. **Adobe Substance Painter** - Texturing (optional)

### Export Checklist
- [ ] Model is properly rigged with humanoid skeleton
- [ ] All 6 animations are embedded in USDZ
- [ ] Textures are optimized and compressed
- [ ] File size is under 5 MB
- [ ] Model tested in Reality Composer Pro
- [ ] Character conforms to AnimatableCharacter protocol
- [ ] Performance tested on target device

## Integration

Characters are loaded via `AssetLoader.swift`:

```swift
let entity = await AssetLoader.shared.loadCharacter(type: .sparkleThePrincess)
```

Animations are triggered via:

```swift
character.performAction(.wave) {
    print("Wave animation completed")
}
```

## Status

- [ ] Sparkle.usdz
- [ ] Luna.usdz
- [ ] Rosie.usdz
- [ ] Crystal.usdz
- [ ] Willow.usdz

**Note:** Currently using colored cube placeholders in `Character.swift`. Replace with actual USDZ models.
