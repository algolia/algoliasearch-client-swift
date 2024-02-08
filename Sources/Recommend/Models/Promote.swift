// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public enum Promote: Codable, JSONEncodable, AbstractEncodable, Hashable {
    case promoteObjectID(PromoteObjectID)
    case promoteObjectIDs(PromoteObjectIDs)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .promoteObjectID(value):
            try container.encode(value)
        case let .promoteObjectIDs(value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(PromoteObjectID.self) {
            self = .promoteObjectID(value)
        } else if let value = try? container.decode(PromoteObjectIDs.self) {
            self = .promoteObjectIDs(value)
        } else {
            throw DecodingError.typeMismatch(Self.Type.self, .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode instance of Promote"))
        }
    }

    public func GetActualInstance() -> Encodable {
        switch self {
        case let .promoteObjectID(value):
            return value as PromoteObjectID
        case let .promoteObjectIDs(value):
            return value as PromoteObjectIDs
        }
    }
}