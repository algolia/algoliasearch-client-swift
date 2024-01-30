//
//  Empty.swift
//
//
//  Created by Vladislav Fitc on 30/03/2020.
//

import Foundation

public struct Empty: Codable {
  public static let empty: Self = .init()

  public init() {}

  public init(from _: Decoder) throws {
    self.init()
  }

  public func encode(to _: Encoder) throws {}
}
