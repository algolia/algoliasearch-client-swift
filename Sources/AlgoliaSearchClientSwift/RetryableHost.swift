//
//  RetryableHost.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct RetryableHost {
  
  /// The url to target.
  public let url: URL
  
  /// Whether this host should be used for CallType.read or CallType.write requests.
  public let callType: CallType?
  var isUp: Bool
  var lastUpdated: Date
  var retryCount: Int
  
  init(url: URL, callType: CallType? = nil) {
    self.url = url
    self.callType = callType
    self.isUp = true
    self.lastUpdated = .init()
    self.retryCount = 0
  }
  
  mutating func reset() {
    lastUpdated = .init()
    isUp = true
    retryCount = 0
  }
  
  mutating func hasTimedOut() {
    isUp = true
    lastUpdated = .init()
    retryCount += 1
  }
  
  mutating func hasFailed() {
    isUp = false
    lastUpdated = .init()
  }
  
}

extension Array where Element == RetryableHost {
  
  mutating func expireHostsOlderThan(expirationDelay: TimeInterval) {
    var updatedHosts: [RetryableHost] = []
    for host in self {
      var mutableHost = host
      let timeDelayExpired = Date().timeIntervalSince(host.lastUpdated)
      if timeDelayExpired > expirationDelay {
        mutableHost.reset()
      }
      updatedHosts.append(mutableHost)
    }
    self = updatedHosts
  }
  
  func filterCallType(callType: CallType) -> [RetryableHost] {
    return filter { $0.callType == callType || $0.callType == nil }
  }
  
}
