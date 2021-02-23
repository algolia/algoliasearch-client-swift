//
//  Optional+Convenience.swift
//  
//
//  Created by Vladislav Fitc on 22/02/2021.
//

import Foundation

extension Optional where Wrapped: Equatable {

  func isNilOrEqual(to value: Wrapped) -> Bool {
    return self == nil || self == value
  }

}
