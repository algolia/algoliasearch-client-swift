//
//  Hit.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

/// Wraps a generic hit object with its meta information

public struct Hit<T: Codable> {

  public let objectID: ObjectID
  public let object: T

  /// Snippeted attributes. Only returned when `attributesToSnippet` is non-empty.
  public let snippetResult: TreeModel<SnippetResult>?

  /// Highlighted attributes. Only returned when `attributesToHighlight` is non-empty.
  public let highlightResult: TreeModel<HighlightResult>?

  /// Ranking information. Only returned when `getRankingInfo` is true.
  public let rankingInfo: RankingInfo?
  public let geolocation: SingleOrList<Point>?

  /// Answer information
  public let answer: Answer?

}

extension Hit: Equatable where T: Equatable {}

extension Hit: Codable {

  enum CodingKeys: String, CodingKey {
    case objectID
    case snippetResult = "_snippetResult"
    case highlightResult = "_highlightResult"
    case rankingInfo = "_rankingInfo"
    case geolocation = "_geoloc"
    case answer = "_answer"
  }

  public init(from decoder: Decoder) throws {
    self.object = try T(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.objectID = try container.decode(ObjectID.self, forKey: .objectID)
    self.snippetResult = try container.decodeIfPresent(TreeModel<SnippetResult>.self, forKey: .snippetResult)
    self.highlightResult = try container.decodeIfPresent(TreeModel<HighlightResult>.self, forKey: .highlightResult)
    self.rankingInfo = try container.decodeIfPresent(RankingInfo.self, forKey: .rankingInfo)
    self.geolocation = try? container.decodeIfPresent(SingleOrList<Point>.self, forKey: .geolocation)
    self.answer = try container.decodeIfPresent(forKey: .answer)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(objectID, forKey: .objectID)
    try container.encodeIfPresent(objectID, forKey: .objectID)
    try container.encodeIfPresent(snippetResult, forKey: .snippetResult)
    try container.encodeIfPresent(highlightResult, forKey: .highlightResult)
    try container.encodeIfPresent(rankingInfo, forKey: .rankingInfo)
    try container.encodeIfPresent(geolocation, forKey: .geolocation)
    try container.encodeIfPresent(answer, forKey: .answer)
    try object.encode(to: encoder)
  }

}
