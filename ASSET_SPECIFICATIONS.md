# Asset Specifications for Aria's Magic SharePlay App

**Document Version:** 1.0
**Last Updated:** 2025-11-17
**Owner:** 3D Assets & Animation Engineer

---

## Table of Contents

1. [Overview](#overview)
2. [3D Character Models](#3d-character-models)
3. [Character Animations](#character-animations)
4. [Sound Effects](#sound-effects)
5. [Particle Textures](#particle-textures)
6. [Preview Images](#preview-images)
7. [Performance Requirements](#performance-requirements)
8. [Quality Assurance](#quality-assurance)
9. [Asset Pipeline](#asset-pipeline)

---

## Overview

This document defines the technical specifications for all visual and audio assets in Aria's Magic SharePlay App. All assets must meet these requirements to ensure optimal performance, visual quality, and user experience.

**Target Audience:** Ages 4-8
**Target Devices:** iPhone 12 and newer, iPad Pro (2020+)
**iOS Version:** iOS 17.0+
**Performance Target:** 60 FPS with 10 characters + 3 effects active

---

## 3D Character Models

### Format Requirements

- **File Format:** USDZ (Universal Scene Description)
- **Naming Convention:** `[CharacterName].usdz`
  - Example: `Sparkle.usdz`, `Luna.usdz`
- **Location:** `AriasMagicApp/Resources/Characters/`

### Model Specifications

| Specification | Requirement | Notes |
|--------------|-------------|-------|
| Polygon Count | 5,000 - 15,000 triangles | Mobile-optimized, not desktop quality |
| Vertices | < 20,000 | Keep vertex count reasonable |
| Materials | 1 material per character | Use texture atlas |
| Texture Resolution | 1024x1024 or 2048x2048 | Single texture atlas |
| Texture Format | PNG or JPEG in USDZ | Will be converted to ASTC by iOS |
| File Size | < 5 MB per character | Compressed and optimized |
| Scale | 30cm height in AR | Consistent scale across all characters |
| Pivot Point | Ground level, centered | For proper placement |

### Character Rig Requirements

- **Skeleton Type:** Humanoid
- **Bone Count:** 20-40 bones (don't over-complicate)
- **Required Bones:**
  - Root
  - Hips
  - Spine/Chest
  - Head/Neck
  - Arms (shoulder, elbow, hand)
  - Legs (hip, knee, foot)
  - Optional: Fingers (simplified), accessories (crown, wand)

### Visual Style Guidelines

- **Style:** Cute, friendly, non-realistic (Disney/Pixar junior aesthetic)
- **Silhouettes:** Clear and distinctive
- **Colors:** Vibrant, age-appropriate
- **Proportions:** Slightly exaggerated (larger heads, bigger eyes)
- **Accessories:** Crown and wand for each character
- **Safety:** No sharp edges, no scary features

### The 5 Characters

#### 1. Sparkle the Princess (Pink)
- **Primary Color:** Pink/Magenta (#FF69B4)
- **Accessories:** Star crown, magic wand with star
- **Personality:** Joyful, energetic leader
- **Unique Features:** Sparkly dress, bright eyes

#### 2. Luna the Star Dancer (Purple)
- **Primary Color:** Purple/Lavender (#9370DB)
- **Accessories:** Star crown, moon wand
- **Personality:** Graceful, dreamy
- **Unique Features:** Celestial motifs, flowing dress

#### 3. Rosie the Dream Weaver (Red)
- **Primary Color:** Red/Pink (#DC143C)
- **Accessories:** Rose crown, dream catcher wand
- **Personality:** Creative, warm
- **Unique Features:** Rose decorations, warm glow

#### 4. Crystal the Gem Keeper (Cyan)
- **Primary Color:** Cyan/Blue (#00CED1)
- **Accessories:** Crystal tiara, gem wand
- **Personality:** Elegant, magical
- **Unique Features:** Ice/crystal effects, sparkles

#### 5. Willow the Wish Maker (Green)
- **Primary Color:** Green/Emerald (#2E8B57)
- **Accessories:** Leaf crown, wish star wand
- **Personality:** Gentle, hopeful
- **Unique Features:** Nature motifs, leaves

---

## Character Animations

### Animation Requirements

All characters must have 6 animations embedded in USDZ or as separate animation files.

### Animation Specifications

| Specification | Requirement |
|--------------|-------------|
| Frame Rate | 30 FPS (interpolated to 60 by engine) |
| Format | Embedded in USDZ or separate .usdz animation files |
| Compression | Apple's animation compression |
| Blending | Smooth transitions to/from idle state |

### The 6 Required Animations

#### 1. Idle (Looping)
- **Duration:** 2-3 seconds
- **Type:** Seamless loop
- **Content:**
  - Subtle breathing motion
  - Gentle weight shift
  - Occasional blinks
  - Slight sway or bounce
- **Purpose:** Default state when character is inactive

#### 2. Wave (One-Shot)
- **Duration:** 1.5 seconds
- **Type:** Play once, return to idle
- **Content:**
  - Arm raises to shoulder height
  - Hand waves side-to-side (2-3 waves)
  - Happy/friendly facial expression
  - Slight body lean into wave
- **Purpose:** Greeting gesture

#### 3. Dance (Looping)
- **Duration:** 2-3 seconds
- **Type:** Seamless loop
- **Content:**
  - Bouncy, rhythmic movement
  - Arms move expressively
  - Hips sway
  - Feet tap or shuffle
  - Joyful energy
- **Purpose:** Celebration, music response

#### 4. Twirl (One-Shot)
- **Duration:** 1.5 seconds
- **Type:** Play once, return to idle
- **Content:**
  - 360° spin on one axis
  - Arms extend outward
  - Dress/cape flows and billows
  - Graceful motion
- **Purpose:** Magical display

#### 5. Jump (One-Shot)
- **Duration:** 1.0 second
- **Type:** Play once, return to idle
- **Content:**
  - Anticipation (crouch down)
  - Jump (rise up)
  - Apex (brief hang time)
  - Landing (absorb impact)
  - Squash and stretch for appeal
- **Purpose:** Excited reaction

#### 6. Sparkle (One-Shot)
- **Duration:** 2.0 seconds
- **Type:** Play once, return to idle
- **Content:**
  - Magical pose (e.g., arms raised)
  - Wand flourish
  - Hold pose
  - Particles trigger during this animation
- **Purpose:** Trigger particle effects

### Animation Guidelines

- **Child-Friendly:** No aggressive or scary movements
- **Exaggerated:** Clear, readable motions (principle of animation)
- **Appeal:** Characters should be charming and delightful
- **Timing:** Use anticipation, action, and follow-through
- **Viewing Distance:** Animations visible from 1-3 meters away

---

## Sound Effects

### Audio Format

- **Primary Format:** .m4a (AAC encoded)
- **Alternative:** .wav (uncompressed)
- **Sample Rate:** 44.1 kHz
- **Bit Depth:** 16-bit
- **Channels:** Mono (spatial audio handled by RealityKit)
- **Bitrate:** 128 kbps for .m4a

### File Specifications

| Specification | Requirement |
|--------------|-------------|
| File Size | < 100 KB each (target), < 200 KB max |
| Duration | 0.3 - 3 seconds |
| Volume | Normalized, child-safe levels (-6 dB to -12 dB peak) |
| Clipping | None (0 dBFS max) |
| Silence | Trimmed from start and end |

### Required Sound Files

#### Character Actions (6 files)
1. **character_spawn.m4a**
   - Description: Magical "poof" or chime when character appears
   - Duration: 0.5 - 1 second
   - Style: Magical, whimsical entrance

2. **character_wave.m4a**
   - Description: Light, friendly sound for waving
   - Duration: 0.5 second
   - Style: Cheerful, welcoming

3. **character_dance.m4a**
   - Description: Upbeat musical notes or rhythm
   - Duration: 2 seconds (can loop)
   - Style: Playful, energetic

4. **character_twirl.m4a**
   - Description: Whoosh with sparkle/chime
   - Duration: 1 second
   - Style: Graceful, magical

5. **character_jump.m4a**
   - Description: Boing or bounce sound
   - Duration: 0.5 second
   - Style: Bouncy, fun

6. **character_sparkle.m4a**
   - Description: Magical shimmer/chime
   - Duration: 1.5 seconds
   - Style: Enchanting, glittery

#### Magical Effects (3 files)
7. **effect_sparkles.m4a**
   - Description: Twinkling, shimmering sound
   - Duration: 2 seconds
   - Style: Bright, glittery

8. **effect_snow.m4a**
   - Description: Gentle wind chimes, soft ambience
   - Duration: 2-3 seconds
   - Style: Calm, winter-like

9. **effect_bubbles.m4a**
   - Description: Bubbly pops and gurgles
   - Duration: 2 seconds
   - Style: Playful, light

#### Face Tracking (3 files)
10. **face_smile.m4a**
    - Description: Happy chime when user smiles
    - Duration: 0.3 second
    - Style: Joyful, uplifting

11. **face_eyebrows.m4a**
    - Description: Surprise sound when eyebrows raise
    - Duration: 0.3 second
    - Style: Curious, surprised

12. **face_mouth.m4a**
    - Description: Playful note when mouth opens
    - Duration: 0.3 second
    - Style: Silly, fun

### Sound Design Guidelines

- **Pleasant:** Not annoying with repeated playback
- **Child-Safe:** No sudden loud sounds, no harsh frequencies
- **Magical Theme:** Whimsical, fantasy-appropriate
- **Clear:** Easy to distinguish different sounds
- **Frequency Range:** 200 Hz - 12 kHz (avoid extreme highs/lows)

### Licensing

- Must be royalty-free or properly licensed
- Commercial use rights required
- Attribution documented if needed
- No copyrighted sound effects

---

## Particle Textures

### Format Requirements

- **File Format:** PNG with alpha channel
- **Resolution:** 128x128 or 256x256 pixels
- **Color Space:** sRGB
- **Bit Depth:** 8-bit RGBA
- **Location:** `AriasMagicApp/Resources/Particles/`

### Required Textures

#### 1. sparkle_texture.png
- **Purpose:** Sparkle/star particles
- **Design:** Golden sparkle or 4-point star
- **Color:** Yellow/Gold (#FFD700) with white center
- **Alpha:** Soft radial gradient (solid center, fade to transparent)

#### 2. snow_texture.png
- **Purpose:** Snowflake particles
- **Design:** 6-point snowflake or simple asterisk
- **Color:** White with slight blue tint (#F0F8FF)
- **Alpha:** Delicate, slightly transparent

#### 3. bubble_texture.png
- **Purpose:** Bubble particles
- **Design:** Circular bubble with specular highlight
- **Color:** Cyan/white gradient (#87CEEB to white)
- **Alpha:** Transparent with highlight spot

### Texture Guidelines

- **Soft Edges:** Use feathering and anti-aliasing
- **Power of 2:** Dimensions should be 128 or 256 (for GPU optimization)
- **File Size:** < 50 KB per texture (use PNG compression)
- **Centered:** Design centered in square canvas
- **Tileable:** Optional, but can be useful for some effects

---

## Preview Images

### Format Requirements

- **File Format:** PNG with transparency
- **Resolution:** 512x512 pixels
- **Color Space:** sRGB
- **Bit Depth:** 8-bit RGBA
- **Location:** `AriasMagicApp/Resources/Previews/`

### Required Images

1. `Sparkle_preview.png`
2. `Luna_preview.png`
3. `Rosie_preview.png`
4. `Crystal_preview.png`
5. `Willow_preview.png`

### Image Specifications

- **Background:** Transparent
- **View Angle:** 3/4 view (slightly to side and above)
- **Lighting:** Well-lit, soft shadows, 3-point lighting ideal
- **Expression:** Happy or neutral, friendly
- **Framing:** Consistent across all characters
  - Option A: Full body
  - Option B: Head to mid-torso
- **File Size:** < 200 KB per image

### Creation Methods

1. **Render from 3D Software**
   - Best quality and consistency
   - Use same lighting setup for all

2. **Screenshot from AR App**
   - Place character in well-lit environment
   - Use consistent background
   - Remove background in image editor

3. **2D Illustration**
   - Must match 3D model appearance
   - Consistent art style

---

## Performance Requirements

### Overall Performance Targets

| Metric | Requirement |
|--------|-------------|
| Frame Rate | 60 FPS minimum |
| Memory Usage | < 200 MB for all assets |
| Load Time | < 2 seconds for all characters |
| Character Limit | Support 10 simultaneous characters |
| Effect Limit | Support 3 simultaneous particle effects |

### Per-Asset Budgets

#### 3D Characters
- **Polygon Budget:** 15,000 triangles max per character
- **Texture Memory:** ~6 MB per character (2048x2048 compressed)
- **Total Characters:** 5 models cached = ~30 MB
- **Animation Memory:** ~2 MB per character

#### Particle Effects
- **Particle Count:**
  - Sparkles: 50-100 particles
  - Snow: 100-200 particles
  - Bubbles: 15-30 particles
- **Texture Memory:** ~300 KB per texture
- **Emission Rate:** Tuned to maintain 60 FPS

#### Sound Effects
- **Total Audio Memory:** ~2 MB for all sounds
- **Simultaneous Sounds:** Support 5+ concurrent playback

### Optimization Techniques

1. **Texture Compression:** Use ASTC format (automatic on iOS)
2. **LOD (Level of Detail):** Consider if needed for distant characters
3. **Occlusion Culling:** Characters off-screen don't render
4. **Particle Pooling:** Reuse particle entities
5. **Audio Caching:** Preload all sounds at launch

---

## Quality Assurance

### Character Model Checklist

- [ ] Polygon count within limits (5,000-15,000)
- [ ] Single material, single texture atlas
- [ ] Proper UV mapping, no stretching
- [ ] File size < 5 MB
- [ ] Imports correctly into Reality Composer Pro
- [ ] Displays correctly in iOS Simulator/Device
- [ ] Collision detection works
- [ ] Scale is appropriate (~30cm in AR)

### Animation Checklist

- [ ] All 6 animations present
- [ ] Smooth transitions to/from idle
- [ ] No popping or glitching
- [ ] Timing feels good (not too fast/slow)
- [ ] Child-friendly content
- [ ] Loops are seamless (for idle, dance)
- [ ] One-shots return cleanly to idle

### Sound Effect Checklist

- [ ] Correct format (.m4a or .wav)
- [ ] Correct sample rate (44.1 kHz)
- [ ] File size within limits (< 100 KB target)
- [ ] No clipping or distortion
- [ ] Normalized volume
- [ ] Silence trimmed
- [ ] Pleasant with repeated playback
- [ ] Properly licensed

### Testing Procedures

1. **Visual Inspection**
   - Load in Reality Composer Pro
   - Check in AR Quick Look
   - Test in actual app

2. **Performance Testing**
   - Use Xcode Instruments (GPU, Memory)
   - Test with 10 characters spawned
   - Monitor FPS with effects active
   - Check memory usage

3. **User Testing**
   - Test with target age group (4-8)
   - Verify characters are appealing
   - Ensure sounds are pleasant
   - Confirm animations are clear

---

## Asset Pipeline

### Workflow Overview

```
1. Concept/Design → 2. Modeling → 3. Texturing → 4. Rigging → 5. Animation
    ↓
6. Export USDZ → 7. Test → 8. Optimize → 9. Integrate → 10. QA
```

### Recommended Tools

#### 3D Modeling & Animation
- **Reality Composer Pro** (Free with Xcode)
  - Native USDZ support
  - Optimized for iOS
  - Recommended for this project

- **Blender** (Free, open-source)
  - Powerful modeling and animation
  - USDZ export via plugins
  - More learning curve

- **Maya/3DS Max** (Commercial)
  - Professional-grade
  - USDZ export available
  - Expensive

#### Sound Design
- **GarageBand** (Free on Mac/iOS)
  - Easy to use
  - Good sound library

- **Logic Pro** (Mac, $200)
  - Professional audio production

- **Audacity** (Free, cross-platform)
  - Audio editing and effects

#### Texture Creation
- **Photoshop/GIMP**
  - Image editing
  - Texture creation

- **Substance Painter** (Commercial)
  - Professional texturing

### Version Control

- Store source files (.blend, .psd, etc.) in separate repository
- Only commit final USDZ files to project
- Use Git LFS for large binary files
- Document asset versions in commit messages

### Asset Handoff

When delivering assets to iOS Core Engineer:

1. **Notify via daily log or pull request**
2. **Include:**
   - Asset file(s)
   - Brief description of asset
   - Any special notes (e.g., "requires XYZ")
   - Test results (performance, visual)
3. **Ensure:**
   - Files are in correct directories
   - Naming conventions followed
   - README files updated if needed

---

## Appendix: Quick Reference

### File Naming Convention

| Asset Type | Pattern | Example |
|-----------|---------|---------|
| Character Model | `[Name].usdz` | `Sparkle.usdz` |
| Character Preview | `[Name]_preview.png` | `Sparkle_preview.png` |
| Character Sound | `character_[action].m4a` | `character_wave.m4a` |
| Effect Sound | `effect_[name].m4a` | `effect_sparkles.m4a` |
| Face Sound | `face_[trigger].m4a` | `face_smile.m4a` |
| Particle Texture | `[name]_texture.png` | `sparkle_texture.png` |

### Directory Structure

```
AriasMagicApp/Resources/
├── Characters/
│   ├── Sparkle.usdz
│   ├── Luna.usdz
│   ├── Rosie.usdz
│   ├── Crystal.usdz
│   └── Willow.usdz
├── Sounds/
│   ├── character_spawn.m4a
│   ├── character_wave.m4a
│   ├── (... 10 more sound files)
│   └── face_mouth.m4a
├── Previews/
│   ├── Sparkle_preview.png
│   ├── Luna_preview.png
│   ├── Rosie_preview.png
│   ├── Crystal_preview.png
│   └── Willow_preview.png
└── Particles/
    ├── sparkle_texture.png
    ├── snow_texture.png
    └── bubble_texture.png
```

---

**Questions?** Post to `AGENT_PROMPTS/questions.md` or contact the Project Coordinator.

**Updates:** This document will be updated as requirements evolve. Check version number and last updated date.
