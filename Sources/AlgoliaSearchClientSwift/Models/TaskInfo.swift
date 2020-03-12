//
//  TaskInfo.swift
//  
//
//  Created by Vladislav Fitc on 06.03.2020.
//

import Foundation

struct TaskInfo: Codable {
  
  /**
   The Task current TaskStatus.
   */
  let status: TaskStatus
  
  /**
   * Whether the index has remaining Task is running
   */
  let pendingTask: Bool

  
}
