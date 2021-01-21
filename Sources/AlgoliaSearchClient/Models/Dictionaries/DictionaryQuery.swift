//
//  DictionaryQuery.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

public struct DictionaryQuery: Codable {
  
  let query: String
  
  let page: Int?
  
  let hitsPerPage: Int?
  
  let language: Language?
  
}
