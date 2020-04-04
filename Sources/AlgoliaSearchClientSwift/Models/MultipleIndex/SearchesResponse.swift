//
//  SearchesResponse.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

struct SearchesResponse: Codable {
  
  /**
    List of result in the order they were submitted, one element for each IndexQuery.
   */
  let results: [SearchResponse]
  
}
