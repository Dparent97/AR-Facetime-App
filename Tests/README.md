# Aria's Magic SharePlay App - Test Suite

## Overview

Comprehensive test coverage ensuring quality and preventing regressions for Aria's Magic SharePlay App. This test suite follows industry best practices with unit tests, integration tests, UI tests, and performance tests.

## Test Structure

```
Tests/
├── Fixtures/
│   └── TestFixtures.swift           # Mock objects and test data
├── Unit/
│   ├── Models/
│   │   ├── CharacterTests.swift     # Character model tests (30+ tests)
│   │   ├── CharacterProtocolTests.swift # Protocol conformance tests
│   │   └── MagicEffectTests.swift   # Magic effect tests (25+ tests)
│   ├── Services/
│   │   ├── FaceTrackingServiceTests.swift  # Face tracking tests (20+ tests)
│   │   └── SharePlayServiceTests.swift     # SharePlay tests (30+ tests)
│   └── ViewModels/
│       └── CharacterViewModelTests.swift   # ViewModel tests (40+ tests)
├── UI/                               # UI tests (to be added)
├── Performance/                      # Performance tests (to be added)
└── Integration/                      # Integration tests (to be added)
```

## Quick Start

### Running All Tests

**Note:** This project currently contains Swift test files but does not yet have an Xcode project file (`.xcodeproj`). Before running tests, you'll need to create an Xcode project:

1. Open Xcode
2. Create a new iOS App project named "AriasMagicApp"
3. Add all Swift files from `AriasMagicApp/` to the project
4. Add test targets and test files from `Tests/`

Once the Xcode project is set up:

```bash
# Run all tests
xcodebuild test -scheme AriasMagicApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage Goals

- **Phase 1**: 70%+ code coverage
- **Phase 2**: 80%+ code coverage
- **Phase 3**: Production-ready (maintained at 80%+)

## Test Categories

### Unit Tests

Unit tests verify individual components in isolation using mocks and fixtures.

#### Models
- **CharacterTests:** Character initialization, actions, entity creation, edge cases
- **CharacterProtocolTests:** Protocol conformance, position/scale updates, action execution
- **MagicEffectTests:** Effect types, particle generation, performance

#### Services
- **FaceTrackingServiceTests:** Expression detection, thresholds, debouncing, delegate callbacks
- **SharePlayServiceTests:** Message encoding/decoding, session management, sync messages

#### ViewModels
- **CharacterViewModelTests:** Character spawning, actions, effects, face expression handling

### UI Tests (Planned)

UI tests verify end-to-end user flows:
- Onboarding flow
- Character spawning and selection
- Gesture interactions (tap, drag, pinch)
- Settings screen
- SharePlay UI

## Writing Tests

### Test Structure (AAA Pattern)

All tests follow the Arrange-Act-Assert pattern:

```swift
func testExample() {
    // ARRANGE: Set up test conditions
    let character = Character(type: .sparkleThePrincess)

    // ACT: Perform action
    character.performAction(.wave)

    // ASSERT: Verify results
    XCTAssertEqual(character.currentAction, .wave)
}
```

### Best Practices
1. Each test should test one thing
2. Use XCTestExpectation for async operations
3. Clean up in tearDown
4. Use meaningful assertion messages
5. Test edge cases and error paths

## CI/CD

### GitHub Actions

Tests run automatically on every push via GitHub Actions. See `.github/workflows/ios-tests.yml`.

**Workflow includes:**
- Unit test execution
- UI test execution
- Code coverage generation
- Coverage reporting to Codecov
- Swift lint checks
- Build verification

---

**Last Updated:** 2025-11-19
