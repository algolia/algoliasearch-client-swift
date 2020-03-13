//
//  TaskStatus.swift
//  
//
//  Created by Vladislav Fitc on 06.03.2020.
//

import Foundation

public enum TaskStatus {
      
  /**
   * The Task has been processed by the server.
   */
  case published

  /**
   * The Task has not yet been processed by the server.
   */
  case notPublished

  case other(String)
  
}

extension TaskStatus: RawRepresentable {
  
  public var rawValue: String {
    switch self {
    case .notPublished:
      return "notPublished"
    case .published:
      return "published"
    case .other(let value):
      return value
    }
  }
  
  public init(rawValue: String) {
    switch rawValue {
    case TaskStatus.published.rawValue:
      self = .published
    case TaskStatus.notPublished.rawValue:
      self = .notPublished
    default:
      self = .other(rawValue)
    }
  }
    
}

extension TaskStatus: Codable {
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(String.self)
    self.init(rawValue: value)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
  
}
