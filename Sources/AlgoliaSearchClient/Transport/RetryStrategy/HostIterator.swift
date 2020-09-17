//
//  HostIterator.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

class HostIterator: IteratorProtocol {

  var getHost: () -> RetryableHost?
  
  init(getHost: @escaping () -> RetryableHost?) {
    self.getHost = getHost
  }

  func next() -> RetryableHost? {
    return getHost()
  }

}
