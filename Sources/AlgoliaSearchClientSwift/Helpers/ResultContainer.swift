//
//  ResultContainer.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

protocol ResultContainer {

  associatedtype ResultValue

  var result: Result<ResultValue, Swift.Error>? { get }

}

extension ResultContainer {
  func getValue() throws -> ResultValue {
    guard let result = result else { throw SyncOperationError.noResult }
    return try result.value()
  }
}
