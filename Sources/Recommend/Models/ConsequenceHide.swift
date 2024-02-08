// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

/** Unique identifier of the record to hide. */
public struct ConsequenceHide: Codable, JSONEncodable, Hashable {
    /** Unique object identifier. */
    public var objectID: String

    public init(objectID: String) {
        self.objectID = objectID
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case objectID
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(objectID, forKey: .objectID)
    }
}