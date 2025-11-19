# API Reference Documentation
**Aria's Magic SharePlay App**

## Overview

This directory contains comprehensive API documentation for all public interfaces in Aria's Magic SharePlay App. The documentation is organized by layer following the app's MVVM architecture.

## Documentation Structure

```
api/
├── README.md           # This file - API documentation overview
├── Models.md           # Character, MagicEffect, and data types
├── ViewModels.md       # CharacterViewModel
├── Services.md         # FaceTrackingService, SharePlayService
├── Protocols.md        # Delegates and protocol definitions
└── Views.md            # SwiftUI views and components
```

## Quick Navigation

### Models Layer
**File:** [Models.md](./Models.md)

Core data types and domain objects:
- `Character` - AR character instance with animations
- `CharacterType` - Character theme enumeration
- `CharacterAction` - Animation type enumeration
- `MagicEffect` - Particle effect types
- `MagicEffectGenerator` - Effect creation factory

### ViewModels Layer
**File:** [ViewModels.md](./ViewModels.md)

State management and business logic:
- `CharacterViewModel` - Central state manager for characters and effects

### Services Layer
**File:** [Services.md](./Services.md)

Platform integration services:
- `FaceTrackingService` - ARKit face expression detection
- `SharePlayService` - GroupActivities synchronization
- `MagicARActivity` - SharePlay activity definition
- `SyncMessage` - State synchronization messages

### Protocols Layer
**File:** [Protocols.md](./Protocols.md)

Protocol definitions and delegates:
- `FaceTrackingDelegate` - Face expression callbacks
- `ARSessionDelegate` - AR session updates (standard ARKit)

### Views Layer
**File:** [Views.md](./Views.md)

SwiftUI views and UI components:
- `ContentView` - Main coordinator view
- `MagicARView` - AR view with RealityKit
- `ActionButtonsView` - Control panel
- `OnboardingView` - Tutorial flow

## Usage Guidelines

### Reading the Documentation

Each API reference page follows this structure:

1. **Overview** - High-level purpose and role
2. **Declaration** - Swift syntax
3. **Properties** - All properties with types and descriptions
4. **Methods** - All methods with parameters, return values, and examples
5. **Examples** - Real-world usage code
6. **Discussion** - Implementation details and best practices
7. **See Also** - Related APIs

### Code Examples

All code examples are:
- Fully functional and runnable
- Include necessary imports
- Show realistic use cases
- Include inline comments for clarity

### Conventions

**Type Formatting:**
- `TypeName` - Types, classes, structs, enums in backticks
- `methodName()` - Methods and functions with parentheses
- `propertyName` - Properties and variables
- `.enumCase` - Enum cases with leading dot

**Parameter Descriptions:**
- **Type:** Swift type
- **Access:** Read-only, Read-write, Private, etc.
- **Default:** Default value if applicable
- **Required:** Whether parameter is required

## Integration Patterns

### Common Workflows

**Creating and Managing Characters:**
```swift
import RealityKit

// 1. Create ViewModel
let viewModel = CharacterViewModel()

// 2. Spawn a character
viewModel.spawnCharacter(at: [0, 0, -0.5])

// 3. Trigger an action
viewModel.performAction(.wave)

// 4. Trigger an effect
viewModel.triggerEffect(.sparkles)
```

**Face Tracking Integration:**
```swift
import ARKit

// 1. Create service with delegate
let service = FaceTrackingService(delegate: self)

// 2. Process ARFaceAnchor from ARSession
func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    for anchor in anchors {
        if let faceAnchor = anchor as? ARFaceAnchor {
            service.processFaceAnchor(faceAnchor)
        }
    }
}

// 3. Implement delegate
extension MyClass: FaceTrackingDelegate {
    func didDetectExpression(_ expression: FaceExpression) {
        // Handle expression
    }
}
```

**SharePlay Sessions:**
```swift
import GroupActivities

// 1. Create service
let sharePlayService = SharePlayService()

// 2. Start session
sharePlayService.startSharePlay()

// 3. Send messages
let message = SyncMessage(
    type: .characterSpawned,
    characterID: UUID(),
    characterType: .sparkleThePrincess,
    position: [0, 0, -0.5],
    action: nil,
    effect: nil
)
sharePlayService.sendMessage(message)

// 4. Observe state
if sharePlayService.isActive {
    // SharePlay active
}
```

## Version Information

**App Version:** 1.0.0
**iOS Deployment Target:** 17.0
**Swift Version:** 5.9
**Frameworks:**
- SwiftUI
- RealityKit
- ARKit
- GroupActivities
- Combine

## API Stability

**Stable APIs:**
- All public types and methods are stable for 1.x releases
- Breaking changes will only occur in major version updates

**Experimental APIs:**
- SharePlay integration (may evolve based on GroupActivities updates)
- Effect system (may be replaced with RealityKit particles)

## Deprecation Policy

When APIs are deprecated:
1. Marked with `@available(*, deprecated, message: "...")`
2. Alternative API suggested
3. Maintained for at least one major version
4. Documented in release notes

## Support

For questions or issues with this API documentation:
- Check the [Architecture Documentation](../ARCHITECTURE.md)
- Review code examples in each section
- See the [User Guide](../USER_GUIDE.md) for usage patterns

---

**Last Updated:** 2025-11-19
**Maintained by:** Technical Writer
