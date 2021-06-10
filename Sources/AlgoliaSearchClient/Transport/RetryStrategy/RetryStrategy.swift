//
//  RetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

protocol RetryStrategy: AnyObject {

  /// Returns the iterator providing retryable hosts for a call type
  func retryableHosts(for callType: CallType) -> HostIterator

  /// Notify the strategy object about the result of request executed to a provided host in order to update its state
  func notify<T>(host: RetryableHost, result: Result<T, Swift.Error>)

  /// Check if a request can be retried on another host in case of provided error
  func canRetry(inCaseOf error: Error) -> Bool

}
