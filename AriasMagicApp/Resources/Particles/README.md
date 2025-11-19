# Particle Textures

This directory contains texture assets for RealityKit particle systems.

## Particle Texture Files

1. **sparkle_texture.png** - Golden star/sparkle texture
2. **snow_texture.png** - White snowflake texture
3. **bubble_texture.png** - Translucent bubble texture with reflections

## Technical Specifications

### Image Format
- **Format:** PNG with alpha transparency
- **Dimensions:** 128x128 or 256x256 pixels (power of 2)
- **Color Space:** sRGB
- **Bit Depth:** 8-bit per channel with alpha
- **File Size:** < 50 KB per texture

### Design Guidelines

#### Sparkle Texture
- **Shape:** Star or diamond shape
- **Color:** Warm golden yellow/white
- **Glow:** Soft glow/bloom effect
- **Alpha:** Gradient fade to transparent edges
- **Style:** Magical, twinkling appearance

#### Snow Texture
- **Shape:** Snowflake or crystal pattern
- **Color:** Pure white with subtle blue tint
- **Detail:** Delicate crystalline structure
- **Alpha:** Soft edges, organic feel
- **Style:** Winter, gentle, soft

#### Bubble Texture
- **Shape:** Circular with specular highlights
- **Color:** Cyan/rainbow iridescence
- **Detail:** Surface reflections and shine
- **Alpha:** Translucent center, clearer edges
- **Style:** Soap bubble, playful

## Optimization

### Texture Compression
- Use ASTC compression for iOS (smaller file size)
- Keep source PNG files for editing
- Test compressed versions in-app

### Performance Considerations
- Small texture size = better performance
- Power-of-2 dimensions (128, 256, 512)
- Mipmaps for smooth scaling
- Alpha channel for blending

## Creation Tools

- **Photoshop/Affinity Photo** - Professional texture creation
- **GIMP** - Free, open-source alternative
- **Procreate (iPad)** - Drawing custom textures
- **Texture Libraries** - Pre-made particle textures
- **AI Generation** - Midjourney, DALL-E for concepts

## Integration

Used by `EnhancedParticleEffects.swift`:

```swift
let texture = try? TextureResource.load(named: "sparkle_texture")
particleEmitter.mainTexture = texture
```

## Status

- [ ] sparkle_texture.png
- [ ] snow_texture.png
- [ ] bubble_texture.png

**Note:** Basic particle effects currently use generated geometry. These textures will enhance visual quality.
