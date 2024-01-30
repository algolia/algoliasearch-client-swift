//
//  TaskWaitWrapper.swift
//
//
//  Created by Vladislav Fitc on 16/04/2020.
//

import Foundation

public struct WaitableWrapper<T> {
  public let wrapped: T
  let tasksToWait: [Waitable]
}

extension WaitableWrapper where T: IndexTask {
  public var task: T {
    wrapped
  }

  init(task: T, index: Index) {
    wrapped = task
    tasksToWait = [.init(index: index, taskID: task.taskID)]
  }

  static func wrap(with index: Index) -> (T) -> WaitableWrapper<T> {
    { task in
      WaitableWrapper(task: task, index: index)
    }
  }
}

extension WaitableWrapper where T == [IndexTask] {
  public var tasks: T {
    wrapped
  }

  init(tasks: [IndexTask], index: Index) {
    wrapped = tasks
    tasksToWait = tasks.map { Waitable(index: index, taskID: $0.taskID) }
  }
}

extension WaitableWrapper where T: AppTask {
  public var task: T {
    wrapped
  }

  init(task: T, client: SearchClient) {
    wrapped = task
    tasksToWait = [.init(client: client, taskID: task.taskID)]
  }

  static func wrap(with client: SearchClient) -> (T) -> WaitableWrapper<T> {
    { task in
      WaitableWrapper(task: task, client: client)
    }
  }
}

extension WaitableWrapper where T: IndexTask & IndexNameContainer {
  static func wrap(credentials: Credentials) -> (T) -> WaitableWrapper<T> {
    { task in
      let index = SearchClient(appID: credentials.applicationID, apiKey: credentials.apiKey).index(
        withName: task.indexName)
      return WaitableWrapper(task: task, index: index)
    }
  }
}

extension WaitableWrapper where T == BatchesResponse {
  public var batchesResponse: BatchesResponse {
    wrapped
  }

  init(batchesResponse: T, client: SearchClient) {
    wrapped = batchesResponse
    tasksToWait = batchesResponse.tasks.map {
      Waitable(index: client.index(withName: $0.indexName), taskID: $0.taskID)
    }
  }

  init(batchesResponse: T, index: Index) {
    wrapped = batchesResponse
    tasksToWait = batchesResponse.tasks.map { Waitable(index: index, taskID: $0.taskID) }
  }
}

extension WaitableWrapper: AnyWaitable {
  public func wait(
    timeout: TimeInterval? = nil,
    requestOptions: RequestOptions? = nil
  ) throws {
    for waiter in tasksToWait {
      try waiter.wait(timeout: timeout, requestOptions: requestOptions)
    }
  }

  public func wait(
    timeout: TimeInterval? = nil,
    requestOptions: RequestOptions? = nil,
    completion: @escaping (Result<Empty, Swift.Error>) -> Void
  ) {
    let dispatchGroup = DispatchGroup()
    var outputError: Error?
    for waiter in tasksToWait {
      dispatchGroup.enter()
      waiter.wait(
        timeout: timeout,
        requestOptions: requestOptions
      ) { result in
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
      completion(outputError.flatMap { .failure($0) } ?? .success(.empty))
    }
  }
}
