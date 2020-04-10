//
//  OperationLauncher.swift
//  
//
//  Created by Vladislav Fitc on 03/04/2020.
//

import Foundation

class OperationLauncher {
  
  let queue: OperationQueue
  
  init(queue: OperationQueue) {
    self.queue = queue
  }
  
  @discardableResult func launch<O: Operation>(_ operation: O) -> O {
    queue.addOperation(operation)
    return operation
  }
  
  func launchSync<O: OperationWithResult>(_ operation: O) throws -> O.ResultValue {
    
    queue.addOperations([operation], waitUntilFinished: true)

    guard !operation.isCancelled else {
      throw SyncOperationError.cancelled
    }

    guard let result = operation.result else {
      assertionFailure("Operation with result must have result value if not cancelled")
      throw SyncOperationError.noResult
    }

    return try result.value()

  }

}

public typealias OperationWithResult = Operation & ResultContainer

enum SyncOperationError: Error {
  case cancelled
  case noResult
}