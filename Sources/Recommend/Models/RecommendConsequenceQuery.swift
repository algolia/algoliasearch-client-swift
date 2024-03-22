// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Replace or edit the search query.  If &#x60;consequenceQuery&#x60; is a string, the entire search query is replaced
/// with that string. If &#x60;consequenceQuery&#x60; is an object, it describes incremental edits made to the query.
public enum RecommendConsequenceQuery: Codable, JSONEncodable, AbstractEncodable {
    case recommendConsequenceQueryObject(RecommendConsequenceQueryObject)
    case string(String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .recommendConsequenceQueryObject(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(RecommendConsequenceQueryObject.self) {
            self = .recommendConsequenceQueryObject(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(
                Self.Type.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode instance of RecommendConsequenceQuery"
                )
            )
        }
    }

    public func GetActualInstance() -> Encodable {
        switch self {
        case let .recommendConsequenceQueryObject(value):
            value as RecommendConsequenceQueryObject
        case let .string(value):
            value as String
        }
    }
}
