//
//  Empty.swift
//  
//
//  Created by Vladislav Fitc on 30/03/2020.
//

import Foundation

public struct Empty: Codable {

  static let empty: Self = .init()
  
  init() {}

  public init(from decoder: Decoder) throws {
    self.init()
  }

  public func encode(to encoder: Encoder) throws {}

}
