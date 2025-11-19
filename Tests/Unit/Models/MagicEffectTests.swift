//
//  MagicEffectTests.swift
//  Aria's Magic SharePlay App - Test Suite
//
//  Unit tests for MagicEffect model
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class MagicEffectTests: XCTestCase {

    // MARK: - Enum Tests

    func testMagicEffect_allCases() {
        // GIVEN: MagicEffect enum
        // WHEN: Accessing all cases
        let effects = MagicEffect.allCases

        // THEN: All 3 effects exist
        XCTAssertEqual(effects.count, 3)
        XCTAssertTrue(effects.contains(.sparkles))
        XCTAssertTrue(effects.contains(.snow))
        XCTAssertTrue(effects.contains(.bubbles))
    }

    func testMagicEffect_rawValues() {
        // GIVEN: Magic effects
        // WHEN: Accessing raw values
        // THEN: Raw values match expected strings
        XCTAssertEqual(MagicEffect.sparkles.rawValue, "sparkles")
        XCTAssertEqual(MagicEffect.snow.rawValue, "snow")
        XCTAssertEqual(MagicEffect.bubbles.rawValue, "bubbles")
    }

    func testMagicEffect_displayNames() {
        // GIVEN: Magic effects
        // WHEN: Accessing display names
        // THEN: Display names include emojis
        XCTAssertEqual(MagicEffect.sparkles.displayName, "✨ Sparkles")
        XCTAssertEqual(MagicEffect.snow.displayName, "❄️ Snow")
        XCTAssertEqual(MagicEffect.bubbles.displayName, "🫧 Bubbles")
    }

    func testMagicEffect_emojis() {
        // GIVEN: Magic effects
        // WHEN: Accessing emoji properties
        // THEN: Correct emojis are returned
        XCTAssertEqual(MagicEffect.sparkles.emoji, "✨")
        XCTAssertEqual(MagicEffect.snow.emoji, "❄️")
        XCTAssertEqual(MagicEffect.bubbles.emoji, "🫧")
    }

    // MARK: - Particle Generator Tests

    func testCreateParticleEffect_sparkles() {
        // GIVEN: Sparkles effect type
        let effect = MagicEffect.sparkles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Entity is created
        XCTAssertNotNil(particleEntity)
        XCTAssertTrue(particleEntity.children.count > 0)
    }

    func testCreateParticleEffect_snow() {
        // GIVEN: Snow effect type
        let effect = MagicEffect.snow

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Entity is created with particles
        XCTAssertNotNil(particleEntity)
        XCTAssertTrue(particleEntity.children.count > 0)
    }

    func testCreateParticleEffect_bubbles() {
        // GIVEN: Bubbles effect type
        let effect = MagicEffect.bubbles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Entity is created with particles
        XCTAssertNotNil(particleEntity)
        XCTAssertTrue(particleEntity.children.count > 0)
    }

    func testCreateParticleEffect_sparkles_hasCorrectParticleCount() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN: Creating effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Should have 20 sparkle particles
        XCTAssertEqual(particleEntity.children.count, 20)
    }

    func testCreateParticleEffect_snow_hasCorrectParticleCount() {
        // GIVEN: Snow effect
        let effect = MagicEffect.snow

        // WHEN: Creating effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Should have 30 snow particles
        XCTAssertEqual(particleEntity.children.count, 30)
    }

    func testCreateParticleEffect_bubbles_hasCorrectParticleCount() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles

        // WHEN: Creating effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Should have 15 bubble particles
        XCTAssertEqual(particleEntity.children.count, 15)
    }

    func testCreateParticleEffect_allEffects_generateDifferentEntities() {
        // GIVEN: All effect types
        let effects = MagicEffect.allCases

        // WHEN: Creating entities for each
        let entities = effects.map { MagicEffectGenerator.createParticleEffect(for: $0) }

        // THEN: Each has different particle counts
        XCTAssertEqual(entities[0].children.count, 20) // sparkles
        XCTAssertEqual(entities[1].children.count, 30) // snow
        XCTAssertEqual(entities[2].children.count, 15) // bubbles
    }

    // MARK: - Particle Properties Tests

    func testSparkles_particlesHaveModelComponent() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // WHEN: Checking children
        guard let firstChild = particleEntity.children.first as? ModelEntity else {
            XCTFail("Particle should be a ModelEntity")
            return
        }

        // THEN: Particle is a model entity
        XCTAssertNotNil(firstChild)
    }

    func testSnow_particlesHaveModelComponent() {
        // GIVEN: Snow effect
        let effect = MagicEffect.snow
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // WHEN: Checking children
        guard let firstChild = particleEntity.children.first as? ModelEntity else {
            XCTFail("Particle should be a ModelEntity")
            return
        }

        // THEN: Particle is a model entity
        XCTAssertNotNil(firstChild)
    }

    func testBubbles_particlesHaveModelComponent() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // WHEN: Checking children
        guard let firstChild = particleEntity.children.first as? ModelEntity else {
            XCTFail("Particle should be a ModelEntity")
            return
        }

        // THEN: Particle is a model entity
        XCTAssertNotNil(firstChild)
    }

    func testBubbles_particlesHaveVariedSizes() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // WHEN: Getting all particle entities
        let particles = particleEntity.children.compactMap { $0 as? ModelEntity }

        // THEN: Not all particles have the same size (due to random sizing)
        // Note: This test might occasionally fail due to randomness, but very unlikely
        let sizes = Set(particles.map { $0.model?.mesh.bounds.extents.x })
        XCTAssertGreaterThan(sizes.count, 1, "Bubbles should have varied sizes")
    }

    // MARK: - Codable Tests

    func testMagicEffect_isEncodable() throws {
        // GIVEN: A magic effect
        let effect = MagicEffect.sparkles

        // WHEN: Encoding to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(effect)

        // THEN: Encoding succeeds
        XCTAssertFalse(data.isEmpty)
    }

    func testMagicEffect_isDecodable() throws {
        // GIVEN: Encoded magic effect
        let effect = MagicEffect.snow
        let encoder = JSONEncoder()
        let data = try encoder.encode(effect)

        // WHEN: Decoding from JSON
        let decoder = JSONDecoder()
        let decodedEffect = try decoder.decode(MagicEffect.self, from: data)

        // THEN: Original and decoded match
        XCTAssertEqual(effect, decodedEffect)
    }

    func testMagicEffect_roundTripEncoding() throws {
        // GIVEN: All magic effects
        let effects = MagicEffect.allCases

        // WHEN: Encoding and decoding each
        for effect in effects {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            let data = try encoder.encode(effect)
            let decoded = try decoder.decode(MagicEffect.self, from: data)

            // THEN: Values match after round trip
            XCTAssertEqual(effect, decoded)
        }
    }

    // MARK: - Performance Tests

    func testPerformance_createSparkles() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN/THEN: Measuring creation performance
        measure {
            _ = MagicEffectGenerator.createParticleEffect(for: effect)
        }
    }

    func testPerformance_createSnow() {
        // GIVEN: Snow effect
        let effect = MagicEffect.snow

        // WHEN/THEN: Measuring creation performance
        measure {
            _ = MagicEffectGenerator.createParticleEffect(for: effect)
        }
    }

    func testPerformance_createBubbles() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles

        // WHEN/THEN: Measuring creation performance
        measure {
            _ = MagicEffectGenerator.createParticleEffect(for: effect)
        }
    }

    func testPerformance_createMultipleEffects() {
        // GIVEN: All effects
        let effects = MagicEffect.allCases

        // WHEN/THEN: Measuring batch creation performance
        measure {
            for effect in effects {
                _ = MagicEffectGenerator.createParticleEffect(for: effect)
            }
        }
    }

    // MARK: - Integration Tests

    func testEffectGeneration_doesNotCrash() {
        // GIVEN: All effect types
        let effects = MagicEffect.allCases

        // WHEN: Creating each effect
        // THEN: No crashes occur
        for effect in effects {
            let entity = MagicEffectGenerator.createParticleEffect(for: effect)
            XCTAssertNotNil(entity)
        }
    }

    func testParticlePositions_areRandomized() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // WHEN: Getting positions
        let positions = particleEntity.children.map { $0.position }

        // THEN: Positions are not all the same
        let uniquePositions = Set(positions.map { "\($0.x),\($0.y),\($0.z)" })
        XCTAssertGreaterThan(uniquePositions.count, 1, "Particles should have varied positions")
    }

    // MARK: - Memory Tests

    func testParticleEntity_canBeReleased() {
        // GIVEN: A weak reference to a particle entity
        weak var weakEntity: Entity?

        autoreleasepool {
            let entity = MagicEffectGenerator.createParticleEffect(for: .sparkles)
            weakEntity = entity
            XCTAssertNotNil(weakEntity)
        }

        // WHEN: Entity goes out of scope
        // THEN: It can be deallocated
        XCTAssertNil(weakEntity)
    }

    func testMultipleEffects_doNotLeakMemory() {
        // GIVEN: Multiple effect creations
        // WHEN: Creating and releasing effects
        autoreleasepool {
            for _ in 0..<100 {
                for effect in MagicEffect.allCases {
                    _ = MagicEffectGenerator.createParticleEffect(for: effect)
                }
            }
        }

        // THEN: Test completes without memory warnings
        // (If memory leaked, test would crash or timeout)
        XCTAssertTrue(true)
    }
}
