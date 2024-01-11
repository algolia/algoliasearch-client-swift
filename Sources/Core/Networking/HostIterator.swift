//
//  HostIterator.swift
//
//
//  Created by Algolia on 02/03/2020.
//

import Foundation

open class HostIterator: IteratorProtocol {

  var getHost: () -> RetryableHost?

  init(getHost: @escaping () -> RetryableHost?) {
    self.getHost = getHost
  }

  public func next() -> RetryableHost? {
    return getHost()
  }

}
