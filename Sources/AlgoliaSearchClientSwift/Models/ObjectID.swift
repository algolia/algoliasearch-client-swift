//
//  ObjectID.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public struct ObjectID: StringWrapper {
    
  public var rawValue: String
    
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
}
