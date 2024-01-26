//
//  AlgoliaError.swift
//
//
//  Created by Algolia on 22/12/2023.
//

import Foundation

public struct GenericError: Error, CustomStringConvertible {
  public var description: String

  public init(description: String) {
    self.description = description
  }
}

public struct ErrorMessage: Codable, CustomStringConvertible {

  enum CodingKeys: String, CodingKey {
    case description = "message"
  }

  public let description: String

}
