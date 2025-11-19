# Character Preview Images

This directory contains preview/thumbnail images for the character picker UI.

## Preview Files Required

1. **Sparkle_preview.png** - Sparkle the Princess
2. **Luna_preview.png** - Luna the Star Dancer
3. **Rosie_preview.png** - Rosie the Dream Weaver
4. **Crystal_preview.png** - Crystal the Gem Keeper
5. **Willow_preview.png** - Willow the Wish Maker

## Technical Specifications

### Image Format
- **Format:** PNG with alpha transparency
- **Dimensions:** 512x512 pixels
- **Color Space:** sRGB
- **Bit Depth:** 8-bit per channel (24-bit RGB + 8-bit alpha)
- **File Size:** < 500 KB per image (target: 200-300 KB)

### Visual Guidelines

#### Framing & Composition
- **View Angle:** 3/4 view (slight angle, not straight-on)
- **Character Position:** Centered in frame
- **Cropping:** Head to knees or full body
- **Padding:** ~10% margin around character

#### Lighting & Rendering
- **Lighting:** Soft, even lighting (no harsh shadows)
- **Background:** Transparent (PNG alpha channel)
- **Expression:** Happy/neutral, welcoming expression
- **Pose:** Idle or signature pose for character

#### Style Consistency
- **Camera Angle:** Same angle for all 5 characters
- **Scale:** Characters should be similar size in frame
- **Lighting Setup:** Identical lighting for consistency
- **Quality:** High-quality render, anti-aliased edges

## Creation Methods

### Method 1: Reality Composer Pro Render
1. Load character USDZ in Reality Composer Pro
2. Set up 3/4 view camera angle
3. Position soft lighting (key + fill)
4. Render at 1024x1024 or higher
5. Export as PNG
6. Edit in Preview/Photoshop to remove background
7. Resize to 512x512 with transparency

### Method 2: Blender Render
1. Import character model in Blender
2. Set up EEVEE or Cycles renderer
3. Configure camera and lighting
4. Enable transparent background in render settings
5. Render at 1024x1024
6. Save as PNG with alpha
7. Resize to 512x512

### Method 3: In-App Screenshot
1. Launch app on device
2. Spawn character in AR
3. Take screenshot with clean background
4. Edit to isolate character
5. Add transparent background
6. Resize to 512x512

## Post-Processing Checklist

- [ ] Background removed (transparent PNG)
- [ ] Clean edges (no artifacts or halos)
- [ ] Centered and properly framed
- [ ] Correct dimensions (512x512)
- [ ] Optimized file size
- [ ] Matches style of other previews
- [ ] Character clearly recognizable

## Usage in App

Preview images are used by `CharacterPickerView.swift`:

```swift
Image("Sparkle_preview")
    .resizable()
    .scaledToFit()
    .frame(width: 80, height: 80)
```

## Naming Convention

- Format: `{CharacterName}_preview.png`
- Use PascalCase for character name
- Lowercase for "preview"
- PNG extension

## Status

- [ ] Sparkle_preview.png
- [ ] Luna_preview.png
- [ ] Rosie_preview.png
- [ ] Crystal_preview.png
- [ ] Willow_preview.png

**Dependencies:** Requires 3D character models to be completed first.
