//
//  TimeInterval+Minutes.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public extension TimeInterval {

  var milliseconds: Int64 {
    return Int64((self * 1000.0).rounded())
  }

}

public extension TimeInterval {

  static let hour: TimeInterval = minute * 60

  static func hours(_ hoursCount: Int) -> TimeInterval {
    return TimeInterval(hoursCount) * hour
  }

}

public extension TimeInterval {

  static let minute: TimeInterval = 60

  static func minutes(_ minutesCount: Int) -> TimeInterval {
    return TimeInterval(minutesCount) * minute
  }

}

public extension TimeInterval {

  static let second: TimeInterval = 1

  static func seconds(_ secondsCount: Int) -> TimeInterval {
    return TimeInterval(secondsCount)
  }

}

public extension TimeInterval {

  static let day: TimeInterval = hour * 24

  static func days(_ daysCount: Int) -> TimeInterval {
    return TimeInterval(daysCount) * day
  }

}
