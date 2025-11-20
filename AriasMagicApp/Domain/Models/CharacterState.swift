import Foundation
import simd

public struct CharacterState: Codable, Equatable, Sendable {
    public let id: UUID
    public let type: CharacterType
    public var position: SIMD3<Float>
    public var scale: Float
    public var rotation: simd_quatf
    public var currentAction: CharacterAction
    public var isHidden: Bool
    
    public init(
        id: UUID = UUID(),
        type: CharacterType,
        position: SIMD3<Float> = .zero,
        scale: Float = 1.0,
        rotation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
        currentAction: CharacterAction = .idle,
        isHidden: Bool = false
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.currentAction = currentAction
        self.isHidden = isHidden
    }
    
    // Manual Codable implementation for simd types if needed, 
    // but let's use the extension approach or a wrapper if standard Codable fails.
    // Since SIMD3<Float> and simd_quatf are not Codable by default in all Swift versions, 
    // I will add Codable conformance or use a wrapper.
    
    enum CodingKeys: String, CodingKey {
        case id, type, position, scale, rotation, currentAction, isHidden
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(CharacterType.self, forKey: .type)
        scale = try container.decode(Float.self, forKey: .scale)
        currentAction = try container.decode(CharacterAction.self, forKey: .currentAction)
        isHidden = try container.decode(Bool.self, forKey: .isHidden)
        
        let posArray = try container.decode([Float].self, forKey: .position)
        position = SIMD3<Float>(posArray[0], posArray[1], posArray[2])
        
        let rotArray = try container.decode([Float].self, forKey: .rotation)
        rotation = simd_quatf(ix: rotArray[0], iy: rotArray[1], iz: rotArray[2], r: rotArray[3])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(scale, forKey: .scale)
        try container.encode(currentAction, forKey: .currentAction)
        try container.encode(isHidden, forKey: .isHidden)
        
        try container.encode([position.x, position.y, position.z], forKey: .position)
        try container.encode([rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w], forKey: .rotation)
    }
}

