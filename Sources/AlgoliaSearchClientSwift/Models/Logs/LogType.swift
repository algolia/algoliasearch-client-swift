//
//  LogType.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

public struct LogType: Codable {
  
  let rawValue: String
  
  init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  /// Retrieve all the logs.
  public static var all: Self { return .init(rawValue: #function) }
  
  /// Retrieve only the queries.
  public static var query: Self { return .init(rawValue: #function) }
  
  /// Retrieve only the build operations.
  public static var build: Self { return .init(rawValue: #function) }
  
  /// Retrieve only the errors.
  public static var error: Self { return .init(rawValue: #function) }
  
  public static func other(_ rawValue: String) -> Self { return .init(rawValue: rawValue) }
  
}
