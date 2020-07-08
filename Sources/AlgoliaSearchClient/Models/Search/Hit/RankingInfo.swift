//
//  RankingInfo.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

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
