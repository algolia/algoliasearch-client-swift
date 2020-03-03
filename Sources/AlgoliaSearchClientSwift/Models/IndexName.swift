//
//  IndexName.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

public struct IndexName: StringWrapper {
    
  public var rawValue: String
  
  func toPath(withSuffix suffix: String = "") -> String {
    return "\(Route.indexesV1)/\(rawValue.utf8)" + suffix
  }
    
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
}
