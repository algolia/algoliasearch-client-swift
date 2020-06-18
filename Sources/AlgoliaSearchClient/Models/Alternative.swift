//
//  Alternative.swift
//  
//
//  Created by Vladislav Fitc on 23/03/2020.
//

import Foundation

public struct Alternative: Codable {
  public let types: [AlternativeType]
  public let words: [String]
  public let typos: Int
  public let offset: Int
  public let length: Int
}
