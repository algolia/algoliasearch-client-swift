//
//  DictionarySearchResponse.swift
//  
//
//  Created by Vladislav Fitc on 21/01/2021.
//

import Foundation

public struct DictionarySearchResponse<E: DictionaryEntry> {

  public let hits: [E]
  public let nbHits: Int
  public let page: Int
  public let nbPages: Int

  public init(hits: [E], nbHits: Int, page: Int, nbPages: Int) {
    self.hits = hits
    self.nbHits = nbHits
    self.page = page
    self.nbPages = nbPages
  }

}

extension DictionarySearchResponse: Encodable where E: Encodable {}
extension DictionarySearchResponse: Decodable where E: Decodable {}
