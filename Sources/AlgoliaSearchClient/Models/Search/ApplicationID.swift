//
//  ApplicationID.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct ApplicationID: StringWrapper {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

}
