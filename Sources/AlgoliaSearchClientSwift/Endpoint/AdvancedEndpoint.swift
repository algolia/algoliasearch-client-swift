//
//  AdvancedEndpoint.swift
//  
//
//  Created by Vladislav Fitc on 06.03.2020.
//

import Foundation

public protocol AdvancedEndpoint {
  
  /**
    Check the current TaskStatus of a given Task.
   
    - parameter taskID: of the indexing [Task].
    - parameter requestOptions: Configure request locally with [RequestOptions]
   */
  @discardableResult func taskStatus(for taskID: TaskID, requestOptions: RequestOptions?, completion: @escaping ResultCallback<TaskInfo>) -> Operation

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
  @discardableResult func waitTask(withID taskID: TaskID, timeout: TimeInterval?, requestOptions: RequestOptions?, completion: @escaping  ResultCallback<TaskStatus>) -> Operation
  
}
