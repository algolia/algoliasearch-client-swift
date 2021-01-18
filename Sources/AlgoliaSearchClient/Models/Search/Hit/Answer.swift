//
//  Answer.swift
//  
//
//  Created by Vladislav Fitc on 19/11/2020.
//

import Foundation

public struct Answer: Codable, Hashable {

  /// String containing the answer
  public let extract: HighlightedString

  /// Attribute the answer is come from
  public let extractAttribute: Attribute

  /// Answer's confidence score
  public let score: Double

}
