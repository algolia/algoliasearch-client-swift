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
  public let snippetResult: TreeModel<SnippetResult>?
  public let highlightResult: TreeModel<HighlightResult>?
  public let rankingInfo: RankingInfo?
  public let geolocation: Point?

}

extension Hit: Equatable where T: Equatable {}

extension Hit: Codable {

  enum CodingKeys: String, CodingKey {
    case objectID
    case snippetResult = "_snippetResult"
    case highlightResult = "_highlightResult"
    case rankingInfo = "_rankingInfo"
    case geolocation = "_geoloc"
  }

  public init(from decoder: Decoder) throws {
    self.object = try T(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.objectID = try container.decode(ObjectID.self, forKey: .objectID)
    self.snippetResult = try container.decodeIfPresent(TreeModel<SnippetResult>.self, forKey: .snippetResult)
    self.highlightResult = try container.decodeIfPresent(TreeModel<HighlightResult>.self, forKey: .highlightResult)
    self.rankingInfo = try container.decodeIfPresent(RankingInfo.self, forKey: .rankingInfo)
    self.geolocation = try container.decodeIfPresent(Point.self, forKey: .geolocation)
  }

  public func encode(to encoder: Encoder) throws {
    var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
    try keyedContainer.encode(objectID, forKey: .objectID)
    try object.encode(to: encoder)
  }

}
