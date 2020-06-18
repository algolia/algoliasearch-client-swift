//
//  MultipleQueriesStrategy.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public struct MultipleQueriesStrategy: RawRepresentable, Codable {

  public var rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  /**
    Execute the sequence of queries until the end.
    This is recommended when each query is of equal importance, meaning all records of all queries need to be returned.
  */
  public static var none: Self { .init(rawValue: #function) }

  /**
   Execute queries one by one, but stop as soon as the cumulated number of hits is at least Query.hitsPerPage.
   This is recommended when each query is an alternative, and where, if the first returns enough records, there is no need to perform the remaining queries.
   */
  public static var stopIfEnoughMatches: Self { .init(rawValue: #function) }

}
