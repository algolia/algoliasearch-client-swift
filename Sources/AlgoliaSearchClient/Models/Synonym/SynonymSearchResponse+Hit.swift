//
//  SynonymSearchResponse+Hit.swift
//  
//
//  Created by Vladislav Fitc on 20/05/2020.
//

import Foundation

extension SynonymSearchResponse {

  public struct Hit {

    public let synonym: Synonym
    public let highlightResult: TreeModel<HighlightResult>

  }

}

extension SynonymSearchResponse.Hit: Codable {

  enum CodingKeys: String, CodingKey {
    case highlightResult = "_highlightResult"
  }

  public init(from decoder: Decoder) throws {
    self.synonym = try .init(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.highlightResult = try container.decode(forKey: .highlightResult)
  }

  public func encode(to encoder: Encoder) throws {
    try synonym.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(highlightResult, forKey: .highlightResult)
  }

}
