//
//  PromisesHelpers.swift
//  AlgoliaSearch OSX
//
//  Created by Robert Mogos on 06/02/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation
import InstantSearchClient
import PromiseKit

public typealias FulfillHandler = ([String: Any]) -> Void
public typealias RejectHandler = (Error) -> Void
public typealias ShellHandler = (@escaping FulfillHandler, @escaping RejectHandler) -> Void

func promiseWrap(_ bodyHandler: @escaping ShellHandler) -> Promise<[String: Any]> {
  return Promise<[String: Any]> { fulfill, reject in
    bodyHandler(fulfill, reject)
  }
}

func completionWrap(fulfill: (@escaping FulfillHandler), reject: @escaping RejectHandler) -> CompletionHandler {
  return { result, error in
    if let result = result {
      fulfill(result)
    } else if let error = error {
      reject(error)
    }
  }
}
