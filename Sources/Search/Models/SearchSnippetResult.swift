// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public enum SearchSnippetResult: Codable, JSONEncodable, AbstractEncodable {
    case searchSnippetResultOption(SearchSnippetResultOption)
    case dictionaryOfStringToSearchSnippetResultOption([String: SearchSnippetResultOption])
    case arrayOfSearchSnippetResultOption([SearchSnippetResultOption])

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .searchSnippetResultOption(value):
            try container.encode(value)
        case let .dictionaryOfStringToSearchSnippetResultOption(value):
            try container.encode(value)
        case let .arrayOfSearchSnippetResultOption(value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(SearchSnippetResultOption.self) {
            self = .searchSnippetResultOption(value)
        } else if let value = try? container.decode([String: SearchSnippetResultOption].self) {
            self = .dictionaryOfStringToSearchSnippetResultOption(value)
        } else if let value = try? container.decode([SearchSnippetResultOption].self) {
            self = .arrayOfSearchSnippetResultOption(value)
        } else {
            throw DecodingError.typeMismatch(
                Self.Type.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode instance of SearchSnippetResult"
                )
            )
        }
    }

    public func GetActualInstance() -> Encodable {
        switch self {
        case let .searchSnippetResultOption(value):
            value as SearchSnippetResultOption
        case let .dictionaryOfStringToSearchSnippetResultOption(value):
            value as [String: SearchSnippetResultOption]
        case let .arrayOfSearchSnippetResultOption(value):
            value as [SearchSnippetResultOption]
        }
    }
}