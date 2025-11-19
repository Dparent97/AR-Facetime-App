# Services API Reference

## Overview

The Services layer provides platform integration abstractions for ARKit face tracking and GroupActivities SharePlay functionality. Services encapsulate complex platform APIs and provide simplified interfaces using delegate patterns.

---

## FaceTrackingService

### Overview

Detects facial expressions from ARKit face tracking data and notifies delegates when expressions exceed threshold values. Includes debouncing to prevent rapid-fire triggers and ensure smooth user experience.

### Declaration

```swift
class FaceTrackingService {
    weak var delegate: FaceTrackingDelegate?

    init(delegate: FaceTrackingDelegate? = nil)

    func processFaceAnchor(_ faceAnchor: ARFaceAnchor)
}
```

**Location:** `AriasMagicApp/Services/FaceTrackingService.swift`

**Dependencies:**
- ARKit framework
- ARFaceAnchor for blend shape data

---

### Properties

#### `delegate`
Receives callbacks when facial expressions are detected.

**Type:** `FaceTrackingDelegate?`
**Access:** Read-write (weak reference)
**Discussion:** Set this delegate to receive `didDetectExpression(_:)` callbacks. Uses weak reference to prevent retain cycles.

**Example:**
```swift
let service = FaceTrackingService()
service.delegate = self

// Or via initializer
let service = FaceTrackingService(delegate: self)
```

---

### Detection Thresholds

**Internal Configuration:**

| Expression | Blend Shapes | Threshold | Debounce |
|------------|-------------|-----------|----------|
| Smile | `mouthSmileLeft` + `mouthSmileRight` | 0.5 (average) | 1.0s |
| Eyebrows Raised | `browInnerUp` (both) | 0.5 (average) | 1.0s |
| Mouth Open | `jawOpen` | 0.4 | 1.0s |

**Customization:**
Currently hardcoded. Future versions may expose threshold properties for sensitivity adjustment via Settings.

---

### Methods

#### `init(delegate:)`

Initializes the face tracking service with optional delegate.

**Declaration:**
```swift
init(delegate: FaceTrackingDelegate? = nil)
```

**Parameters:**
- `delegate` - Optional delegate to receive expression callbacks

**Example:**
```swift
// Initialize without delegate
let service = FaceTrackingService()
service.delegate = myDelegate

// Initialize with delegate
let service = FaceTrackingService(delegate: self)
```

---

#### `processFaceAnchor(_:)`

Processes an ARFaceAnchor to detect facial expressions.

**Declaration:**
```swift
func processFaceAnchor(_ faceAnchor: ARFaceAnchor)
```

**Parameters:**
- `faceAnchor` - ARFaceAnchor from ARSession delegate callback

**Discussion:**
Call this method from your `ARSessionDelegate.session(_:didUpdate:)` implementation for each `ARFaceAnchor`. The method extracts blend shape values, compares against thresholds, applies debouncing, and triggers delegate callbacks on the main queue.

**Processing Flow:**
1. Extract relevant blend shape values
2. Calculate averages (for paired expressions like smile)
3. Compare against thresholds
4. Check debounce timers
5. Update last trigger time
6. Dispatch delegate callback on main queue

**Example:**
```swift
extension MyCoordinator: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                faceTrackingService.processFaceAnchor(faceAnchor)
            }
        }
    }
}
```

**Performance:**
- Lightweight computation (simple arithmetic)
- Main queue dispatch for callbacks only
- Debouncing prevents excessive delegate calls

**Thread Safety:**
Safe to call from ARSession callback thread (typically background). Delegate callbacks automatically dispatched to main queue.

---

### Expression Detection Details

#### Smile Detection
**Blend Shapes:** `mouthSmileLeft`, `mouthSmileRight`
**Calculation:** Average of both values
**Threshold:** 0.5

**Example Values:**
- Neutral face: 0.0 - 0.2
- Slight smile: 0.3 - 0.4
- Clear smile: 0.5 - 0.7
- Big smile: 0.8 - 1.0

#### Eyebrows Raised Detection
**Blend Shapes:** `browInnerUp` (both)
**Calculation:** Average of both values
**Threshold:** 0.5

**Example Values:**
- Neutral: 0.0 - 0.2
- Slight raise: 0.3 - 0.4
- Clear raise: 0.5 - 0.7
- Extreme raise: 0.8 - 1.0

#### Mouth Open Detection
**Blend Shapes:** `jawOpen`
**Threshold:** 0.4

**Example Values:**
- Closed mouth: 0.0 - 0.1
- Slightly open: 0.2 - 0.3
- Clearly open: 0.4 - 0.6
- Wide open: 0.7 - 1.0

---

### Debouncing Mechanism

**Purpose:** Prevent rapid-fire triggers when user holds expression

**Implementation:**
- Separate timer for each expression type
- 1-second cooldown period
- Tracks last trigger time with `Date`
- Resets on each successful trigger

**Example Scenario:**
```
User smiles
    ↓
Smile detected → Delegate callback
    ↓
User continues smiling (0.5s elapsed)
    ↓
Smile still detected → NO callback (debounced)
    ↓
User continues smiling (1.1s elapsed)
    ↓
Smile still detected → Delegate callback (debounce expired)
```

**Benefits:**
- Prevents animation spam
- Improves battery life
- Better user experience
- Reduces system load

---

### Usage Example

**Complete Integration:**

```swift
import ARKit

class ARCoordinator: NSObject, ARSessionDelegate, FaceTrackingDelegate {
    let faceTrackingService: FaceTrackingService
    let viewModel: CharacterViewModel

    init(viewModel: CharacterViewModel) {
        self.viewModel = viewModel
        self.faceTrackingService = FaceTrackingService()
        super.init()
        self.faceTrackingService.delegate = self
    }

    // ARSessionDelegate
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                faceTrackingService.processFaceAnchor(faceAnchor)
            }
        }
    }

    // FaceTrackingDelegate
    func didDetectExpression(_ expression: FaceExpression) {
        viewModel.handleFaceExpression(expression)
    }
}
```

---

## FaceExpression

### Overview

Enumeration of detectable facial expressions.

### Declaration

```swift
enum FaceExpression {
    case smile
    case eyebrowsRaised
    case mouthOpen
}
```

**Location:** `AriasMagicApp/Services/FaceTrackingService.swift`

---

### Cases

#### `.smile`
User is smiling.

**Triggered Action:** Sparkles effect
**User Feedback:** Golden particles appear

#### `.eyebrowsRaised`
User has raised their eyebrows.

**Triggered Action:** Wave action
**User Feedback:** All characters wave

#### `.mouthOpen`
User has opened their mouth.

**Triggered Action:** Jump action
**User Feedback:** All characters jump

---

## SharePlayService

### Overview

Manages GroupActivities sessions for SharePlay functionality. Handles session lifecycle, participant tracking, and message synchronization across FaceTime calls.

### Declaration

```swift
class SharePlayService: ObservableObject {
    @Published var isActive: Bool
    @Published var participants: [Participant]

    init()

    func startSharePlay()
    func sendMessage(_ message: SyncMessage)
    func endSharePlay()
}
```

**Location:** `AriasMagicApp/Services/SharePlayService.swift`

**Dependencies:**
- GroupActivities framework
- Combine framework

---

### Properties

#### `isActive`
Indicates whether a SharePlay session is currently active.

**Type:** `Bool`
**Access:** Read-only (@Published)
**Default:** `false`

**Discussion:**
Automatically updates when:
- Session joins (becomes `true`)
- Session ends (becomes `false`)
- Session invalidates (becomes `false`)

**Example:**
```swift
let service = SharePlayService()

// Observe state
service.$isActive.sink { active in
    if active {
        print("SharePlay is active!")
    } else {
        print("SharePlay is inactive")
    }
}

// Check state
if service.isActive {
    // Show SharePlay UI
}
```

---

#### `participants`
Array of active participants in the SharePlay session.

**Type:** `[Participant]`
**Access:** Read-only (@Published)
**Default:** `[]` (empty array)

**Discussion:**
Updates automatically as participants join or leave. Includes local user. `Participant` is a GroupActivities framework type.

**Example:**
```swift
service.$participants.sink { participants in
    print("\(participants.count) participants in session")
}
```

---

### Methods

#### `init()`

Initializes the SharePlay service and sets up session listeners.

**Declaration:**
```swift
init()
```

**Discussion:**
Automatically starts listening for incoming SharePlay sessions. Call `startSharePlay()` to initiate a new session.

**Example:**
```swift
let sharePlayService = SharePlayService()
```

---

#### `startSharePlay()`

Initiates a new SharePlay session.

**Declaration:**
```swift
func startSharePlay()
```

**Discussion:**
Creates a `MagicARActivity` and prepares it for activation. Presents the SharePlay system UI to the user for confirmation. If user accepts, the session activates and `isActive` becomes `true`.

**User Flow:**
1. App calls `startSharePlay()`
2. System shows SharePlay picker (requires active FaceTime call)
3. User confirms
4. Session activates
5. `isActive` → `true`
6. Participants receive session invitation

**Example:**
```swift
let service = SharePlayService()

// User taps SharePlay button
Button("Start SharePlay") {
    service.startSharePlay()
}
```

**Requirements:**
- Active FaceTime call (or supported communication app)
- GroupActivities entitlement
- User permission

**Error Handling:**
Currently silent failures. Production should handle:
- `.activationDisabled` - SharePlay not available
- `.cancelled` - User cancelled picker
- Network errors

---

#### `sendMessage(_:)`

Broadcasts a synchronization message to all participants.

**Declaration:**
```swift
func sendMessage(_ message: SyncMessage)
```

**Parameters:**
- `message` - The sync message to broadcast

**Discussion:**
Sends message to all participants in the active session. Messages are delivered reliably but may have latency. Requires an active session (`isActive == true`).

**Example:**
```swift
let service = SharePlayService()

// Sync character spawn
let message = SyncMessage(
    type: .characterSpawned,
    characterID: UUID(),
    characterType: .sparkleThePrincess,
    position: [0, 0, -0.5],
    action: nil,
    effect: nil
)

service.sendMessage(message)
```

**Error Handling:**
Currently uses `try?` (silent failures). Production should:
- Check `isActive` before sending
- Handle network errors
- Implement retry logic
- Queue messages during disconnection

---

#### `endSharePlay()`

Terminates the active SharePlay session.

**Declaration:**
```swift
func endSharePlay()
```

**Discussion:**
Ends the session for all participants. `isActive` becomes `false`. Participants receive session end notification.

**Example:**
```swift
Button("End SharePlay") {
    service.endSharePlay()
}
```

---

### SharePlay Lifecycle

**Session Flow:**

```
User starts SharePlay
    ↓
startSharePlay() called
    ↓
MagicARActivity created
    ↓
prepareForActivation()
    ↓
System shows SharePlay picker
    ↓
User confirms
    ↓
activity.activate()
    ↓
MagicARActivity.sessions() yields session
    ↓
configureSession() called
    ↓
Set up messenger & participant observers
    ↓
session.join()
    ↓
isActive = true
    ↓
Active session (can send/receive messages)
    ↓
endSharePlay() or session invalidated
    ↓
isActive = false
```

---

### Message Handling

**Current Implementation:**
```swift
private func handleReceivedMessage(_ message: SyncMessage) {
    print("Received message: \(message.type)")
    // TODO: Connect to CharacterViewModel
}
```

**Production Integration:**
```swift
private func handleReceivedMessage(_ message: SyncMessage) {
    DispatchQueue.main.async {
        switch message.type {
        case .characterSpawned:
            guard let type = message.characterType,
                  let position = message.position else { return }
            viewModel.spawnCharacter(
                type: type,
                at: SIMD3<Float>(position)
            )

        case .characterAction:
            guard let action = message.action,
                  let id = message.characterID else { return }
            viewModel.performAction(action, characterID: id)

        case .effectTriggered:
            guard let effectString = message.effect,
                  let effect = MagicEffect(rawValue: effectString) else { return }
            viewModel.triggerEffect(effect)
        }
    }
}
```

---

## MagicARActivity

### Overview

GroupActivity definition for SharePlay sessions.

### Declaration

```swift
struct MagicARActivity: GroupActivity {
    static let activityIdentifier = "com.ariasmagic.shareplay"

    var metadata: GroupActivityMetadata { get }
}
```

**Location:** `AriasMagicApp/Services/SharePlayService.swift`

**Conforms To:**
- `GroupActivity` - Enables SharePlay functionality

---

### Properties

#### `activityIdentifier`
Unique identifier for the activity.

**Type:** `String`
**Value:** `"com.ariasmagic.shareplay"`
**Discussion:** Must match bundle identifier prefix. Used by system to track activity type.

#### `metadata`
Activity metadata shown in SharePlay UI.

**Type:** `GroupActivityMetadata`
**Properties:**
- `title` - "Aria's Magic AR"
- `subtitle` - "Share the magic together!"
- `type` - `.generic`

**Example:**
Shows in SharePlay picker as:
```
Aria's Magic AR
Share the magic together!
```

---

## SyncMessage

### Overview

Codable message structure for synchronizing state across SharePlay participants.

### Declaration

```swift
struct SyncMessage: Codable {
    enum MessageType: String, Codable {
        case characterSpawned
        case characterAction
        case effectTriggered
    }

    let type: MessageType
    let characterID: UUID?
    let characterType: CharacterType?
    let position: [Float]?
    let action: CharacterAction?
    let effect: String?
}
```

**Location:** `AriasMagicApp/Services/SharePlayService.swift`

**Conforms To:**
- `Codable` - Serializable for network transmission

---

### Properties

#### `type`
The type of synchronization message.

**Type:** `MessageType`
**Required:** Yes
**Values:** `.characterSpawned`, `.characterAction`, `.effectTriggered`

#### `characterID`
UUID of the character (for actions on specific characters).

**Type:** `UUID?`
**Required:** Only for `.characterAction`

#### `characterType`
Type of character being spawned.

**Type:** `CharacterType?`
**Required:** Only for `.characterSpawned`

#### `position`
3D world position for spawned character.

**Type:** `[Float]?` (3 elements: x, y, z)
**Required:** Only for `.characterSpawned`

**Note:** Array used instead of SIMD3<Float> for Codable compatibility.

#### `action`
Character action being performed.

**Type:** `CharacterAction?`
**Required:** Only for `.characterAction`

#### `effect`
Magic effect being triggered.

**Type:** `String?` (raw value of MagicEffect)
**Required:** Only for `.effectTriggered`

---

### Usage Examples

#### Syncing Character Spawn

```swift
let message = SyncMessage(
    type: .characterSpawned,
    characterID: UUID(),
    characterType: .lunaTheStarDancer,
    position: [0, 0, -0.5],
    action: nil,
    effect: nil
)

sharePlayService.sendMessage(message)
```

#### Syncing Character Action

```swift
let message = SyncMessage(
    type: .characterAction,
    characterID: character.id,
    characterType: nil,
    position: nil,
    action: .dance,
    effect: nil
)

sharePlayService.sendMessage(message)
```

#### Syncing Magic Effect

```swift
let message = SyncMessage(
    type: .effectTriggered,
    characterID: nil,
    characterType: nil,
    position: nil,
    action: nil,
    effect: MagicEffect.sparkles.rawValue
)

sharePlayService.sendMessage(message)
```

---

## Complete Usage Example

### SharePlay Integration

```swift
import GroupActivities
import Combine

class ARExperienceCoordinator: ObservableObject {
    let sharePlayService = SharePlayService()
    let viewModel = CharacterViewModel()
    var cancellables = Set<AnyCancellable>()

    init() {
        setupSharePlayObservers()
    }

    func setupSharePlayObservers() {
        // Observe SharePlay state
        sharePlayService.$isActive
            .sink { [weak self] active in
                if active {
                    self?.onSharePlayActivated()
                } else {
                    self?.onSharePlayDeactivated()
                }
            }
            .store(in: &cancellables)

        // Observe participants
        sharePlayService.$participants
            .sink { participants in
                print("Participants: \(participants.count)")
            }
            .store(in: &cancellables)
    }

    func startSharing() {
        sharePlayService.startSharePlay()
    }

    func syncCharacterSpawn(_ character: Character) {
        let message = SyncMessage(
            type: .characterSpawned,
            characterID: character.id,
            characterType: character.type,
            position: [
                character.position.x,
                character.position.y,
                character.position.z
            ],
            action: nil,
            effect: nil
        )
        sharePlayService.sendMessage(message)
    }

    private func onSharePlayActivated() {
        print("SharePlay is active - syncing state...")
    }

    private func onSharePlayDeactivated() {
        print("SharePlay ended")
    }
}
```

---

## Thread Safety

**Main Thread Only:**
- All SharePlay UI interactions
- Delegate callbacks
- Published property modifications

**Async/Await:**
- `startSharePlay()` uses Swift Concurrency
- Message sending/receiving uses async streams
- Automatically dispatches to appropriate threads

---

## See Also

- [Models.md](./Models.md) - `Character`, `MagicEffect` types
- [ViewModels.md](./ViewModels.md) - `CharacterViewModel` integration
- [Protocols.md](./Protocols.md) - `FaceTrackingDelegate` protocol
- [Architecture Documentation](../ARCHITECTURE.md) - Service layer design

---

**Last Updated:** 2025-11-19
**API Version:** 1.0
