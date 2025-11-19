# Models API Reference

## Overview

The Models layer contains the core domain objects representing AR characters and magic effects. These classes manage RealityKit entities and provide high-level interfaces for animations and visual effects.

---

## Character

### Overview

Represents an AR character instance with identity, visual representation, animation capabilities, and spatial properties. Each character maintains its own RealityKit `ModelEntity` and handles its animation lifecycle.

### Declaration

```swift
class Character: Identifiable, ObservableObject {
    let id: UUID
    let type: CharacterType
    @Published var position: SIMD3<Float>
    @Published var scale: SIMD3<Float>
    @Published var currentAction: CharacterAction

    var entity: ModelEntity?

    init(
        id: UUID = UUID(),
        type: CharacterType,
        position: SIMD3<Float> = [0, 0, -1],
        scale: SIMD3<Float> = [1, 1, 1]
    )

    func performAction(_ action: CharacterAction)
}
```

**Location:** `AriasMagicApp/Models/Character.swift`

**Conforms To:**
- `Identifiable` - Unique identification via `id` property
- `ObservableObject` - Publishes state changes for SwiftUI observation

---

### Properties

#### `id`
Unique identifier for the character instance.

**Type:** `UUID`
**Access:** Read-only (let)
**Discussion:** Used for identifying characters in collections and during SharePlay synchronization. Automatically generated on initialization.

**Example:**
```swift
let character = Character(type: .sparkleThePrincess)
print(character.id) // "A1B2C3D4-..."
```

---

#### `type`
The character's theme and personality type.

**Type:** `CharacterType`
**Access:** Read-only (let)
**Values:** See `CharacterType` enum below
**Discussion:** Determines the character's color, name, and future 3D model. Set at initialization and immutable.

**Example:**
```swift
let sparkle = Character(type: .sparkleThePrincess)
let luna = Character(type: .lunaTheStarDancer)
```

---

#### `position`
The character's 3D world position in AR space.

**Type:** `SIMD3<Float>`
**Access:** Read-write (@Published)
**Default:** `[0, 0, -1]` (1 meter in front of user)
**Discussion:** Measured in meters. Changes trigger SwiftUI view updates. Synchronized with the RealityKit entity position.

**Components:**
- `x` - Left/right (negative = left, positive = right)
- `y` - Up/down (negative = down, positive = up)
- `z` - Depth (negative = toward user, positive = away)

**Example:**
```swift
let character = Character(type: .rosieTheDreamWeaver)
character.position = [0.5, 0, -0.5] // 0.5m right, 0.5m away

// Observe changes
character.$position.sink { newPosition in
    print("Character moved to \(newPosition)")
}
```

---

#### `scale`
The character's size scaling factor.

**Type:** `SIMD3<Float>`
**Access:** Read-write (@Published)
**Default:** `[1, 1, 1]` (normal size)
**Discussion:** Uniform scaling (e.g., `[2, 2, 2]`) recommended for consistent proportions. Non-uniform scaling possible but may distort character.

**Example:**
```swift
let character = Character(type: .crystalTheGemKeeper)
character.scale = [2, 2, 2] // Double size
character.scale = [0.5, 0.5, 0.5] // Half size
```

---

#### `currentAction`
The character's current animation state.

**Type:** `CharacterAction`
**Access:** Read-write (@Published)
**Default:** `.idle`
**Discussion:** Automatically set to `.idle` after action animations complete (1.5 seconds). Use `performAction(_:)` method instead of setting directly.

**Example:**
```swift
let character = Character(type: .willowTheWishMaker)
print(character.currentAction) // .idle

character.performAction(.wave)
// currentAction is now .wave
// After 1.5 seconds, returns to .idle
```

---

#### `entity`
The RealityKit visual representation of the character.

**Type:** `ModelEntity?`
**Access:** Read-only (internal set)
**Discussion:** Created automatically during initialization. Nil if entity creation fails. Contains collision components for gesture interaction.

**Current Implementation:**
- Colored cube mesh (0.1m size)
- SimpleMaterial with character-specific color
- CollisionComponent for tap/drag detection

**Production Notes:**
Replace with USDZ 3D models loaded from Reality Composer or Blender.

---

### Methods

#### `performAction(_:)`

Performs an animated action on the character.

**Declaration:**
```swift
func performAction(_ action: CharacterAction)
```

**Parameters:**
- `action` - The action to perform. See `CharacterAction` enum.

**Discussion:**
The character will transition from its current state to perform the specified action, then automatically return to idle state after 1.5 seconds. Animations use RealityKit's `move(to:relativeTo:duration:)` API for smooth transitions.

**Action Details:**
- `.idle` - No animation
- `.wave` - 45° rotation on Y axis (0.5s duration)
- `.dance` - Bounce up 0.1m and down (0.6s total)
- `.twirl` - Full 360° rotation (1.0s duration)
- `.jump` - Jump up 0.2m and down (0.8s total)
- `.sparkle` - Scale pulse to 1.2x and back (0.6s total)

**Example:**
```swift
let character = Character(type: .sparkleThePrincess)

// Perform a wave
character.performAction(.wave)

// Perform a dance
character.performAction(.dance)

// Chain actions with delays
character.performAction(.wave)
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    character.performAction(.dance)
}
```

**Thread Safety:**
Safe to call from main thread. Internal RealityKit animations are thread-safe.

**See Also:**
- `CharacterAction` enum
- `currentAction` property

---

## CharacterType

### Overview

Enumeration of character themes and personalities. Each type has a unique name, color, and (in production) 3D model.

### Declaration

```swift
enum CharacterType: String, CaseIterable, Codable {
    case sparkleThePrincess = "Sparkle the Princess"
    case lunaTheStarDancer = "Luna the Star Dancer"
    case rosieTheDreamWeaver = "Rosie the Dream Weaver"
    case crystalTheGemKeeper = "Crystal the Gem Keeper"
    case willowTheWishMaker = "Willow the Wish Maker"
}
```

**Conforms To:**
- `String` - Raw value is display name
- `CaseIterable` - Can iterate over all cases
- `Codable` - Serializable for SharePlay messages

---

### Cases

| Case | Display Name | Color | Theme |
|------|--------------|-------|-------|
| `.sparkleThePrincess` | "Sparkle the Princess" | Pink | Classic princess with sparkle magic |
| `.lunaTheStarDancer` | "Luna the Star Dancer" | Purple | Celestial dancer with starlight |
| `.rosieTheDreamWeaver` | "Rosie the Dream Weaver" | Red | Dream creator with rosy magic |
| `.crystalTheGemKeeper` | "Crystal the Gem Keeper" | Cyan | Crystal guardian with gem powers |
| `.willowTheWishMaker` | "Willow the Wish Maker" | Green | Wish granter with nature magic |

---

### Usage

**Iterating All Types:**
```swift
for type in CharacterType.allCases {
    print(type.rawValue) // Display name
}
```

**Selecting Type:**
```swift
let selectedType: CharacterType = .sparkleThePrincess
let character = Character(type: selectedType)
```

**Codable (for SharePlay):**
```swift
let message = SyncMessage(
    type: .characterSpawned,
    characterType: .lunaTheStarDancer,
    // ...
)
```

---

## CharacterAction

### Overview

Enumeration of character animation actions. Each action has a specific animation behavior and duration.

### Declaration

```swift
enum CharacterAction: String, Codable {
    case idle
    case wave
    case dance
    case twirl
    case jump
    case sparkle
}
```

**Conforms To:**
- `String` - Raw value for serialization
- `Codable` - Serializable for SharePlay sync

---

### Cases

#### `.idle`
Default resting state with no animation.

**Duration:** N/A
**Animation:** None
**Triggered By:** Auto-return after actions complete

---

#### `.wave`
Character rotates as if waving hello.

**Duration:** 0.5 seconds
**Animation:** 45° rotation on Y axis
**Triggered By:**
- Wave button tap
- Eyebrows raised face expression

**Example:**
```swift
character.performAction(.wave)
```

---

#### `.dance`
Character bounces up and down.

**Duration:** 0.6 seconds
**Animation:** Move up 0.1m, then down 0.1m
**Triggered By:** Dance button tap

**Example:**
```swift
character.performAction(.dance)
```

---

#### `.twirl`
Character spins in a full circle.

**Duration:** 1.0 second
**Animation:** 360° rotation on Y axis
**Triggered By:** Twirl button tap

**Example:**
```swift
character.performAction(.twirl)
```

---

#### `.jump`
Character jumps high and lands.

**Duration:** 0.8 seconds
**Animation:** Move up 0.2m, then down 0.2m
**Triggered By:**
- Jump button tap
- Mouth open face expression

**Example:**
```swift
character.performAction(.jump)
```

---

#### `.sparkle`
Character pulses with sparkle energy.

**Duration:** 0.6 seconds
**Animation:** Scale to 1.2x, then back to 1.0x
**Triggered By:** Smile face expression (triggers effect, not action)

**Example:**
```swift
character.performAction(.sparkle)
```

---

## MagicEffect

### Overview

Enumeration of magical particle effect types. Each effect creates a unique visual experience in the AR scene.

### Declaration

```swift
enum MagicEffect: String, CaseIterable {
    case sparkles
    case snow
    case bubbles

    var displayName: String { get }
    var emoji: String { get }
}
```

**Conforms To:**
- `String` - Raw value identifier
- `CaseIterable` - Iterate over all effects

---

### Cases

#### `.sparkles`
Golden glowing particles that rise and fade.

**Particle Count:** 20
**Color:** Yellow (golden)
**Motion:** Upward with fade out
**Duration:** 2.0 seconds
**Triggered By:**
- Sparkles button tap
- Smile face expression

**Example:**
```swift
viewModel.triggerEffect(.sparkles)
```

---

#### `.snow`
White particles that fall like snowflakes.

**Particle Count:** 30
**Color:** White
**Motion:** Downward falling
**Duration:** 3.0 seconds
**Triggered By:** Snow button tap

**Example:**
```swift
viewModel.triggerEffect(.snow)
```

---

#### `.bubbles`
Translucent spheres that float upward.

**Particle Count:** 15
**Color:** Cyan (transparent)
**Size:** Variable (0.02m - 0.05m radius)
**Motion:** Upward floating
**Duration:** 4.0 seconds
**Triggered By:** Bubbles button tap

**Example:**
```swift
viewModel.triggerEffect(.bubbles)
```

---

### Computed Properties

#### `displayName`
User-friendly name with emoji.

**Type:** `String`
**Values:**
- `.sparkles` → "✨ Sparkles"
- `.snow` → "❄️ Snow"
- `.bubbles` → "🫧 Bubbles"

**Example:**
```swift
let effect: MagicEffect = .sparkles
print(effect.displayName) // "✨ Sparkles"
```

---

#### `emoji`
Emoji icon representing the effect.

**Type:** `String`
**Values:**
- `.sparkles` → "✨"
- `.snow` → "❄️"
- `.bubbles` → "🫧"

**Example:**
```swift
Button(effect.emoji) {
    viewModel.triggerEffect(effect)
}
```

---

## MagicEffectGenerator

### Overview

Static factory class for creating particle effect entities. Generates RealityKit entity hierarchies with animated particles.

### Declaration

```swift
class MagicEffectGenerator {
    static func createParticleEffect(for effect: MagicEffect) -> Entity
}
```

**Location:** `AriasMagicApp/Models/MagicEffect.swift`

---

### Methods

#### `createParticleEffect(for:)`

Creates a particle effect entity with animated children.

**Declaration:**
```swift
static func createParticleEffect(for effect: MagicEffect) -> Entity
```

**Parameters:**
- `effect` - The type of effect to create

**Returns:** `Entity` containing particle children with animations

**Discussion:**
Creates an entity hierarchy with multiple child particles. Each particle is a `ModelEntity` with a sphere mesh and material. Animations are applied using RealityKit's `move(to:relativeTo:duration:)` API.

**Implementation Details:**
- **Sparkles:** 20 small yellow spheres, upward motion, 2s duration
- **Snow:** 30 white spheres, downward falling, 3s duration
- **Bubbles:** 15 variable-size cyan spheres, upward floating, 4s duration

**Production Recommendations:**
Replace with RealityKit's built-in particle system for:
- Better performance (GPU acceleration)
- More realistic effects (turbulence, velocity, etc.)
- Emitter-based continuous effects
- Particle textures and blending modes

**Example:**
```swift
import RealityKit

// Create effect entity
let effectEntity = MagicEffectGenerator.createParticleEffect(for: .sparkles)

// Add to AR scene
arView.scene.addChild(effectEntity)

// Position effect
effectEntity.position = [0, 0.5, -1]

// Remove after duration
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    effectEntity.removeFromParent()
}
```

**See Also:**
- `MagicEffect` enum
- `CharacterViewModel.triggerEffect(_:)`

---

## Usage Examples

### Basic Character Creation

```swift
import RealityKit

// Create a character
let sparkle = Character(
    type: .sparkleThePrincess,
    position: [0, 0, -0.5],
    scale: [1, 1, 1]
)

// Add entity to AR scene
if let entity = sparkle.entity {
    arView.scene.addChild(entity)
}

// Perform an action
sparkle.performAction(.wave)
```

---

### Multiple Characters with Different Types

```swift
import RealityKit

let characterTypes: [CharacterType] = [
    .sparkleThePrincess,
    .lunaTheStarDancer,
    .rosieTheDreamWeaver
]

var characters: [Character] = []

for (index, type) in characterTypes.enumerated() {
    let xPosition = Float(index - 1) * 0.3 // Spread out
    let character = Character(
        type: type,
        position: [xPosition, 0, -1]
    )
    characters.append(character)

    if let entity = character.entity {
        arView.scene.addChild(entity)
    }
}

// Make them all dance
characters.forEach { $0.performAction(.dance) }
```

---

### Creating Effects

```swift
import RealityKit

// Create sparkle effect
let sparkleEffect = MagicEffectGenerator.createParticleEffect(for: .sparkles)
sparkleEffect.position = [0, 0.5, -1]
arView.scene.addChild(sparkleEffect)

// Auto-remove after effect duration
DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
    sparkleEffect.removeFromParent()
}
```

---

### Observing Character State

```swift
import Combine

let character = Character(type: .crystalTheGemKeeper)
var cancellables = Set<AnyCancellable>()

// Observe position changes
character.$position
    .sink { newPosition in
        print("Character moved to \(newPosition)")
    }
    .store(in: &cancellables)

// Observe action changes
character.$currentAction
    .sink { action in
        print("Character is now: \(action)")
    }
    .store(in: &cancellables)

// Trigger changes
character.position = [1, 0, -1]
character.performAction(.jump)
```

---

### Animating a Sequence

```swift
let character = Character(type: .willowTheWishMaker)

// Perform sequence: wave → dance → twirl
character.performAction(.wave)

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    character.performAction(.dance)
}

DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    character.performAction(.twirl)
}
```

---

## Thread Safety

**Main Thread Only:**
- All character property modifications
- `performAction(_:)` calls
- RealityKit entity operations

**Thread-Safe:**
- Reading properties (UUID, type)
- Combine publishers (automatically dispatch to main queue)

---

## Performance Considerations

**Current Limitations:**
- Simple cube meshes (low overhead)
- Basic material rendering
- Limited particle counts (15-30)

**Production Optimizations:**
- Implement object pooling for effects
- Use LOD (Level of Detail) for 3D models
- Limit max concurrent characters (recommend 5-10)
- Profile with Instruments for 60 FPS

**Memory Management:**
- Characters retain RealityKit entities
- Remove characters from scene when no longer needed
- Effects auto-cleanup after animation completes

---

## See Also

- [ViewModels.md](./ViewModels.md) - `CharacterViewModel` for state management
- [Services.md](./Services.md) - `FaceTrackingService` for expression-triggered actions
- [Architecture Documentation](../ARCHITECTURE.md) - Overall system design

---

**Last Updated:** 2025-11-19
**API Version:** 1.0
