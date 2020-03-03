//
//  Query.swift
//  
//
//  Created by Vladislav Fitc on 17.02.2020.
//

import Foundation

public struct Query: Codable {
    
  /**
   The text to search in the index.
   - Engine default: ""
   - seealso: [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/query/?language=swift)
  */
  public var query: String?
  
  /**
   Filter the query with numeric, facet and/or tag filters.
   - Engine default: ""
   - seealso:
   [Documentation](https://www.algolia.com/doc/api-reference/api-parameters/filters/?language=swift)
   */
  public var filters: String?
  
  public init(_ query: String?) {
    self.query = query
  }
    
}
