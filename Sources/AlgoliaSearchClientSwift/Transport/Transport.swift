//
//  Transport.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

/**
 * Indicate whether the HTTP call performed is of type [read] (GET) or [write] (POST, PUT ..).
 * Used to determine which timeout duration to use.
 */
public enum CallType {
    case read, write
}

extension CallType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .read:
      return "read"
    case .write:
      return "write"
    }
  }
}

public enum HttpMethod: String {
  case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

protocol Transport: Credentials {

  func execute<Response: Codable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output, completion: @escaping (Result<Output, Error>) -> Void) -> Operation & TransportTask
  func execute<Response: Codable, Output>(_ command: AlgoliaCommand, transform: @escaping (Response) -> Output) throws -> Output

}

extension Transport {

  func execute<Output: Codable>(_ command: AlgoliaCommand, completion: @escaping ResultCallback<Output>) -> Operation & TransportTask {
    execute(command, transform: { $0 }, completion: completion)
  }

  func execute<Output: Codable>(_ command: AlgoliaCommand) throws -> Output {
    try execute(command, transform: { $0 })
  }

}

public typealias TransportTask = Cancellable & ProgressReporting
