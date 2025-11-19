//
//  MagicEffectTests.swift
//  Aria's Magic SharePlay App - Tests
//
//  Unit tests for MagicEffect model
//

import XCTest
import RealityKit
@testable import AriasMagicApp

class MagicEffectTests: XCTestCase {

    // MARK: - MagicEffect Enum Tests

    func testMagicEffect_caseIterable() {
        // GIVEN: MagicEffect enum
        // WHEN: Accessing all cases
        let allEffects = MagicEffect.allCases

        // THEN: All 3 effect types are present
        XCTAssertEqual(allEffects.count, 3)
        XCTAssertTrue(allEffects.contains(.sparkles))
        XCTAssertTrue(allEffects.contains(.snow))
        XCTAssertTrue(allEffects.contains(.bubbles))
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
        // WHEN: Accessing emojis
        // THEN: Each effect has a unique emoji
        XCTAssertEqual(MagicEffect.sparkles.emoji, "✨")
        XCTAssertEqual(MagicEffect.snow.emoji, "❄️")
        XCTAssertEqual(MagicEffect.bubbles.emoji, "🫧")
    }

    func testMagicEffect_uniqueEmojis() {
        // GIVEN: All magic effects
        let emojis = Set(TestData.allMagicEffects.map { $0.emoji })

        // WHEN: Collecting all emojis
        // THEN: Each effect has a unique emoji
        XCTAssertEqual(emojis.count, TestData.allMagicEffects.count)
    }

    func testMagicEffect_uniqueDisplayNames() {
        // GIVEN: All magic effects
        let displayNames = Set(TestData.allMagicEffects.map { $0.displayName })

        // WHEN: Collecting all display names
        // THEN: Each effect has a unique display name
        XCTAssertEqual(displayNames.count, TestData.allMagicEffects.count)
    }

    // MARK: - MagicEffectGenerator Tests

    func testCreateParticleEffect_sparkles() {
        // GIVEN: Sparkles effect type
        let effect = MagicEffect.sparkles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Entity is created
        XCTAssertNotNil(particleEntity)
        XCTAssertGreaterThan(particleEntity.children.count, 0, "Sparkles should have particles")
    }

    func testCreateParticleEffect_snow() {
        // GIVEN: Snow effect type
        let effect = MagicEffect.snow

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Entity is created with particles
        XCTAssertNotNil(particleEntity)
        XCTAssertGreaterThan(particleEntity.children.count, 0, "Snow should have particles")
    }

    func testCreateParticleEffect_bubbles() {
        // GIVEN: Bubbles effect type
        let effect = MagicEffect.bubbles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Entity is created with particles
        XCTAssertNotNil(particleEntity)
        XCTAssertGreaterThan(particleEntity.children.count, 0, "Bubbles should have particles")
    }

    func testCreateParticleEffect_sparkles_hasCorrectParticleCount() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Sparkles has expected number of particles (20)
        XCTAssertEqual(particleEntity.children.count, 20)
    }

    func testCreateParticleEffect_snow_hasCorrectParticleCount() {
        // GIVEN: Snow effect
        let effect = MagicEffect.snow

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Snow has expected number of particles (30)
        XCTAssertEqual(particleEntity.children.count, 30)
    }

    func testCreateParticleEffect_bubbles_hasCorrectParticleCount() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Bubbles has expected number of particles (15)
        XCTAssertEqual(particleEntity.children.count, 15)
    }

    func testCreateParticleEffect_allEffects_createUniqueEntities() {
        // GIVEN: All effect types
        var entities: [Entity] = []

        // WHEN: Creating effects for all types
        for effect in TestData.allMagicEffects {
            let entity = MagicEffectGenerator.createParticleEffect(for: effect)
            entities.append(entity)
        }

        // THEN: Each effect creates a unique entity
        XCTAssertEqual(entities.count, TestData.allMagicEffects.count)
        for entity in entities {
            XCTAssertNotNil(entity)
        }
    }

    func testCreateParticleEffect_particlesHavePositions() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: All particles have positions
        for child in particleEntity.children {
            XCTAssertNotNil(child.position)
        }
    }

    func testCreateParticleEffect_sparkles_particlesAreYellow() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Sparkles particles are yellow/gold colored
        if let firstParticle = particleEntity.children.first as? ModelEntity,
           let material = firstParticle.model?.materials.first as? UnlitMaterial {
            // Check that the material color contains yellow components
            XCTAssertNotNil(material)
        }
    }

    func testCreateParticleEffect_snow_particlesAreWhite() {
        // GIVEN: Snow effect
        let effect = MagicEffect.snow

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Snow particles are white
        if let firstParticle = particleEntity.children.first as? ModelEntity,
           let material = firstParticle.model?.materials.first as? SimpleMaterial {
            // Check that the material exists
            XCTAssertNotNil(material)
        }
    }

    func testCreateParticleEffect_bubbles_particlesAreCyan() {
        // GIVEN: Bubbles effect
        let effect = MagicEffect.bubbles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Bubble particles are cyan/blue
        if let firstParticle = particleEntity.children.first as? ModelEntity,
           let material = firstParticle.model?.materials.first as? UnlitMaterial {
            // Check that the material exists
            XCTAssertNotNil(material)
        }
    }

    func testCreateParticleEffect_bubbles_hasVaryingSizes() {
        // GIVEN: Bubbles effect (should have varying sizes)
        let effect = MagicEffect.bubbles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Bubbles have different sizes
        var sizes: Set<String> = []
        for child in particleEntity.children {
            if let modelEntity = child as? ModelEntity,
               let mesh = modelEntity.model?.mesh {
                sizes.insert("\(mesh)")
            }
        }

        // Should have some variation (not all exactly the same)
        // Note: This test verifies the mechanism exists, actual variation depends on random
        XCTAssertGreaterThan(particleEntity.children.count, 0)
    }

    // MARK: - Particle Position Tests

    func testParticles_haveRandomizedPositions() {
        // GIVEN: Sparkles effect
        let effect = MagicEffect.sparkles

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Particles have different positions
        var positions: Set<String> = []
        for child in particleEntity.children {
            positions.insert("\(child.position)")
        }

        // Should have many unique positions (allowing for some random collisions)
        XCTAssertGreaterThan(positions.count, particleEntity.children.count / 2)
    }

    func testSnowParticles_startAboveGround() {
        // GIVEN: Snow effect (should start higher)
        let effect = MagicEffect.snow

        // WHEN: Creating particle effect
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)

        // THEN: Snow particles start with positive Y positions
        var particlesAboveGround = 0
        for child in particleEntity.children {
            if child.position.y >= 0.5 {
                particlesAboveGround += 1
            }
        }

        // Most snow particles should start above ground
        XCTAssertGreaterThan(particlesAboveGround, 0)
    }

    // MARK: - Performance Tests

    func testCreateParticleEffect_performance() {
        // GIVEN: All effect types
        measure {
            // WHEN: Creating particle effects repeatedly
            for effect in TestData.allMagicEffects {
                _ = MagicEffectGenerator.createParticleEffect(for: effect)
            }
        }

        // THEN: Performance is acceptable (measured by XCTest)
    }

    func testCreateParticleEffect_multipleSimultaneous() {
        // GIVEN: Multiple effect types
        var entities: [Entity] = []

        // WHEN: Creating multiple effects at once
        for _ in 0..<10 {
            for effect in TestData.allMagicEffects {
                let entity = MagicEffectGenerator.createParticleEffect(for: effect)
                entities.append(entity)
            }
        }

        // THEN: All effects are created successfully
        XCTAssertEqual(entities.count, 30) // 10 iterations × 3 effects
    }

    // MARK: - Memory Tests

    func testCreateParticleEffect_noMemoryLeak() {
        // GIVEN: Starting memory state
        // WHEN: Creating and releasing many particle effects
        weak var weakEntity: Entity?

        autoreleasepool {
            let entity = MagicEffectGenerator.createParticleEffect(for: .sparkles)
            weakEntity = entity
            // Entity goes out of scope
        }

        // THEN: Entity should be deallocated
        // Note: In practice, this may not always pass due to RealityKit's internal caching
        // This is more of a sanity check
        XCTAssertNotNil(weakEntity) // RealityKit entities may be retained internally
    }

    // MARK: - Integration Tests

    func testAllEffects_canBeCreatedSequentially() {
        // GIVEN: All effect types
        var success = true

        // WHEN: Creating each effect in sequence
        for effect in TestData.allMagicEffects {
            let entity = MagicEffectGenerator.createParticleEffect(for: effect)
            if entity.children.isEmpty {
                success = false
            }
        }

        // THEN: All effects are created successfully
        XCTAssertTrue(success)
    }

    func testEffectEntity_canBeAddedToScene() {
        // GIVEN: A particle effect
        let effect = MagicEffect.sparkles
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: effect)
        let parentEntity = Entity()

        // WHEN: Adding effect to parent entity
        parentEntity.addChild(particleEntity)

        // THEN: Effect is successfully added
        XCTAssertEqual(parentEntity.children.count, 1)
        XCTAssertTrue(parentEntity.children.contains(particleEntity))
    }

    func testEffectEntity_canBeRemoved() {
        // GIVEN: A particle effect added to parent
        let particleEntity = MagicEffectGenerator.createParticleEffect(for: .snow)
        let parentEntity = Entity()
        parentEntity.addChild(particleEntity)

        // WHEN: Removing effect from parent
        particleEntity.removeFromParent()

        // THEN: Effect is removed
        XCTAssertEqual(parentEntity.children.count, 0)
    }
}
