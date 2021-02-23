//
//  RetryStrategy.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

protocol RetryStrategy: class {

  func retryableHosts(for callType: CallType) -> HostIterator
  func notify<T>(host: RetryableHost, result: Result<T, Swift.Error>)
  func canRetry(inCaseOf error: Error) -> Bool

}
