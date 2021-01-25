//
//  TaskWaitWrapper.swift
//  
//
//  Created by Vladislav Fitc on 16/04/2020.
//

import Foundation

public struct WaitableWrapper<T> {

  public let wrapped: T
  let tasksToWait: [(TaskWaitable, TaskID)]

  init(wrapped: T, tasksToWait: [(TaskWaitable, TaskID)]) {
    self.wrapped = wrapped
    self.tasksToWait = tasksToWait
  }

}

extension WaitableWrapper where T: Task {
  
  public var task: T {
    return wrapped
  }

  init(task: T, index: Index) {
    self.wrapped = task
    self.tasksToWait = [(index, task.taskID)]
  }

  static func wrap(with index: Index) -> (T) -> WaitableWrapper<T> {
    return { task in
      return WaitableWrapper(task: task, index: index)
    }
  }
  
  init(task: T, client: SearchClient) {
    self.wrapped = task
    self.tasksToWait = [(client, task.taskID)]
  }
  
  static func wrap(with client: SearchClient) -> (T) -> WaitableWrapper<T> {
    return { task in
      return WaitableWrapper(task: task, client: client)
    }
  }

}

extension WaitableWrapper where T: Task & IndexNameContainer  {

  static func wrap(credentials: Credentials) -> (T) -> WaitableWrapper<T> {
    return { task in
      let index = SearchClient(appID: credentials.applicationID, apiKey: credentials.apiKey).index(withName: task.indexName)
      return WaitableWrapper(task: task, index: index)
    }
  }

}

extension WaitableWrapper where T == BatchesResponse {
  
  public var batchesResponse: BatchesResponse {
    return wrapped
  }

  init(batchesResponse: T, client: SearchClient) {
    self.wrapped = batchesResponse
    self.tasksToWait = batchesResponse.tasks.map { (client.index(withName: $0.indexName), $0.taskID) }
  }

  init(batchesResponse: T, index: Index) {
    self.wrapped = batchesResponse
    self.tasksToWait = batchesResponse.tasks.map { (index, $0.taskID) }
  }

}

extension WaitableWrapper: AnyWaitable {

  public func wait(timeout: TimeInterval? = nil,
                   requestOptions: RequestOptions? = nil) throws {
    for (waiter, taskID) in tasksToWait {
      _ = try waiter.waitTask(withID: taskID, timeout: timeout, requestOptions: requestOptions)
    }
  }

  public func wait(timeout: TimeInterval? = nil,
                   requestOptions: RequestOptions? = nil,
                   completion: @escaping (Result<Empty, Swift.Error>) -> Void) {
    let dispatchGroup = DispatchGroup()
    var outputError: Error?
    for (waiter, taskID) in tasksToWait {
      dispatchGroup.enter()
      _ = waiter.waitTask(withID: taskID,
                     timeout: timeout,
                     requestOptions: requestOptions) { result in
        switch result {
        case .success:
          break
        case .failure(let error):
          outputError = error
        }
        dispatchGroup.leave()
      }
    }
    dispatchGroup.notify(queue: .global(qos: .userInteractive)) {
      let result: Result<Empty, Error>
      if let error = outputError {
        result = .failure(error)
      } else {
        result = .success(.empty)
      }
      completion(result)
    }
  }

}
