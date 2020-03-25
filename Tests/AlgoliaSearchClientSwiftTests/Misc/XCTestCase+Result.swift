//
//  XCTestCase+Result.swift
//  
//
//  Created by Vladislav Fitc on 25/03/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClientSwift

public func XCTExtract<T>(_ result: Result<T, Error>, completion: @escaping  (T) -> Void) {
  switch result {
  case .failure(let error):
    XCTFail("\(error)")
  case .success(let value):
    completion(value)
  }
}

public func extract<T>(_ completion: @escaping (T) -> Void) -> ResultCallback<T> {
  return { result in
    switch result {
    case .failure(let error):
      XCTFail("\(error)")
    case .success(let value):
      completion(value)
    }
  }
}
