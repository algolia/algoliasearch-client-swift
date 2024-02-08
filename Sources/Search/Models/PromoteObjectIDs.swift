// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

/** Records to promote. */
public struct PromoteObjectIDs: Codable, JSONEncodable, Hashable {
    /** Unique identifiers of the records to promote. */
    public var objectIDs: [String]
    /** The position to promote the records to. If you pass objectIDs, the records are placed at this position as a group. For example, if you pronmote four objectIDs to position 0, the records take the first four positions. */
    public var position: Int

    public init(objectIDs: [String], position: Int) {
        self.objectIDs = objectIDs
        self.position = position
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case objectIDs
        case position
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(objectIDs, forKey: .objectIDs)
        try container.encode(position, forKey: .position)
    }
}