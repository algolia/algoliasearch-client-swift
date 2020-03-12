//
//  Index+Advanced.swift
//  
//
//  Created by Vladislav Fitc on 06.03.2020.
//

import Foundation


extension Index: AdvancedEndpoint {
  
  @discardableResult func taskStatus(for taskID: TaskID, requestOptions: RequestOptions? = nil, completion: @escaping  ResultCallback<TaskInfo>) -> Operation {
    let request = Command.Advanced.TaskStatus(indexName: name, taskID: taskID, requestOptions: requestOptions)
    return performRequest(for: request, completion: completion)
  }
  
  @discardableResult func waitTask(withID taskID: TaskID, timeout: TimeInterval? = nil, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<TaskStatus>) -> Operation {
    let task = WaitTask(index: self, taskID: taskID, requestOptions: requestOptions, completion: completion)
    queue.addOperation(task)
    return task
  }
    
}

extension Index {
  
  func waitTask(withID taskID: TaskID, timeout: TimeInterval? = nil, requestOptions: RequestOptions? = nil) throws -> TaskStatus {
    let task = WaitTask(index: self, taskID: taskID, requestOptions: requestOptions, completion: { _ in })
    return try queue.performOperation(task)
  }
  
  func wait(for task: Task, timeout: TimeInterval? = nil, requestOptions: RequestOptions? = nil) throws -> TaskStatus {
    return try waitTask(withID: task.taskID, timeout: timeout, requestOptions: requestOptions)
  }
  
}


