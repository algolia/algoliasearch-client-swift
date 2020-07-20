//
//  HitWithPosition.swift
//  
//
//  Created by Vladislav Fitc on 31/03/2020.
//

import Foundation

public struct HitWithPosition<T: Codable>: Codable {

  public let hit: T
  public let page: Int
  public let position: Int

}
