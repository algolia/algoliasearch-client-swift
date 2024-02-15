// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

// MARK: - SnippetResult

public enum SnippetResult: Codable, JSONEncodable, AbstractEncodable, Hashable {
    case snippetResultOption(SnippetResultOption)
    case arrayOfSnippetResultOption([SnippetResultOption])
    case dictionaryOfStringToSnippetResultOption([String: SnippetResultOption])

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(SnippetResultOption.self) {
            self = .snippetResultOption(value)
        } else if let value = try? container.decode([SnippetResultOption].self) {
            self = .arrayOfSnippetResultOption(value)
        } else if let value = try? container.decode([String: SnippetResultOption].self) {
            self = .dictionaryOfStringToSnippetResultOption(value)
        } else {
            throw DecodingError.typeMismatch(
                Self.Type.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode instance of SnippetResult")
            )
        }
    }

    // MARK: Public

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .snippetResultOption(value):
            try container.encode(value)
        case let .arrayOfSnippetResultOption(value):
            try container.encode(value)
        case let .dictionaryOfStringToSnippetResultOption(value):
            try container.encode(value)
        }
    }

    public func GetActualInstance() -> Encodable {
        switch self {
        case let .snippetResultOption(value):
            value as SnippetResultOption
        case let .arrayOfSnippetResultOption(value):
            value as [SnippetResultOption]
        case let .dictionaryOfStringToSnippetResultOption(value):
            value as [String: SnippetResultOption]
        }
    }
}
