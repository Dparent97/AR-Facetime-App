import XCTest
import simd
@testable import AriasMagicApp

final class CharacterStoreTests: XCTestCase {
    var store: CharacterStore!
    
    override func setUp() {
        super.setUp()
        store = CharacterStore()
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    func testSpawnCharacter() {
        let type = CharacterType.sparkleThePrincess
        let position = SIMD3<Float>(1, 0, 0)
        
        store.spawnCharacter(type: type, at: position)
        
        XCTAssertEqual(store.characters.count, 1)
        let character = store.characters.values.first
        XCTAssertEqual(character?.type, type)
        XCTAssertEqual(character?.position, position)
    }
    
    func testUpdateCharacter() {
        store.spawnCharacter(type: .sparkleThePrincess)
        guard let id = store.characters.keys.first else { return XCTFail() }
        
        let newPosition = SIMD3<Float>(2, 0, 0)
        let newScale: Float = 2.0
        
        store.updateCharacter(id: id, position: newPosition, scale: newScale)
        
        guard let character = store.characters[id] else { return XCTFail() }
        XCTAssertEqual(character.position, newPosition)
        XCTAssertEqual(character.scale, newScale)
    }
    
    func testRemoveCharacter() {
        store.spawnCharacter(type: .sparkleThePrincess)
        guard let id = store.characters.keys.first else { return XCTFail() }
        
        store.removeCharacter(id: id)
        
        XCTAssertTrue(store.characters.isEmpty)
    }
    
    func testPerformAction() {
        store.spawnCharacter(type: .sparkleThePrincess)
        guard let id = store.characters.keys.first else { return XCTFail() }
        
        store.performAction(id: id, action: .dance)
        
        XCTAssertEqual(store.characters[id]?.currentAction, .dance)
    }
    
    func testSpawnEffect() {
        let position = SIMD3<Float>(1, 1, 1)
        store.spawnEffect(type: .sparkles, at: position)
        
        XCTAssertEqual(store.effects.count, 1)
        XCTAssertEqual(store.effects.first?.type, .sparkles)
        XCTAssertEqual(store.effects.first?.position, position)
    }
    
    func testClearAll() {
        store.spawnCharacter(type: .sparkleThePrincess)
        store.spawnEffect(type: .bubbles, at: .zero)
        
        store.clearAll()
        
        XCTAssertTrue(store.characters.isEmpty)
        XCTAssertTrue(store.effects.isEmpty)
    }
}

