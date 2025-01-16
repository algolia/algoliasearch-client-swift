// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

public struct FacetsScoring: Codable, JSONEncodable {
    /// Event score.
    public var score: Int
    /// Facet attribute name.
    public var facetName: String

    public init(score: Int, facetName: String) {
        self.score = score
        self.facetName = facetName
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case score
        case facetName
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.score, forKey: .score)
        try container.encode(self.facetName, forKey: .facetName)
    }
}

extension FacetsScoring: Equatable {
    public static func ==(lhs: FacetsScoring, rhs: FacetsScoring) -> Bool {
        lhs.score == rhs.score &&
            lhs.facetName == rhs.facetName
    }
}

extension FacetsScoring: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.score.hashValue)
        hasher.combine(self.facetName.hashValue)
    }
}