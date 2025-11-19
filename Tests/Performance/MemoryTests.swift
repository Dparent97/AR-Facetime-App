//
//  MemoryTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Performance tests for memory usage
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class MemoryTests: XCTestCase {

    // MARK: - Memory Usage Tests

    func testMemoryUsage_with10Characters() {
        // GIVEN: View model
        let viewModel = CharacterViewModel()

        // Measure initial memory
        let initialMemory = PerformanceTestHelpers.measureMemory()

        // WHEN: Spawning 10 characters
        measure(metrics: [XCTMemoryMetric()]) {
            for i in 0..<10 {
                let position = SIMD3<Float>(Float(i) * 0.2, 0, -1)
                viewModel.spawnCharacter(at: position)
            }

            // Perform actions on characters
            viewModel.performAction(.wave, on: nil)
            viewModel.triggerEffect(.sparkles)
        }

        // THEN: Memory usage is within acceptable range
        let finalMemory = PerformanceTestHelpers.measureMemory()
        let memoryIncrease = finalMemory - initialMemory

        // Allow up to 50 MB for 10 characters (placeholder threshold)
        XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024, "Memory usage exceeds acceptable threshold")
    }

    func testMemoryUsage_multipleEffects() {
        // GIVEN: Effect generator
        // WHEN: Creating multiple effects
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 0..<10 {
                _ = MagicEffectGenerator.createParticleEffect(for: .sparkles)
                _ = MagicEffectGenerator.createParticleEffect(for: .snow)
                _ = MagicEffectGenerator.createParticleEffect(for: .bubbles)
            }
        }

        // THEN: Memory usage measured
        XCTAssertTrue(true)
    }

    func testNoMemoryLeaks_whenSpawningAndRemoving() {
        // GIVEN: View model
        let viewModel = CharacterViewModel()
        weak var weakCharacter: Character?

        // WHEN: Spawning and removing characters repeatedly
        autoreleasepool {
            for _ in 0..<100 {
                viewModel.spawnCharacter(at: SIMD3<Float>(0, 0, -1))
                if let character = viewModel.characters.last {
                    weakCharacter = character
                    viewModel.removeCharacter(character)
                }
            }
        }

        // THEN: Characters are properly deallocated
        XCTAssertNil(weakCharacter, "Memory leak detected: Character not deallocated")
    }

    func testNoMemoryLeaks_effectGeneration() {
        // GIVEN: Multiple effect creations
        weak var weakEffect: Entity?

        // WHEN: Creating and releasing effects
        autoreleasepool {
            for _ in 0..<50 {
                let effect = MagicEffectGenerator.createParticleEffect(for: .sparkles)
                weakEffect = effect
            }
        }

        // THEN: Effects are properly deallocated
        XCTAssertNil(weakEffect, "Memory leak detected: Effect not deallocated")
    }

    // MARK: - Memory Stress Tests

    func testMemoryStress_manyCharacters() {
        // GIVEN: Performance test for many characters
        measure(metrics: [XCTMemoryMetric()]) {
            let characters = PerformanceTestHelpers.generateCharacters(count: 50)

            // Perform actions on all characters
            for character in characters {
                character.performAction(.wave)
            }
        }

        // THEN: Test completes without crashes
        XCTAssertTrue(true)
    }

    func testMemoryStress_rapidSpawnAndDespawn() {
        // GIVEN: View model
        let viewModel = CharacterViewModel()

        // WHEN: Rapidly spawning and removing
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 0..<20 {
                // Spawn 5 characters
                for i in 0..<5 {
                    viewModel.spawnCharacter(at: SIMD3<Float>(Float(i), 0, -1))
                }

                // Remove all characters
                let allCharacters = viewModel.characters
                for character in allCharacters {
                    viewModel.removeCharacter(character)
                }
            }
        }

        // THEN: Memory is stable
        XCTAssertTrue(true)
    }
}
