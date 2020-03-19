//
//  Result+Convenience.swift
//  
//
//  Created by Vladislav Fitc on 19/03/2020.
//

import Foundation

extension Result {
  
  func value() throws -> Success {
    switch self {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }
  
}
