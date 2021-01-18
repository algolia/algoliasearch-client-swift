//
//  AnswersQuery+Language.swift
//  
//
//  Created by Vladislav Fitc on 20/11/2020.
//

import Foundation

extension AnswersQuery {

  public enum Language: RawRepresentable, Codable {

    case english
    case custom(String)

    public var rawValue: AlgoliaSearchClient.Language {
      switch self {
      case .english:
        return .english
      case .custom(let rawValue):
        return .init(rawValue: rawValue)
      }
    }

    public init(rawValue: AlgoliaSearchClient.Language) {
      switch rawValue {
      case .english:
        self = .english
      default:
        self = .custom(rawValue.rawValue)
      }
    }

    public init(from decoder: Decoder) throws {
      let rawLanguage = try AlgoliaSearchClient.Language(from: decoder)
      self.init(rawValue: rawLanguage)
    }

    public func encode(to encoder: Encoder) throws {
      try rawValue.encode(to: encoder)
    }

  }

}
