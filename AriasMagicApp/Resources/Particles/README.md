# Particle Effect Textures

This directory contains texture files for enhanced particle effects.

## Required Texture Files

### 1. sparkle_texture.png
- **Purpose:** Sparkle/star particles
- **Style:** Golden sparkle or star shape
- **Features:** Soft glow, radial gradient

### 2. snow_texture.png
- **Purpose:** Snowflake particles
- **Style:** White snowflake design
- **Features:** Delicate crystalline pattern

### 3. bubble_texture.png
- **Purpose:** Bubble particles
- **Style:** Translucent bubble with highlight
- **Features:** Spherical gradient, specular highlight

## Technical Specifications

### Image Format
- **Format:** PNG with alpha channel
- **Resolution:** 128x128 or 256x256 pixels
- **Color Space:** sRGB
- **Bit Depth:** 8-bit RGBA

### Design Guidelines
- **Alpha Channel:** Soft falloff from center to edges
- **Colors:**
  - Sparkles: Golden/yellow with white highlights
  - Snow: White/light blue
  - Bubbles: Cyan/white with transparency
- **Style:** Soft, glowing, magical

### Optimization
- Use appropriate resolution (don't over-size)
- Compress without quality loss
- Target file size: < 50 KB per texture

## Particle System Usage

These textures will be used in `EnhancedParticleEffects.swift`:

```swift
// Example:
var material = UnlitMaterial()
material.color = .init(tint: .white, texture: .init(sparkleTexture))
material.blending = .transparent(opacity: .init(floatLiteral: 0.8))
```

## Creating Textures

### Option 1: Photoshop/GIMP
1. Create square canvas (256x256)
2. Paint particle design on transparent background
3. Use soft brushes and gradients
4. Add glow effects
5. Export as PNG with transparency

### Option 2: Procedural (Blender, Substance)
1. Create procedural texture
2. Render to 256x256 image
3. Export with alpha channel

### Option 3: Stock Assets
- Use licensed particle texture packs
- Modify to match style
- Ensure commercial use rights

## Current Status
**Status:** Placeholder - Using programmatic particles

Currently, particle effects use simple colored spheres.
Enhanced textures will significantly improve visual quality.

## Integration
Textures are loaded via `AssetLoader.swift` and applied to particle systems in `EnhancedParticleEffects.swift`.
