import Foundation
import simd

public struct EffectState: Codable, Equatable, Sendable {
    public let id: UUID
    public let type: EffectType
    public let position: SIMD3<Float>
    public let createdAt: Date
    public let duration: TimeInterval
    
    public init(
        id: UUID = UUID(),
        type: EffectType,
        position: SIMD3<Float>,
        duration: TimeInterval = 3.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.duration = duration
        self.createdAt = createdAt
    }
    
    public var isExpired: Bool {
        return Date().timeIntervalSince(createdAt) > duration
    }
    
    enum CodingKeys: String, CodingKey {
        case id, type, position, createdAt, duration
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(EffectType.self, forKey: .type)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        
        let posArray = try container.decode([Float].self, forKey: .position)
        position = SIMD3<Float>(posArray[0], posArray[1], posArray[2])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(duration, forKey: .duration)
        
        try container.encode([position.x, position.y, position.z], forKey: .position)
    }
}

