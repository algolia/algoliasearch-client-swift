//
//  WaitTask.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

class WaitTask: AsyncOperation, ResultContainer {

  typealias TaskIDProvider = () -> TaskID
  typealias TaskStatusService = (TaskID, RequestOptions?, @escaping  ResultCallback<TaskInfo>) -> Void

  let taskStatusService: TaskStatusService
  let taskIDProvider: TaskIDProvider
  let requestOptions: RequestOptions?
  let timeout: TimeInterval?
  private var launchDate: Date?
  let completion: (ResultCallback<TaskStatus>)

  var result: Result<TaskStatus, Swift.Error> = .failure(SyncOperationError.notFinished) {
    didSet {
      completion(result)
      state = .finished
    }
  }

  var isTimeout: Bool {
    guard let timeout = timeout, let launchDate = launchDate else {
      return false
    }
    return Date().timeIntervalSince(launchDate) >= timeout
  }

  init(taskStatusService: @escaping TaskStatusService,
       taskID: @autoclosure @escaping TaskIDProvider,
       timeout: TimeInterval? = nil,
       requestOptions: RequestOptions?,
       completion: @escaping ResultCallback<TaskStatus>) {
    self.taskStatusService = taskStatusService
    self.taskIDProvider = taskID
    self.timeout = timeout
    self.requestOptions = requestOptions
    self.completion = completion
  }

  override func main() {

    launchDate = Date()

    checkStatus()
  }

  private func checkStatus() {

    guard !isTimeout else {
      result = .failure(Error.timeout)
      return
    }

    let taskID = taskIDProvider()
    
    taskStatusService(taskID, requestOptions) { [weak self] result in
      guard let request = self else { return }

      switch result {
      case .success(let taskStatus):
        switch taskStatus.status {
        case .published:
          request.result = .success(taskStatus.status)

        default:
          sleep(1)
          request.checkStatus()
        }
      case .failure(let error):
        request.result = .failure(error)
      }
    }

  }

  enum Error: Swift.Error {
    case timeout
  }

}

extension WaitTask {

  convenience init(index: Index,
                   task: Task,
                   timeout: TimeInterval? = nil,
                   requestOptions: RequestOptions?,
                   completion: @escaping ResultCallback<TaskStatus>) {
    self.init(taskStatusService: { taskID, requestOptions, completion in index.taskStatus(for: taskID, requestOptions: requestOptions, completion: completion) },
              taskID: task.taskID,
              timeout: timeout,
              requestOptions: requestOptions,
              completion: completion)
  }
  
  convenience init(client: Client,
                   taskID: TaskID,
                   timeout: TimeInterval? = nil,
                   requestOptions: RequestOptions?,
                   completion: @escaping ResultCallback<TaskStatus>) {
    self.init(taskStatusService: { taskID, requestOptions, completion in client.taskStatus(for: taskID, requestOptions: requestOptions, completion: completion) },
              taskID: taskID,
              timeout: timeout,
              requestOptions: requestOptions,
              completion: completion)
  }

}
