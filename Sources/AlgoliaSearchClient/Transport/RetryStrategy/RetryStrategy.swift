//
//  RetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

protocol RetryStrategy: class {

  func retryableHosts(for callType: CallType) -> HostIterator
  func notify<T>(host: RetryableHost, result: Result<T, Swift.Error>) -> RetryOutcome<T>

}

extension Error {

  var isRetryable: Bool {
    switch self {
    case is URLError:
      return true

    case let httpError as HTTPError where !httpError.statusCode.belongs(to: .success, .clientError):
      return true

    default:
      return false
    }
  }

  var isTimeout: Bool {
    switch self {
    case let urlError as URLError:
      return urlError.code == .timedOut

    case let httpError as HTTPError:
      return httpError.statusCode == .requestTimeout

    default:
      return false
    }
  }

}

extension Optional where Wrapped: Equatable {

  func isNilOrEqual(to value: Wrapped) -> Bool {
    return self == nil || self == value
  }

}
