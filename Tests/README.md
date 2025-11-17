# Test Suite - Aria's Magic SharePlay App

This directory contains all unit and UI tests for the application.

## Structure

```
Tests/
├── Unit/                           # Unit tests for models, services, viewmodels
│   ├── CharacterProtocolTests.swift
│   └── ...
├── UI/                             # UI tests for user interactions
│   └── ...
└── Performance/                    # Performance and memory tests
    └── ...
```

## Running Tests

### In Xcode
1. Open the Xcode project
2. Press `Cmd + U` to run all tests
3. Or select individual test classes/methods from the Test Navigator (`Cmd + 6`)

### From Command Line
```bash
xcodebuild test -scheme AriasMagicApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage Goals

- **Phase 1**: 70%+ code coverage
- **Phase 2**: 80%+ code coverage
- **Phase 3**: Production-ready (maintained at 80%+)

## Current Tests

### CharacterProtocolTests (27 tests)
Tests for the `AnimatableCharacter` protocol and `Character` class conformance:

**Protocol Conformance:**
- Character conforms to AnimatableCharacter
- ModelEntity is non-optional
- Character type and ID are set correctly
- Initial state is idle

**Position & Scale:**
- setPosition updates both property and entity
- setScale updates both property and entity
- Position and scale are independent

**Actions:**
- All 6 action types can be performed
- Action completion callbacks work
- Actions reset to idle after duration
- Idle action completes immediately
- Multiple actions can be sequenced

**Factory:**
- DefaultCharacterFactory creates valid characters
- Factory returns AnimatableCharacter protocol type
- Factory supports all character types

**Cleanup:**
- cleanup() removes entity from parent

## Writing New Tests

### Test File Naming
- Unit tests: `[ClassName]Tests.swift`
- UI tests: `[FeatureName]UITests.swift`
- Performance tests: `[FeatureName]PerformanceTests.swift`

### Test Method Naming
Use descriptive names that explain what is being tested:
```swift
func testCharacterConformsToAnimatableCharacter() { ... }
func testSetPositionUpdatesEntity() { ... }
```

### Best Practices
1. Each test should test one thing
2. Use XCTestExpectation for async operations
3. Clean up in tearDown
4. Use meaningful assertion messages
5. Test edge cases and error paths

## Integration with CI/CD

When the project is set up with GitHub Actions or similar:
- All tests run on every pull request
- Tests must pass before merging
- Code coverage reports are generated

## QA Engineer Notes

The QA Engineer is responsible for:
- Adding new test files for new features
- Maintaining test coverage above targets
- Running performance tests regularly
- Updating this README with new test info

---

**Last Updated:** 2025-11-17 by iOS Core Engineer
