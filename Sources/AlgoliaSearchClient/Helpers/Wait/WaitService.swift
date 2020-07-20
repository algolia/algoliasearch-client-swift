//
//  WaitService.swift
//  
//
//  Created by Vladislav Fitc on 29/04/2020.
//

import Foundation

struct WaitService {

  let taskIndices: [(Index, TaskID)]

  init<T: Task>(index: Index, task: T) {
    self.taskIndices = [(index, task.taskID)]
  }

  init(taskIndices: [(Index, TaskID)]) {
    self.taskIndices = taskIndices
  }

  init(client: SearchClient, taskIndex: [IndexedTask]) {
    self.taskIndices = taskIndex.map { (client.index(withName: $0.indexName), $0.taskID) }
  }

}

extension WaitService: AnyWaitable {

  func wait(timeout: TimeInterval?, requestOptions: RequestOptions?) throws {
    for (index, taskID) in taskIndices {
      try index.waitTask(withID: taskID, timeout: timeout, requestOptions: requestOptions)
    }
  }

  func wait(timeout: TimeInterval?, requestOptions: RequestOptions? = nil, completion: @escaping (Result<Empty, Error>) -> Void) {
    let dispatchGroup = DispatchGroup()
    var outputError: Error?
    for (index, taskID) in taskIndices {
      dispatchGroup.enter()
      index.waitTask(withID: taskID,
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
