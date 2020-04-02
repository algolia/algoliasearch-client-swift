//
//  Transport.swift
//  
//
//  Created by Vladislav Fitc on 03/03/2020.
//

import Foundation

/**
 * Indicate whether the HTTP call performed is of type [read] (GET) or [write] (POST, PUT ..).
 * Used to determined which timeout duration to use.
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

protocol Transport {

  var credentials: Credentials? { get }
  var configuration: Configuration { get }

  func request<T: Codable>(request: URLRequest, callType: CallType, requestOptions: RequestOptions?, completion: @escaping ResultCallback<T>) -> TransportTask

}

public typealias TransportTask = Cancellable & ProgressReporting
