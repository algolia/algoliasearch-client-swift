//
//  TimeInterval+Minutes.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

extension TimeInterval {
  
  static let minute: TimeInterval = 60
  static func minutes(_ minutesCount: Int) -> TimeInterval {
    return TimeInterval(minutesCount) * minute
  }
  
}
