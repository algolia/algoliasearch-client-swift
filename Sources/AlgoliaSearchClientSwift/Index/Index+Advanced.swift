//
//  Index+Advanced.swift
//  
//
//  Created by Vladislav Fitc on 06.03.2020.
//

import Foundation

extension Index {

  /**
    Check the current TaskStatus of a given Task.
   
    - parameter taskID: of the indexing [Task].
    - parameter requestOptions: Configure request locally with [RequestOptions]
  */
  @discardableResult public func taskStatus(for taskID: TaskID, requestOptions: RequestOptions? = nil, completion: @escaping  ResultCallback<TaskInfo>) -> Operation & TransportTask {
    let request = Command.Advanced.TaskStatus(indexName: name, taskID: taskID, requestOptions: requestOptions)
    return launch(request, completion: completion)
  }

  /**
    Wait for a Task to complete before executing the next line of code, to synchronize index updates.
    All write operations in Algolia are asynchronous by design.
    It means that when you add or update an object to your index, our servers will reply to your request with
    a TaskID as soon as they understood the write operation.
    The actual insert and indexing will be done after replying to your code.
    You can wait for a task to complete by using the TaskID and this method.
   
    - parameter taskID: of the indexing task to wait for.
    - parameter requestOptions: Configure request locally with RequestOptions
  */
  @discardableResult public func waitTask(withID taskID: TaskID, timeout: TimeInterval? = nil, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<TaskStatus>) -> Operation {
    let task = WaitTask(index: self, taskID: taskID, requestOptions: requestOptions, completion: completion)
    queue.addOperation(task)
    return task
  }

}

public extension Index {

  func waitTask(withID taskID: TaskID, timeout: TimeInterval? = nil, requestOptions: RequestOptions? = nil) throws -> TaskStatus {
    let task = WaitTask(index: self, taskID: taskID, requestOptions: requestOptions, completion: { _ in })
    return try queue.performOperation(task)
  }

  func wait(for task: Task, timeout: TimeInterval? = nil, requestOptions: RequestOptions? = nil) throws -> TaskStatus {
    return try waitTask(withID: task.taskID, timeout: timeout, requestOptions: requestOptions)
  }

}
