//
//  Empty.swift
//  
//
//  Created by Vladislav Fitc on 30/03/2020.
//

import Foundation

struct Empty: Codable {
  
  init() {}
  
  init(from decoder: Decoder) throws {
    self.init()
  }
  
  func encode(to encoder: Encoder) throws {}
  
}
