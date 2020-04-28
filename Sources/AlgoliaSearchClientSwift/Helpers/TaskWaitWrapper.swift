//
//  TaskWaitWrapper.swift
//  
//
//  Created by Vladislav Fitc on 16/04/2020.
//

import Foundation

public class TaskWaitWrapper<T: Task>: AnyWaitable {

  public let index: Index
  public let task: T

  public init(index: Index, task: T) {
    self.index = index
    self.task = task
  }

}

extension TaskWaitWrapper {

  public func wait(timeout: TimeInterval? = nil) throws {
    try index.waitTask(withID: task.taskID, timeout: timeout)
  }

  public func wait(timeout: TimeInterval? = nil, completion: @escaping (Result<Empty, Swift.Error>) -> Void) {
    index.waitTask(withID: task.taskID) { result in
      switch result {
      case .success:
        completion(.success(.empty))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

}

public protocol AnyWaitable {

  func wait(timeout: TimeInterval?) throws
  func wait(timeout: TimeInterval?, completion: @escaping (Result<Empty, Swift.Error>) -> Void)

}

extension Array where Element == AnyWaitable {

  func waitAll(timeout: TimeInterval? = nil) throws {
    for element in self {
      try element.wait(timeout: timeout)
    }
  }

}
