// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public enum HighlightResult: Codable, JSONEncodable, AbstractEncodable, Hashable {
    case highlightResultOption(HighlightResultOption)
    case arrayOfHighlightResultOption([HighlightResultOption])
    case dictionaryOfStringToHighlightResultOption([String: HighlightResultOption])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .highlightResultOption(value):
            try container.encode(value)
        case let .arrayOfHighlightResultOption(value):
            try container.encode(value)
        case let .dictionaryOfStringToHighlightResultOption(value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(HighlightResultOption.self) {
            self = .highlightResultOption(value)
        } else if let value = try? container.decode([HighlightResultOption].self) {
            self = .arrayOfHighlightResultOption(value)
        } else if let value = try? container.decode([String: HighlightResultOption].self) {
            self = .dictionaryOfStringToHighlightResultOption(value)
        } else {
            throw DecodingError.typeMismatch(Self.Type.self, .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode instance of HighlightResult"))
        }
    }

    public func GetActualInstance() -> Encodable {
        switch self {
        case let .highlightResultOption(value):
            return value as HighlightResultOption
        case let .arrayOfHighlightResultOption(value):
            return value as [HighlightResultOption]
        case let .dictionaryOfStringToHighlightResultOption(value):
            return value as [String: HighlightResultOption]
        }
    }
}