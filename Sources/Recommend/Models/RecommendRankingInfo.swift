// Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on
// https://github.com/algolia/api-clients-automation. DO NOT EDIT.

import Foundation
#if canImport(Core)
    import Core
#endif

/// Object with detailed information about the record&#39;s ranking.
public struct RecommendRankingInfo: Codable, JSONEncodable {
    /// Whether a filter matched the query.
    public var filters: Int
    /// Position of the first matched word in the best matching attribute of the record.
    public var firstMatchedWord: Int
    /// Distance between the geo location in the search query and the best matching geo location in the record, divided
    /// by the geo precision (in meters).
    public var geoDistance: Int
    /// Precision used when computing the geo distance, in meters.
    public var geoPrecision: Int?
    public var matchedGeoLocation: RecommendMatchedGeoLocation?
    public var personalization: RecommendPersonalization?
    /// Number of exactly matched words.
    public var nbExactWords: Int
    /// Number of typos encountered when matching the record.
    public var nbTypos: Int
    /// Whether the record was promoted by a rule.
    public var promoted: Bool
    /// Number of words between multiple matches in the query plus 1. For single word queries, `proximityDistance` is 0.
    public var proximityDistance: Int?
    /// Overall ranking of the record, expressed as a single integer. This attribute is internal.
    public var userScore: Int
    /// Number of matched words.
    public var words: Int
    /// Whether the record is re-ranked.
    public var promotedByReRanking: Bool?

    public init(
        filters: Int,
        firstMatchedWord: Int,
        geoDistance: Int,
        geoPrecision: Int? = nil,
        matchedGeoLocation: RecommendMatchedGeoLocation? = nil,
        personalization: RecommendPersonalization? = nil,
        nbExactWords: Int,
        nbTypos: Int,
        promoted: Bool,
        proximityDistance: Int? = nil,
        userScore: Int,
        words: Int,
        promotedByReRanking: Bool? = nil
    ) {
        self.filters = filters
        self.firstMatchedWord = firstMatchedWord
        self.geoDistance = geoDistance
        self.geoPrecision = geoPrecision
        self.matchedGeoLocation = matchedGeoLocation
        self.personalization = personalization
        self.nbExactWords = nbExactWords
        self.nbTypos = nbTypos
        self.promoted = promoted
        self.proximityDistance = proximityDistance
        self.userScore = userScore
        self.words = words
        self.promotedByReRanking = promotedByReRanking
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case filters
        case firstMatchedWord
        case geoDistance
        case geoPrecision
        case matchedGeoLocation
        case personalization
        case nbExactWords
        case nbTypos
        case promoted
        case proximityDistance
        case userScore
        case words
        case promotedByReRanking
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.filters, forKey: .filters)
        try container.encode(self.firstMatchedWord, forKey: .firstMatchedWord)
        try container.encode(self.geoDistance, forKey: .geoDistance)
        try container.encodeIfPresent(self.geoPrecision, forKey: .geoPrecision)
        try container.encodeIfPresent(self.matchedGeoLocation, forKey: .matchedGeoLocation)
        try container.encodeIfPresent(self.personalization, forKey: .personalization)
        try container.encode(self.nbExactWords, forKey: .nbExactWords)
        try container.encode(self.nbTypos, forKey: .nbTypos)
        try container.encode(self.promoted, forKey: .promoted)
        try container.encodeIfPresent(self.proximityDistance, forKey: .proximityDistance)
        try container.encode(self.userScore, forKey: .userScore)
        try container.encode(self.words, forKey: .words)
        try container.encodeIfPresent(self.promotedByReRanking, forKey: .promotedByReRanking)
    }
}
