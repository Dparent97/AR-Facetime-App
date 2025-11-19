# Asset Specifications & Requirements
**Aria's Magic SharePlay App - 3D Assets & Animation**

## Overview

This document provides comprehensive specifications for all 3D assets, animations, sound effects, and visual resources required for the app.

---

## 📦 Asset Inventory

### Characters (5 USDZ models)
- [ ] Sparkle.usdz - Sparkle the Princess
- [ ] Luna.usdz - Luna the Star Dancer
- [ ] Rosie.usdz - Rosie the Dream Weaver
- [ ] Crystal.usdz - Crystal the Gem Keeper
- [ ] Willow.usdz - Willow the Wish Maker

### Sounds (12 audio files)
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

### Preview Images (5 PNG files)
- [ ] Sparkle_preview.png
- [ ] Luna_preview.png
- [ ] Rosie_preview.png
- [ ] Crystal_preview.png
- [ ] Willow_preview.png

### Particle Textures (3 PNG files)
- [ ] sparkle_texture.png
- [ ] snow_texture.png
- [ ] bubble_texture.png

---

## 🎨 Character Design Specifications

### Technical Requirements

| Specification | Requirement | Notes |
|--------------|-------------|-------|
| **Format** | USDZ (Universal Scene Description) | iOS/RealityKit compatible |
| **Polygon Count** | 5,000 - 15,000 triangles | Mobile-optimized |
| **Texture Resolution** | 1024x1024 or 2048x2048 | Single texture atlas |
| **File Size** | < 5 MB per character | Performance target |
| **Rig Type** | Humanoid skeleton | Standard bone hierarchy |
| **AR Height** | ~30cm (0.3m) | When spawned in AR |
| **Animations** | 6 embedded animations | See below |
| **Materials** | 1 material per character | Optimized draw calls |
| **Texture Format** | ASTC compressed | iOS GPU format |

### Character Descriptions

#### 1. Sparkle the Princess (Pink)
- **Primary Color:** Pink/Magenta with warm tones
- **Theme:** Joy, energy, sparkles
- **Accessories:**
  - Crown (tiara style)
  - Star-topped wand
  - Flowing dress/cape
- **Personality:** Joyful, energetic, friendly
- **Special Features:** Sparkle effects on wand

#### 2. Luna the Star Dancer (Purple)
- **Primary Color:** Purple/Lavender with silver accents
- **Theme:** Celestial, night sky, stars
- **Accessories:**
  - Star crown
  - Moon-shaped wand
  - Flowing cosmic-themed dress
- **Personality:** Graceful, dreamy, elegant
- **Special Features:** Star patterns, ethereal glow

#### 3. Rosie the Dream Weaver (Red)
- **Primary Color:** Red/Pink with gold accents
- **Theme:** Dreams, imagination, warmth
- **Accessories:**
  - Rose crown
  - Dream catcher wand
  - Soft flowing dress
- **Personality:** Creative, warm, nurturing
- **Special Features:** Floral elements, soft glow

#### 4. Crystal the Gem Keeper (Cyan)
- **Primary Color:** Cyan/Blue with white/silver
- **Theme:** Ice, crystals, winter magic
- **Accessories:**
  - Crystal tiara
  - Gem-topped wand
  - Ice-inspired dress
- **Personality:** Elegant, magical, cool
- **Special Features:** Crystalline details, icy shimmer

#### 5. Willow the Wish Maker (Green)
- **Primary Color:** Green/Emerald with earth tones
- **Theme:** Nature, wishes, growth
- **Accessories:**
  - Leaf crown
  - Wish star wand
  - Nature-themed dress
- **Personality:** Gentle, hopeful, kind
- **Special Features:** Natural elements, soft earthy glow

### Animation Requirements

All 6 animations must be embedded in each USDZ file:

| Animation | Type | Duration | Details |
|-----------|------|----------|---------|
| **idle** | Loop | 2-3 sec | Subtle breathing, weight shift, gentle sway |
| **wave** | One-shot | 1.5 sec | Arm raises, waves, returns to idle |
| **dance** | Loop | 2.5 sec | Bouncy, energetic, twirls, child-appropriate |
| **twirl** | One-shot | 1.5 sec | 360° spin, arms out, dress flows |
| **jump** | One-shot | 1.0 sec | Anticipation → jump → land, squash/stretch |
| **sparkle** | One-shot | 2.0 sec | Magical pose, wand flourish, triggers particles |

**Animation Standards:**
- 30 FPS (interpolated to 60 by engine)
- Smooth transitions to/from idle
- Exaggerated for clarity and appeal
- Child-friendly (no aggressive movements)
- Compatible with AnimatableCharacter protocol

---

## 🔊 Sound Effect Specifications

### Technical Requirements

| Specification | Requirement |
|--------------|-------------|
| **Format** | .m4a (AAC) or .wav |
| **Sample Rate** | 44.1 kHz |
| **Bit Depth** | 16-bit |
| **Channels** | Mono |
| **Duration** | 0.5 - 2 seconds |
| **File Size** | < 100 KB (target: 50-75 KB) |
| **Volume** | Normalized, child-safe levels |

### Sound Design Guidelines

#### Character Sounds
- **Magical Theme:** Whimsical, fantasy-inspired
- **Age-Appropriate:** Delightful for ages 4-8
- **Energy:** Upbeat but not overwhelming
- **Repetition-Friendly:** Pleasant when repeated

#### Effect Sounds
- **Atmospheric:** Enhance magical environment
- **Layerable:** Work well simultaneously
- **Non-Intrusive:** Complement, don't dominate

#### Face Tracking Sounds
- **Rewarding:** Positive reinforcement
- **Subtle:** Don't distract from AR
- **Responsive:** Quick attack, no long tails

### Sound Descriptions

| Sound File | Description | Reference |
|------------|-------------|-----------|
| character_spawn.m4a | Magical "poof" chime | Tinkerbell sparkle |
| character_wave.m4a | Light friendly sound | Gentle chime |
| character_dance.m4a | Upbeat musical notes | Playful melody |
| character_twirl.m4a | Whoosh + sparkle | Wind + magic |
| character_jump.m4a | Boing/bounce | Cartoon spring |
| character_sparkle.m4a | Magical shimmer | Glittery chime |
| effect_sparkles.m4a | Twinkling | Star twinkles |
| effect_snow.m4a | Gentle wind chimes | Winter ambience |
| effect_bubbles.m4a | Bubbly pops | Water bubbles |
| face_smile.m4a | Happy chime | Positive feedback |
| face_eyebrows.m4a | Surprise sound | Curious tone |
| face_mouth.m4a | Playful note | Silly sound |

---

## 🖼️ Preview Image Specifications

### Technical Requirements

| Specification | Requirement |
|--------------|-------------|
| **Format** | PNG with alpha transparency |
| **Dimensions** | 512x512 pixels |
| **Color Space** | sRGB |
| **Bit Depth** | 8-bit per channel + alpha |
| **File Size** | < 500 KB (target: 200-300 KB) |

### Visual Guidelines

- **View Angle:** 3/4 view (slight angle)
- **Character Position:** Centered
- **Cropping:** Head to knees or full body
- **Padding:** ~10% margin
- **Lighting:** Soft, even (no harsh shadows)
- **Background:** Transparent
- **Expression:** Happy/neutral, welcoming
- **Consistency:** Same angle/scale for all 5

---

## ✨ Particle Texture Specifications

### Technical Requirements

| Specification | Requirement |
|--------------|-------------|
| **Format** | PNG with alpha transparency |
| **Dimensions** | 128x128 or 256x256 (power of 2) |
| **Color Space** | sRGB |
| **File Size** | < 50 KB |
| **Compression** | ASTC for iOS |

### Texture Descriptions

#### sparkle_texture.png
- **Shape:** Star or diamond
- **Color:** Golden yellow/white
- **Effect:** Soft glow, gradient fade
- **Usage:** Magical sparkle particles

#### snow_texture.png
- **Shape:** Snowflake crystal
- **Color:** Pure white, subtle blue tint
- **Effect:** Delicate, soft edges
- **Usage:** Winter snow particles

#### bubble_texture.png
- **Shape:** Circle with highlights
- **Color:** Cyan with rainbow iridescence
- **Effect:** Translucent, reflective
- **Usage:** Floating bubble particles

---

## 🎯 Performance Targets

### Per-Character Performance
- Polygon count: < 15,000 triangles
- Single texture atlas (no extra materials)
- File size: < 5 MB
- Compressed textures (ASTC format)

### Overall Performance
- **Frame Rate:** 60 FPS sustained
- **Memory:** < 200 MB total asset memory
- **Concurrent:** 10 characters + 3 effects simultaneously
- **Target Device:** iPhone 12 and newer

### Optimization Checklist
- [ ] LOD (Level of Detail) models if needed
- [ ] Compressed textures (ASTC)
- [ ] Baked animations into USDZ
- [ ] Removed unused keyframes/bones
- [ ] Optimized bone hierarchy
- [ ] Particle count tuned
- [ ] Auto-disable particles when off-screen

---

## 🛠️ Tools & Workflow

### Recommended Tools

#### 3D Modeling & Animation
- **Reality Composer Pro** (Free with Xcode) - Primary
- **Blender** (Free) - 3D modeling
- **Maya/3DS Max** (Commercial) - Professional workflow

#### Texturing
- **Substance Painter** - Texture creation
- **Photoshop/GIMP** - Texture editing

#### Audio
- **GarageBand** (Free) - Sound creation
- **Logic Pro** - Professional audio
- **Audacity** (Free) - Audio editing

#### Asset Sources
- **Sketchfab** - Licensed 3D models
- **FreeSound.org** - Free sound effects
- **AudioJungle** - Commercial sound library

---

## ✅ Quality Assurance Checklist

### Per Character
- [ ] Model loads in Reality Composer Pro
- [ ] All 6 animations play correctly
- [ ] Textures display properly
- [ ] File size under 5 MB
- [ ] Performance at 60 FPS on test device
- [ ] Conforms to AnimatableCharacter protocol
- [ ] Preview image created

### Per Sound
- [ ] Plays without distortion
- [ ] Volume normalized
- [ ] File size under 100 KB
- [ ] No background noise
- [ ] Pleasant when repeated
- [ ] Integrates with AudioService

### Overall
- [ ] All 5 characters stylistically consistent
- [ ] Color palette distinct for each character
- [ ] All assets properly named
- [ ] All files in correct directories
- [ ] Asset validation passes
- [ ] No missing dependencies

---

## 📚 Integration Points

### AssetLoader.swift
- Loads all USDZ models
- Caches character entities
- Handles missing assets gracefully
- Validates asset availability

### AudioService.swift
- Plays all sound effects
- Manages audio session
- Supports spatial audio (future)
- Volume control

### CharacterProtocols.swift
- AnimatableCharacter protocol
- CharacterAction enum with metadata
- Animation controller
- Event delegation

### EnhancedParticleEffects.swift
- RealityKit particle systems
- Sparkles, snow, bubbles
- Spawn and action effects
- Auto-cleanup and management

---

## 🚀 Development Phases

### Phase 1: Proof of Concept (Week 1)
- [ ] Sparkle character complete
- [ ] All 6 animations working
- [ ] Sound effects sourced/created
- [ ] Integration tested

### Phase 2: Complete Set (Week 2)
- [ ] All 5 characters complete
- [ ] Enhanced particle effects
- [ ] Asset loader implemented
- [ ] Preview images created

### Phase 3: Polish & Optimization (Week 3)
- [ ] All assets optimized
- [ ] Performance targets met
- [ ] Quality assurance passed
- [ ] Production ready

---

## 📞 Support & Resources

### Documentation
- [RealityKit Particle Systems](https://developer.apple.com/documentation/realitykit/particleemittercomponent)
- [USDZ Best Practices](https://developer.apple.com/augmented-reality/quick-look/)
- [Reality Composer Pro Guide](https://developer.apple.com/augmented-reality/tools/)

### Questions
- Post technical questions to `/AGENT_PROMPTS/questions.md`
- Tag iOS Core Engineer for protocol/integration issues
- Tag Coordinator for design approval

---

**Last Updated:** 2025-11-19
**Status:** Infrastructure Complete, Assets Pending
**Next Steps:** Begin character modeling or source licensed assets
