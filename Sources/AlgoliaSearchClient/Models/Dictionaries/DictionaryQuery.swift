//
//  DictionaryQuery.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct DictionaryQuery: Codable {

  public var query: String

  public var page: Int?

  public var hitsPerPage: Int?

  public var language: Language?

  public init(query: String,
              page: Int? = nil,
              hitsPerPage: Int? = nil,
              language: Language? = nil) {
    self.query = query
    self.page = page
    self.hitsPerPage = hitsPerPage
    self.language = language
  }

}

extension DictionaryQuery: ExpressibleByStringInterpolation {

  public init(stringLiteral value: String) {
    self.init(query: value)
  }

}
