//
//  AlgoliaError.swift
//
//
//  Created by Algolia on 22/12/2023.
//

import Foundation

public struct AlgoliaError: Error, CustomStringConvertible {
  public var description: String

  public init(errorMessage: String) {
    self.description = errorMessage
  }
}

public struct ErrorMessage: Codable, CustomStringConvertible {

  enum CodingKeys: String, CodingKey {
    case description = "message"
  }

  public let description: String

}
