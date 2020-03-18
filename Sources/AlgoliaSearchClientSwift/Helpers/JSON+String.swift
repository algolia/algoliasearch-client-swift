//
//  JSON+String.swift
//  
//
//  Created by Vladislav Fitc on 13.03.2020.
//

import Foundation

public extension JSON {
  
  init(jsonString: String) throws {
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    self = try decoder.decode(JSON.self, from: data)
  }
  
}
