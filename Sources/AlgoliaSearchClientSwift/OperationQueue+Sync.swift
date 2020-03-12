//
//  OperationQueue.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

extension OperationQueue {
  
  func performOperation<OperationWithResult: Operation & ResultContainer>(_ operation: OperationWithResult) throws -> OperationWithResult.ResultValue {
    
    addOperations([operation], waitUntilFinished: true)
  
    guard !operation.isCancelled else {
      throw SyncOperationError.cancelled
    }
    
    guard let result = operation.result else {
      assertionFailure("Operation with result must have result value if not cancelled")
      throw SyncOperationError.noResult
    }
    
    switch result {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
    
  }
  
}

enum SyncOperationError: Error {
  case cancelled
  case noResult
}

