import XCTest
import simd
@testable import AriasMagicApp

final class CharacterStateTests: XCTestCase {
    func testInitialization() {
        let id = UUID()
        let type = CharacterType.sparkleThePrincess
        let position = SIMD3<Float>(1, 2, 3)
        let scale: Float = 1.5
        
        let state = CharacterState(id: id, type: type, position: position, scale: scale)
        
        XCTAssertEqual(state.id, id)
        XCTAssertEqual(state.type, type)
        XCTAssertEqual(state.position, position)
        XCTAssertEqual(state.scale, scale)
        XCTAssertEqual(state.currentAction, .idle)
        XCTAssertFalse(state.isHidden)
    }
    
    func testCodable() throws {
        let state = CharacterState(
            id: UUID(),
            type: .lunaTheStarDancer,
            position: SIMD3<Float>(0.5, 0, -0.5),
            scale: 2.0,
            currentAction: .dance,
            isHidden: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)
        
        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(CharacterState.self, from: data)
        
        XCTAssertEqual(state.id, decodedState.id)
        XCTAssertEqual(state.type, decodedState.type)
        XCTAssertEqual(state.position, decodedState.position)
        XCTAssertEqual(state.scale, decodedState.scale)
        XCTAssertEqual(state.currentAction, decodedState.currentAction)
        XCTAssertEqual(state.isHidden, decodedState.isHidden)
    }
}

