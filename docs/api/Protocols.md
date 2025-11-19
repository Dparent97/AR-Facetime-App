# Protocols API Reference

## Overview

This document describes the protocol definitions used throughout Aria's Magic SharePlay App for delegation, communication, and abstraction.

---

## FaceTrackingDelegate

### Overview

Protocol for receiving facial expression detection callbacks from `FaceTrackingService`.

### Declaration

```swift
protocol FaceTrackingDelegate: AnyObject {
    func didDetectExpression(_ expression: FaceExpression)
}
```

**Location:** `AriasMagicApp/Services/FaceTrackingService.swift`

**Inherits:** `AnyObject` - Restricts to class types for weak references

---

### Methods

#### `didDetectExpression(_:)`

Called when a facial expression is detected and passes threshold and debouncing checks.

**Declaration:**
```swift
func didDetectExpression(_ expression: FaceExpression)
```

**Parameters:**
- `expression` - The detected expression (`.smile`, `.eyebrowsRaised`, or `.mouthOpen`)

**Discussion:**
This method is called on the main queue automatically. Implement this to trigger character actions or effects based on user expressions.

**Threading:**
Always called on main thread. Safe to update UI directly.

**Example Implementation:**
```swift
extension ARCoordinator: FaceTrackingDelegate {
    func didDetectExpression(_ expression: FaceExpression) {
        switch expression {
        case .smile:
            viewModel.triggerEffect(.sparkles)
        case .eyebrowsRaised:
            viewModel.performAction(.wave)
        case .mouthOpen:
            viewModel.performAction(.jump)
        }
    }
}
```

---

### Usage Pattern

**Setup:**
```swift
class MyClass: FaceTrackingDelegate {
    let faceTrackingService: FaceTrackingService
    let viewModel: CharacterViewModel

    init(viewModel: CharacterViewModel) {
        self.viewModel = viewModel
        self.faceTrackingService = FaceTrackingService(delegate: self)
    }

    // Implement protocol
    func didDetectExpression(_ expression: FaceExpression) {
        viewModel.handleFaceExpression(expression)
    }
}
```

**Integration with ARSession:**
```swift
extension MyClass: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                faceTrackingService.processFaceAnchor(faceAnchor)
                // This triggers didDetectExpression() if threshold met
            }
        }
    }
}
```

---

## Standard Protocol Conformances

The app's types conform to several standard Swift and framework protocols:

---

### Identifiable

**Purpose:** Unique identification for SwiftUI and collection management

**Conforming Types:**
- `Character` - Uses `id: UUID` property

**Benefits:**
- Automatic ForEach support in SwiftUI
- Stable identity for animations
- Collection diffing

**Example:**
```swift
ForEach(characters) { character in
    // character.id used automatically
    CharacterView(character: character)
}
```

---

### ObservableObject

**Purpose:** Reactive state management with Combine

**Conforming Types:**
- `Character` - Publishes position, scale, currentAction
- `CharacterViewModel` - Publishes characters array, effects, selection
- `SharePlayService` - Publishes isActive, participants

**Benefits:**
- Automatic view updates in SwiftUI
- Combine publisher integration
- @Published property wrapper support

**Example:**
```swift
@ObservedObject var viewModel: CharacterViewModel

var body: some View {
    Text("Characters: \(viewModel.characters.count)")
    // Auto-updates when characters array changes
}
```

---

### Codable

**Purpose:** Serialization and deserialization for data persistence and network transmission

**Conforming Types:**
- `CharacterType` - SharePlay message encoding
- `CharacterAction` - SharePlay message encoding
- `SyncMessage` - GroupActivities messaging
- `SyncMessage.MessageType` - Nested enum coding

**Benefits:**
- Automatic JSON encoding/decoding
- SharePlay message transmission
- Future data persistence support

**Example:**
```swift
let message = SyncMessage(
    type: .characterSpawned,
    characterType: .sparkleThePrincess,
    // ...
)

// Encode for transmission
let data = try JSONEncoder().encode(message)

// Decode on receive
let decoded = try JSONDecoder().decode(SyncMessage.self, from: data)
```

---

### CaseIterable

**Purpose:** Iteration over all enum cases

**Conforming Types:**
- `CharacterType` - Iterate all character types
- `MagicEffect` - Iterate all effect types

**Benefits:**
- UI picker generation
- Testing all cases
- Feature completeness validation

**Example:**
```swift
// Character type picker
Picker("Character", selection: $selectedType) {
    ForEach(CharacterType.allCases, id: \.self) { type in
        Text(type.rawValue).tag(type)
    }
}

// Effect buttons
ForEach(MagicEffect.allCases, id: \.self) { effect in
    Button(effect.emoji) {
        viewModel.triggerEffect(effect)
    }
}
```

---

### GroupActivity

**Purpose:** Enable SharePlay integration

**Conforming Types:**
- `MagicARActivity` - SharePlay activity definition

**Requirements:**
- `activityIdentifier` - Unique identifier string
- `metadata` - Activity display information

**Benefits:**
- FaceTime integration
- Automatic participant management
- System UI integration

**Example:**
```swift
struct MagicARActivity: GroupActivity {
    static let activityIdentifier = "com.ariasmagic.shareplay"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Aria's Magic AR"
        metadata.subtitle = "Share the magic together!"
        metadata.type = .generic
        return metadata
    }
}
```

---

### UIViewRepresentable

**Purpose:** Wrap UIKit views for use in SwiftUI

**Conforming Types:**
- `MagicARView` - Wraps ARView (RealityKit)

**Required Methods:**
- `makeUIView(context:)` - Create the UIKit view
- `updateUIView(_:context:)` - Update when SwiftUI state changes
- `makeCoordinator()` - Create coordinator for delegates

**Benefits:**
- Use RealityKit ARView in SwiftUI
- Gesture recognizer integration
- ARSession delegate handling

**Example:**
```swift
struct MagicARView: UIViewRepresentable {
    @ObservedObject var viewModel: CharacterViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // Configure AR session, gestures, etc.
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Sync SwiftUI state to AR scene
        context.coordinator.updateCharacters()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, ARSessionDelegate, FaceTrackingDelegate {
        // Handle gestures, AR updates, face tracking
    }
}
```

---

### ARSessionDelegate

**Purpose:** Receive ARKit session updates

**Conforming Types:**
- `MagicARView.Coordinator` - Processes AR anchors and face data

**Key Methods:**
- `session(_:didUpdate:)` - Receive anchor updates
- `session(_:didFailWithError:)` - Handle errors
- `sessionWasInterrupted(_:)` - Handle interruptions

**Example:**
```swift
extension MagicARView.Coordinator: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                faceTrackingService?.processFaceAnchor(faceAnchor)
            }
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session error: \(error)")
    }
}
```

---

## Protocol Design Patterns

### Delegate Pattern

**Used For:**
- `FaceTrackingDelegate` - One-to-one communication from service to coordinator

**Benefits:**
- Loose coupling
- Easy to test with mocks
- Clear ownership (weak references prevent cycles)

**Example:**
```swift
protocol MyServiceDelegate: AnyObject {
    func serviceDidComplete(_ service: MyService)
}

class MyService {
    weak var delegate: MyServiceDelegate?

    func doWork() {
        // ... work ...
        delegate?.serviceDidComplete(self)
    }
}
```

---

### Observer Pattern (Combine)

**Used For:**
- `@Published` properties via `ObservableObject`
- Multi-subscriber state updates

**Benefits:**
- Multiple observers
- Automatic memory management
- Composable transformations

**Example:**
```swift
class MyViewModel: ObservableObject {
    @Published var state: String = "idle"

    func changeState() {
        state = "active"
        // All subscribers notified automatically
    }
}

// Multiple observers
viewModel.$state.sink { newState in
    print("Observer 1: \(newState)")
}

viewModel.$state.sink { newState in
    print("Observer 2: \(newState)")
}
```

---

## Creating Custom Protocols

### Guidelines

**When to Create a Protocol:**
- Defining a delegate relationship
- Abstracting multiple implementations
- Dependency injection for testing
- Defining service interfaces

**Protocol Naming:**
- Delegates: `[Type]Delegate` (e.g., `FaceTrackingDelegate`)
- Capabilities: `-able` suffix (e.g., `Animatable`, `Syncable`)
- Data sources: `[Type]DataSource`

**Example Custom Protocol:**
```swift
// Service abstraction for testing
protocol CharacterDataProvider {
    func fetchCharacters() async throws -> [Character]
    func save(_ character: Character) async throws
}

// Production implementation
class RealityKitCharacterProvider: CharacterDataProvider {
    func fetchCharacters() async throws -> [Character] {
        // Load from RealityKit scene
    }

    func save(_ character: Character) async throws {
        // Persist to scene
    }
}

// Mock for testing
class MockCharacterProvider: CharacterDataProvider {
    var mockCharacters: [Character] = []

    func fetchCharacters() async throws -> [Character] {
        return mockCharacters
    }

    func save(_ character: Character) async throws {
        mockCharacters.append(character)
    }
}
```

---

## Protocol Composition

**Combining Multiple Protocols:**

```swift
// Character could adopt multiple protocols
protocol Animatable {
    func performAnimation(_ name: String)
}

protocol Positionable {
    var position: SIMD3<Float> { get set }
}

// Composed protocol
typealias ARCharacter = Animatable & Positionable & Identifiable

// Usage
func moveAndAnimate<T: ARCharacter>(_ object: T) {
    object.position = [0, 0, -1]
    object.performAnimation("wave")
}
```

---

## Testing with Protocols

**Mock Implementations:**

```swift
// Mock delegate for testing
class MockFaceTrackingDelegate: FaceTrackingDelegate {
    var expressionsDetected: [FaceExpression] = []

    func didDetectExpression(_ expression: FaceExpression) {
        expressionsDetected.append(expression)
    }
}

// Test
func testFaceTracking() {
    let mockDelegate = MockFaceTrackingDelegate()
    let service = FaceTrackingService(delegate: mockDelegate)

    // Simulate face anchor with smile
    let faceAnchor = createMockFaceAnchor(smile: 0.8)
    service.processFaceAnchor(faceAnchor)

    XCTAssertEqual(mockDelegate.expressionsDetected.count, 1)
    XCTAssertEqual(mockDelegate.expressionsDetected.first, .smile)
}
```

---

## See Also

- [Services.md](./Services.md) - `FaceTrackingService` and `SharePlayService`
- [Models.md](./Models.md) - `Character` and other model types
- [ViewModels.md](./ViewModels.md) - `CharacterViewModel` integration
- [Architecture Documentation](../ARCHITECTURE.md) - Design patterns overview

---

**Last Updated:** 2025-11-19
**API Version:** 1.0
