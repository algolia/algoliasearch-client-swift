//
//  Hit.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

/// Wraps a generic hit object with its meta information

public struct Hit<T: Codable>: Codable {
  
    public let objectID: String
    public let object: T
    public let snippetResult: TreeModel<SnippetResult>?
    public let highlightResult: TreeModel<HighlightResult>?
    public let rankingInfo: RankingInfo?
//    public let geolocation: Place.Geolocation?
    
    enum CodingKeys: String, CodingKey {
        case objectID
        case snippetResult = "_snippetResult"
        case highlightResult = "_highlightResult"
        case rankingInfo = "_rankingInfo"
//        case geolocation = "_geoloc"
    }
  
    public init(objectID: String, object: T) {
        self.objectID = objectID
        self.object = object
        self.snippetResult = nil
        self.highlightResult = nil
        self.rankingInfo = nil
//        self.geolocation = nil
    }
    
    public init(from decoder: Decoder) throws {
        self.object = try T(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.objectID = try container.decode(String.self, forKey: .objectID)
        self.snippetResult = try container.decodeIfPresent(TreeModel<SnippetResult>.self, forKey: .snippetResult)
        self.highlightResult = try container.decodeIfPresent(TreeModel<HighlightResult>.self, forKey: .highlightResult)
        self.rankingInfo = try container.decodeIfPresent(RankingInfo.self, forKey: .rankingInfo)
//        self.geolocation = try container.decodeIfPresent(Place.Geolocation.self, forKey: .geolocation)
    }
    
}

extension Hit {
    
    /// Snippet result for an attribute of a hit.
    
    public struct SnippetResult: Codable, Hashable {
        /// Value of this snippet.
        public let value: String
        
        /// Match level.
        public let matchLevel: MatchLevel
    }
    
    /// Match level of a highlight or snippet result.
    
    public enum MatchLevel: String, Codable, Hashable, CustomStringConvertible {
        
        /// All the query terms were found in the attribute.
        case none
        
        /// Only some of the query terms were found in the attribute.
        case partial
        
        /// None of the query terms were found in the attribute.
        case full
        
        public var description: String {
            return self.rawValue
        }
        
    }
    
    /// Highlight result for an attribute of a hit.
    
    public struct HighlightResult: Codable, Hashable {
        /// Value of this highlight.
        public let value: HighlightedString
        
        /// Match level.
        public let matchLevel: MatchLevel
        
        /// List of matched words.
        public let matchedWords: [String]
    }
    
    /// Ranking info for a hit.
    
    public struct RankingInfo: Codable, Hashable {
        
        /// Number of typos encountered when matching the record.
        /// Corresponds to the `typos` ranking criterion in the ranking formula.
        public let typosCount: Int
        
        /// Position of the most important matched attribute in the attributes to index list.
        /// Corresponds to the `attribute` ranking criterion in the ranking formula.
        public let firstMatchedWord: Int
        
        /// When the query contains more than one word, the sum of the distances between matched words.
        /// Corresponds to the `proximity` criterion in the ranking formula.
        public let proximityDistance: Int
        
        /// Custom ranking for the object, expressed as a single numerical value.
        /// Conceptually, it's what the position of the object would be in the list of all objects sorted by custom ranking.
        /// Corresponds to the `custom` criterion in the ranking formula.
        public let userScore: Int
        
        /// Distance between the geo location in the search query and the best matching geo location in the record, divided
        /// by the geo precision.
        public let geoDistance: Int
        
        /// Precision used when computed the geo distance, in meters.
        /// All distances will be floored to a multiple of this precision.
        public let geoPrecision: Int
        
        /// Number of exactly matched words.
        /// If `alternativeAsExact` is set, it may include plurals and/or synonyms.
        public let exactWordsCount: Int
        
        /// Number of matched words, including prefixes and typos.
        public let words: Int
        
        /// Score from filters.
        /// + Warning: *This field is reserved for advanced usage.* It will be zero in most cases.
        public let filters: Int
        
        public enum CodingKeys: String, CodingKey {
            case typosCount = "nbTypos"
            case firstMatchedWord
            case proximityDistance
            case userScore
            case geoDistance
            case geoPrecision
            case exactWordsCount = "nbExactWords"
            case words
            case filters
        }
        
    }
    
}
