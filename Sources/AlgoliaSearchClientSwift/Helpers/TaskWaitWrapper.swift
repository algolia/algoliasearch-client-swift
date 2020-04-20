//
//  TaskWaitWrapper.swift
//  
//
//  Created by Vladislav Fitc on 16/04/2020.
//

import Foundation

public class TaskWaitWrapper<T: Task> {
  
  public let index: Index
  public let task: T
  
  public init(index: Index, task: T) {
    self.index = index
    self.task = task
  }
  
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
