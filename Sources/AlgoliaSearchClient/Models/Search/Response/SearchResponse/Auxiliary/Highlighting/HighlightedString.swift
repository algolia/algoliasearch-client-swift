//
//  HighlightedString.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

public struct HighlightedString: Codable, Hashable {

  public static var preTag = "<em>"
  public static var postTag = "</em>"

  public let taggedString: TaggedString

  public init(string: String) {
    self.taggedString = TaggedString(string: string, preTag: HighlightedString.preTag, postTag: HighlightedString.postTag, options: [.caseInsensitive, .diacriticInsensitive])
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decodedString = try container.decode(String.self)
    self.init(string: decodedString)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(taggedString.input)
  }

}
