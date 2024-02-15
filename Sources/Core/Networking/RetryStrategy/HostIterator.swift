//
//  HostIterator.swift
//
//
//  Created by Algolia on 02/03/2020.
//

import Foundation

open class HostIterator: IteratorProtocol {
    // MARK: Lifecycle

    init(getHost: @escaping () -> RetryableHost?) {
        self.getHost = getHost
    }

    // MARK: Public

    public func next() -> RetryableHost? {
        self.getHost()
    }

    // MARK: Internal

    var getHost: () -> RetryableHost?
}
