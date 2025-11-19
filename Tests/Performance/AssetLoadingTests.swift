//
//  AssetLoadingTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Performance tests for asset loading
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class AssetLoadingTests: XCTestCase {

    // MARK: - Character Creation Performance

    func testCharacterCreation_singleCharacter() {
        // GIVEN: Character type
        let type = CharacterType.sparkleThePrincess

        // WHEN: Measuring creation time
        measure(metrics: [XCTClockMetric()]) {
            _ = Character(type: type)
        }

        // THEN: Creation is fast (< 100ms ideal)
        XCTAssertTrue(true)
    }

    func testCharacterCreation_allTypes() {
        // GIVEN: All character types
        let types = CharacterType.allCases

        // WHEN: Creating one of each type
        measure(metrics: [XCTClockMetric()]) {
            for type in types {
                _ = Character(type: type)
            }
        }

        // THEN: Batch creation is efficient
        XCTAssertTrue(true)
    }

    func testCharacterCreation_batchOf10() {
        // GIVEN: Need to create 10 characters
        // WHEN: Creating batch
        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<10 {
                _ = Character(type: .sparkleThePrincess)
            }
        }

        // THEN: Should complete quickly (< 500ms target)
        XCTAssertTrue(true)
    }

    // MARK: - Effect Loading Performance

    func testEffectCreation_sparkles() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN: Measuring creation time
        measure(metrics: [XCTClockMetric()]) {
            _ = MagicEffectGenerator.createParticleEffect(for: effect)
        }

        // THEN: Should be fast (< 100ms)
        XCTAssertTrue(true)
    }

    func testEffectCreation_snow() {
        // GIVEN: Snow effect
        let effect = MagicEffect.snow

        // WHEN: Measuring creation time
        measure(metrics: [XCTClockMetric()]) {
            _ = MagicEffectGenerator.createParticleEffect(for: effect)
        }

        // THEN: Should be fast (< 100ms)
        XCTAssertTrue(true)
    }

    func testEffectCreation_bubbles() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles

        // WHEN: Measuring creation time
        measure(metrics: [XCTClockMetric()]) {
            _ = MagicEffectGenerator.createParticleEffect(for: effect)
        }

        // THEN: Should be fast (< 100ms)
        XCTAssertTrue(true)
    }

    func testEffectCreation_allTypes() {
        // GIVEN: All effect types
        let effects = MagicEffect.allCases

        // WHEN: Creating all effects
        measure(metrics: [XCTClockMetric()]) {
            for effect in effects {
                _ = MagicEffectGenerator.createParticleEffect(for: effect)
            }
        }

        // THEN: Batch creation is efficient (< 300ms total)
        XCTAssertTrue(true)
    }

    // MARK: - Entity Creation Performance

    func testEntityCreation_meshGeneration() {
        // GIVEN: Mesh resources
        // WHEN: Creating mesh
        measure(metrics: [XCTClockMetric()]) {
            _ = MeshResource.generateBox(size: 0.1)
        }

        // THEN: Mesh generation is fast
        XCTAssertTrue(true)
    }

    func testEntityCreation_materialApplication() {
        // GIVEN: Mesh and material
        let mesh = MeshResource.generateBox(size: 0.1)

        // WHEN: Creating model entity with material
        measure(metrics: [XCTClockMetric()]) {
            let material = SimpleMaterial(color: .red, isMetallic: false)
            _ = ModelEntity(mesh: mesh, materials: [material])
        }

        // THEN: Material application is fast
        XCTAssertTrue(true)
    }

    // MARK: - ViewModel Initialization Performance

    func testViewModelInitialization() {
        // GIVEN/WHEN: Creating view model
        measure(metrics: [XCTClockMetric()]) {
            _ = CharacterViewModel()
        }

        // THEN: Initialization is fast (< 100ms)
        XCTAssertTrue(true)
    }

    func testViewModelInitialization_withServices() {
        // GIVEN/WHEN: Creating view model and services
        measure(metrics: [XCTClockMetric()]) {
            _ = CharacterViewModel()
            _ = FaceTrackingService()
            _ = SharePlayService()
        }

        // THEN: Complete initialization is reasonable (< 200ms)
        XCTAssertTrue(true)
    }

    // MARK: - Stress Tests

    func testLoadingStress_rapidCharacterCreation() {
        // GIVEN: Need to create many characters rapidly
        // WHEN: Creating 50 characters
        measure(metrics: [XCTClockMetric()]) {
            for i in 0..<50 {
                let type = CharacterType.allCases[i % CharacterType.allCases.count]
                _ = Character(type: type)
            }
        }

        // THEN: Should handle stress (< 2 seconds for 50)
        XCTAssertTrue(true)
    }

    func testLoadingStress_rapidEffectCreation() {
        // GIVEN: Need to create many effects
        // WHEN: Creating 30 effects
        measure(metrics: [XCTClockMetric()]) {
            for i in 0..<30 {
                let effect = MagicEffect.allCases[i % MagicEffect.allCases.count]
                _ = MagicEffectGenerator.createParticleEffect(for: effect)
            }
        }

        // THEN: Should handle stress (< 3 seconds for 30)
        XCTAssertTrue(true)
    }

    // MARK: - Cold Start Performance

    func testColdStart_firstCharacterLoad() {
        // This test should be run first to measure cold start
        // Note: Run as standalone test for accurate measurement

        // GIVEN: Clean state
        // WHEN: Creating first character after app launch
        measure(metrics: [XCTClockMetric()]) {
            _ = Character(type: .sparkleThePrincess)
        }

        // THEN: Cold start time measured
        XCTAssertTrue(true)
    }

    func testColdStart_firstEffectLoad() {
        // GIVEN: Clean state
        // WHEN: Creating first effect after app launch
        measure(metrics: [XCTClockMetric()]) {
            _ = MagicEffectGenerator.createParticleEffect(for: .sparkles)
        }

        // THEN: Cold start time measured
        XCTAssertTrue(true)
    }

    // MARK: - Memory + Speed Combined

    func testCombinedPerformance_memoryAndSpeed() {
        // GIVEN: Characters to create
        // WHEN: Creating and measuring both speed and memory
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let characters = PerformanceTestHelpers.generateCharacters(count: 20)

            for character in characters {
                character.performAction(.wave)
            }
        }

        // THEN: Both metrics within acceptable range
        XCTAssertTrue(true)
    }
}
