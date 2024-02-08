// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Core
import Foundation
#if canImport(AnyCodable)
    import AnyCodable
#endif

public enum RecommendationsRequest: Codable, JSONEncodable, AbstractEncodable, Hashable {
    case recommendationsQuery(RecommendationsQuery)
    case recommendedForYouQuery(RecommendedForYouQuery)
    case trendingFacetsQuery(TrendingFacetsQuery)
    case trendingItemsQuery(TrendingItemsQuery)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .recommendationsQuery(value):
            try container.encode(value)
        case let .recommendedForYouQuery(value):
            try container.encode(value)
        case let .trendingFacetsQuery(value):
            try container.encode(value)
        case let .trendingItemsQuery(value):
            try container.encode(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(RecommendationsQuery.self) {
            self = .recommendationsQuery(value)
        } else if let value = try? container.decode(RecommendedForYouQuery.self) {
            self = .recommendedForYouQuery(value)
        } else if let value = try? container.decode(TrendingFacetsQuery.self) {
            self = .trendingFacetsQuery(value)
        } else if let value = try? container.decode(TrendingItemsQuery.self) {
            self = .trendingItemsQuery(value)
        } else {
            throw DecodingError.typeMismatch(Self.Type.self, .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode instance of RecommendationsRequest"))
        }
    }

    public func GetActualInstance() -> Encodable {
        switch self {
        case let .recommendationsQuery(value):
            return value as RecommendationsQuery
        case let .recommendedForYouQuery(value):
            return value as RecommendedForYouQuery
        case let .trendingFacetsQuery(value):
            return value as TrendingFacetsQuery
        case let .trendingItemsQuery(value):
            return value as TrendingItemsQuery
        }
    }
}