//
//  TaskWaitWrapper.swift
//  
//
//  Created by Vladislav Fitc on 16/04/2020.
//

import Foundation

class TaskWaitWrapper<T: Task> {
  
  let index: Index
  let task: T
  
  init(index: Index, task: T) {
    self.index = index
    self.task = task
  }
  
  func wait(timeout: TimeInterval? = nil) throws {
    try index.waitTask(withID: task.taskID, timeout: timeout)
  }
  
}
