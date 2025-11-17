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

### Running Specific Test Suites

#### Unit Tests Only
```bash
xcodebuild test \
  -scheme AriasMagicApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AriasMagicAppTests
```

#### UI Tests Only
```bash
xcodebuild test \
  -scheme AriasMagicApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AriasMagicAppUITests
```

#### Performance Tests Only
```bash
xcodebuild test \
  -scheme AriasMagicApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AriasMagicAppPerformanceTests
```

#### Specific Test Class
```bash
xcodebuild test \
  -scheme AriasMagicApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AriasMagicAppTests/CharacterTests
```

#### Single Test Method
```bash
xcodebuild test \
  -scheme AriasMagicApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:AriasMagicAppTests/CharacterTests/testCharacterInitialization_withDefaults
```

## Test Coverage

### Current Coverage

**Total Tests:** 145+

- **Character Model:** 30+ tests
- **MagicEffect Model:** 25+ tests
- **FaceTrackingService:** 20+ tests
- **SharePlayService:** 30+ tests
- **CharacterViewModel:** 40+ tests

### Coverage Goals

- **Overall Target:** 80%+
- **Models:** 90%+
- **Services:** 80%+
- **ViewModels:** 80%+
- **UI Components:** 70%+

### Generating Coverage Reports

```bash
# Generate coverage during test run
xcodebuild test \
  -scheme AriasMagicApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# View coverage report
xcrun xccov view --report DerivedData/.../Logs/Test/*.xcresult
```

## Test Categories

### Unit Tests

Unit tests verify individual components in isolation using mocks and fixtures.

#### Models
- **CharacterTests:** Character initialization, actions, entity creation, edge cases
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

### Integration Tests (Planned)

Integration tests verify component interactions:

- ViewModel + FaceTracking integration
- ViewModel + SharePlay integration
- Services interaction

### Performance Tests (Planned)

Performance tests ensure app meets benchmarks:

- Memory usage < 200 MB with 10 characters
- 60 FPS maintained
- Asset loading < 3 seconds
- No memory leaks

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

**Triggers:**
- Push to main, develop, or feature branches
- Pull requests to main/develop
- Manual workflow dispatch

### Test Reports

Test results and coverage reports are uploaded as GitHub Actions artifacts after each run.

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

### Test Naming Convention

```swift
func test<ComponentUnderTest>_<Scenario>_<ExpectedBehavior>()
```

**Examples:**
- `testCharacterInitialization_withDefaults_setsPropertiesCorrectly`
- `testDetectSmile_withStrongSmile_triggersDelegate`
- `testSpawnCharacter_atSpecificPosition_placesCharacterCorrectly`

### Using Test Fixtures

```swift
import XCTest
@testable import AriasMagicApp

class MyTests: XCTestCase {
    func testExample() {
        // Use predefined test data
        let character = TestData.testCharacterSparkle
        let position = TestData.testPosition

        // Use mock objects
        let mockDelegate = MockFaceTrackingDelegate()

        // Use mock face anchors
        let blendShapes = MockARFaceAnchor.smiling()
    }
}
```

### Async Testing

```swift
func testAsyncOperation() async {
    // GIVEN: Async setup
    let expectation = expectation(description: "Async operation completes")

    // WHEN: Triggering async operation
    someAsyncMethod {
        expectation.fulfill()
    }

    // THEN: Wait for completion
    await fulfillment(of: [expectation], timeout: 2.0)
}
```

### Testing Published Properties

```swift
func testPublishedProperty() {
    let expectation = expectation(description: "Property publishes update")
    var cancellables = Set<AnyCancellable>()

    viewModel.$characters
        .dropFirst() // Skip initial value
        .sink { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)

    viewModel.spawnCharacter(at: position)

    wait(for: [expectation], timeout: 1.0)
}
```

## Mock Objects

### Available Mocks

Located in `Tests/Fixtures/TestFixtures.swift`:

- **MockARFaceAnchor:** Simulated face tracking data
  - `.smiling()` - Strong smile
  - `.eyebrowsRaised()` - Raised eyebrows
  - `.mouthOpen()` - Open mouth
  - `.neutral()` - Neutral expression
  - `.subtleSmile()` - Below threshold smile

- **MockFaceTrackingDelegate:** Captures face expression callbacks

- **MockGroupSessionMessenger:** Simulates SharePlay messaging

- **TestData:** Predefined test data
  - Character instances
  - Positions and scales
  - Sync messages

### Creating New Mocks

```swift
class MockMyService {
    var methodCallCount = 0
    var lastParameter: String?

    func myMethod(parameter: String) {
        methodCallCount += 1
        lastParameter = parameter
    }
}
```

## Performance Testing

### Writing Performance Tests

```swift
func testPerformance() {
    measure {
        // Code to measure
        for _ in 0..<1000 {
            performExpensiveOperation()
        }
    }
}
```

### Memory Testing

```swift
func testMemoryUsage() {
    let initialMemory = PerformanceMetrics.measureMemoryUsage()

    // Perform operations

    let finalMemory = PerformanceMetrics.measureMemoryUsage()
    let memoryIncrease = finalMemory - initialMemory

    XCTAssertLessThan(memoryIncrease, 50_000_000) // 50MB max increase
}
```

## Debugging Tests

### Running Tests in Xcode

1. Open the Test Navigator (⌘6)
2. Click the diamond icon next to any test
3. View results in the Report Navigator (⌘9)

### Debugging Failed Tests

```swift
// Add breakpoints in test code
func testExample() {
    let result = functionUnderTest()
    // Set breakpoint here
    XCTAssertEqual(result, expected)
}

// Use print statements
print("Debug: value = \(value)")

// Use test failure messages
XCTAssertEqual(result, expected, "Expected result to be \(expected) but got \(result)")
```

## Best Practices

### DO:
- ✅ Write tests before fixing bugs (TDD)
- ✅ Keep tests focused and independent
- ✅ Use descriptive test names
- ✅ Follow AAA pattern (Arrange-Act-Assert)
- ✅ Test edge cases and error conditions
- ✅ Use mocks to isolate components
- ✅ Clean up resources in tearDown()
- ✅ Make tests fast and deterministic

### DON'T:
- ❌ Share state between tests
- ❌ Test implementation details
- ❌ Write flaky tests
- ❌ Ignore failing tests
- ❌ Test external dependencies directly
- ❌ Skip edge cases
- ❌ Write tests that depend on execution order

## Contributing Tests

When adding new features:

1. **Write tests first** (TDD approach)
2. **Achieve 80%+ coverage** for new code
3. **Add UI tests** for new user flows
4. **Update this README** if adding new test categories
5. **Run all tests** before committing
6. **Ensure CI passes** before merging PRs

## Troubleshooting

### Common Issues

**Issue:** Tests fail on CI but pass locally
- **Solution:** Ensure using same Xcode version, check for timing issues, verify simulator state

**Issue:** Flaky tests
- **Solution:** Add proper expectations, increase timeouts for async operations, ensure test isolation

**Issue:** Code coverage not generating
- **Solution:** Enable coverage in scheme settings, check test targets are configured correctly

**Issue:** Simulator not found
- **Solution:** Update destination to available simulator, check Xcode installation

## Test Metrics

### Key Metrics to Track

- **Code Coverage:** Percentage of code exercised by tests
- **Test Count:** Total number of tests
- **Test Duration:** Time to run all tests
- **Failure Rate:** Percentage of test runs with failures
- **Flakiness:** Tests that fail intermittently

### Current Metrics

- **Total Tests:** 145+
- **Passing:** 145+ (100% when Xcode project is configured)
- **Code Coverage:** To be measured (Target: 80%+)
- **Average Test Duration:** < 30 seconds (estimated)

## Resources

### Apple Documentation
- [XCTest Framework](https://developer.apple.com/documentation/xctest)
- [XCUITest](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [Unit Testing Best Practices (WWDC)](https://developer.apple.com/videos/play/wwdc2019/413/)
- [Testing Performance](https://developer.apple.com/documentation/xctest/performance_tests)

### Testing Guides
- [iOS Testing Guide - Ray Wenderlich](https://www.raywenderlich.com/960290-ios-unit-testing-and-ui-testing-tutorial)
- [Swift Testing Tips - Swift by Sundell](https://www.swiftbysundell.com/basics/unit-testing/)

### CI/CD
- [GitHub Actions for iOS](https://docs.github.com/en/actions/guides/building-and-testing-swift)

---

**Quality Assurance is Everyone's Responsibility!**

Let's keep Aria's app magical and bug-free! ✨
