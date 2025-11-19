# 3D Character Models

This directory contains the USDZ 3D character models for Aria's Magic SharePlay App.

## Required Characters

### 1. Sparkle.usdz - Sparkle the Princess (Pink)
- **Theme:** Joyful and energetic
- **Color:** Pink/magenta tones
- **Accessories:** Crown, wand with star
- **Personality:** Energetic leader

### 2. Luna.usdz - Luna the Star Dancer (Purple)
- **Theme:** Celestial, night sky
- **Color:** Purple/lavender with silver stars
- **Accessories:** Star crown, moon wand
- **Personality:** Graceful, dreamy

### 3. Rosie.usdz - Rosie the Dream Weaver (Red)
- **Theme:** Dreams, imagination
- **Color:** Red/pink with gold accents
- **Accessories:** Rose crown, dream catcher wand
- **Personality:** Creative, warm

### 4. Crystal.usdz - Crystal the Gem Keeper (Cyan)
- **Theme:** Ice/crystals
- **Color:** Cyan/blue with sparkles
- **Accessories:** Crystal tiara, gem wand
- **Personality:** Elegant, magical

### 5. Willow.usdz - Willow the Wish Maker (Green)
- **Theme:** Nature, wishes
- **Color:** Green/emerald with nature motifs
- **Accessories:** Leaf crown, wish star wand
- **Personality:** Gentle, hopeful

## Technical Specifications

### Model Requirements
- **Format:** USDZ (Universal Scene Description)
- **Polygon Count:** 5,000-15,000 triangles per character
- **Texture Resolution:** 1024x1024 or 2048x2048 (single texture atlas)
- **File Size:** < 5 MB per character
- **Target Scale:** ~30cm height when spawned in AR

### Rig Requirements
- Humanoid skeleton structure
- Compatible with standard animation retargeting
- Support for all 6 action animations

### Required Animations (embedded or separate)
1. **Idle** - Looping (2-3 seconds)
2. **Wave** - One-shot (1.5 seconds)
3. **Dance** - Looping (2-3 seconds)
4. **Twirl** - One-shot (1.5 seconds)
5. **Jump** - One-shot (1 second)
6. **Sparkle** - One-shot (2 seconds)

## Animation Standards
- 30 FPS (interpolated to 60 by engine)
- Smooth transitions to/from idle
- Child-friendly movements (ages 4-8)
- Exaggerated for clarity and appeal

## Performance Target
- 60 FPS with 10 characters active
- < 200 MB total memory usage
- Smooth on iPhone 12 and newer

## Current Status
**Status:** Placeholder - Awaiting 3D model creation

Currently using colored cube placeholders. See `Character.swift` for integration points.

## Integration
Models are loaded via `AssetLoader.swift` and integrated into the `Character` class.

See `ASSET_SPECIFICATIONS.md` for detailed production guidelines.
