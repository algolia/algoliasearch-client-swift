//
//  WaitTask.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

class WaitTask: AsyncOperation, ResultContainer {

  typealias TaskIDProvider = () -> TaskID?

  let index: Index
  let taskIDProvider: TaskIDProvider
  let requestOptions: RequestOptions?
  let timeout: TimeInterval?
  private var launchDate: Date?
  let completion: (ResultCallback<TaskStatus>)

  var result: Result<TaskStatus, Swift.Error>?

  var isTimeout: Bool {
    guard let timeout = timeout, let launchDate = launchDate else {
      return false
    }
    return Date().timeIntervalSince(launchDate) >= timeout
  }

  init(index: Index,
       taskIDProvider: @autoclosure @escaping TaskIDProvider,
       timeout: TimeInterval? = nil,
       requestOptions: RequestOptions?,
       completion: @escaping ResultCallback<TaskStatus>) {
    self.index = index
    self.taskIDProvider = taskIDProvider
    self.timeout = timeout
    self.requestOptions = requestOptions
    self.completion = completion
  }

  init(index: Index,
       taskID: TaskID,
       timeout: TimeInterval? = nil,
       requestOptions: RequestOptions?,
       completion: @escaping ResultCallback<TaskStatus>) {
    self.index = index
    self.taskIDProvider = { return taskID }
    self.timeout = timeout
    self.requestOptions = requestOptions
    self.completion = completion
  }

  override func main() {
    launchDate = Date()
    getTaskStatus()
  }

  private func getTaskStatus() {
    guard let taskID = taskIDProvider() else {
      completion(.failure(Error.missingTaskID))
      state = .finished
      return
    }
    index.taskStatus(for: taskID, requestOptions: requestOptions) { [weak self] result in
      guard let operation = self else { return }
      switch result {
      case .failure(let error):
        operation.result = .failure(error)
        operation.completion(.failure(error))
        operation.state = .finished

      case .success(let taskInfo):
        switch taskInfo.status {
        case .published:
          operation.result = .success(taskInfo.status)
          operation.completion(.success(taskInfo.status))
          operation.state = .finished
        default:
          guard operation.isTimeout else {
            sleep(1)
            operation.getTaskStatus()
            return
          }

          operation.result = .failure(Error.timeout)
          operation.completion(.failure(Error.timeout))
          operation.state = .finished
        }
      }
    }
  }

  enum Error: Swift.Error {
    case timeout
    case missingTaskID
  }

}

extension WaitTask {

  convenience init(index: Index,
                   task: Task,
                   timeout: TimeInterval? = nil,
                   requestOptions: RequestOptions?,
                   completion: @escaping ResultCallback<TaskStatus>) {
    self.init(index: index,
              taskID: task.taskID,
              timeout: timeout,
              requestOptions: requestOptions,
              completion: completion)
  }

  convenience init<Value, Request: HTTPRequest<Value>>(index: Index,
                                                       request: Request,
                                                       timeout: TimeInterval? = nil,
                                                       requestOptions: RequestOptions?,
                                                       completion: @escaping ResultCallback<TaskStatus>) where Value: Task {
    self.init(index: index,
              taskIDProvider: { () -> TaskID? in
                guard case .success(let value) = request.result else {
                  return nil
                }
                return value.taskID
    }(),
              timeout: timeout,
              requestOptions: requestOptions,
              completion: completion)
  }

}
