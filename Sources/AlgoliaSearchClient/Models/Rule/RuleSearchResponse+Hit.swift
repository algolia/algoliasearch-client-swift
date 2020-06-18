//
//  RuleSearchResponse+Hit.swift
//  
//
//  Created by Vladislav Fitc on 05/05/2020.
//

import Foundation

extension RuleSearchResponse {

  public struct Hit {

    public let rule: Rule
    public let highlightResult: TreeModel<HighlightResult>

  }

}

extension RuleSearchResponse.Hit: Codable {

  enum CodingKeys: String, CodingKey {
    case highlightResult = "_highlightResult"
  }

  public init(from decoder: Decoder) throws {
    self.rule = try .init(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.highlightResult = try container.decode(forKey: .highlightResult)
  }

  public func encode(to encoder: Encoder) throws {
    try rule.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(highlightResult, forKey: .highlightResult)
  }

}
