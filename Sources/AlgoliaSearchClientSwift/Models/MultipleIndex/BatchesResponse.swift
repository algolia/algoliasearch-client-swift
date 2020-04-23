//
//  BatchesResponse.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public struct BatchesResponse {

  /// A list of TaskIndex to use with .waitAll.
  let tasks: [TaskIndex]

  /// List of ObjectID affected by .multipleBatchObjects.
  let objectIDs: [ObjectID?]

}

extension BatchesResponse: Codable {

  enum CodingKeys: String, CodingKey {
    case tasks = "taskID"
    case objectIDs
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rawTasks: [String: Int] = try container.decode(forKey: .tasks)
    self.tasks = rawTasks.map { rawIndexName, rawTaskID in TaskIndex(indexName: .init(rawValue: rawIndexName), taskID: .init(rawValue: String(rawTaskID))) }
    self.objectIDs = try container.decode(forKey: .objectIDs)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let rawTasks = [String: String](uniqueKeysWithValues: tasks.map { ($0.indexName.rawValue, $0.taskID.rawValue) })
    try container.encode(rawTasks, forKey: .tasks)
    try container.encode(objectIDs, forKey: .objectIDs)
  }

}

public struct WaitableBatchesResponse: AnyWaitable {
  
  public let client: Client
  public let batchesResponse: BatchesResponse
  
  public init(client: Client, batchesResponse: BatchesResponse) {
    self.client = client
    self.batchesResponse = batchesResponse
  }
  
  public func wait(timeout: TimeInterval? = nil) throws {
    for taskIndex in batchesResponse.tasks {
      try client.index(withName: taskIndex.indexName).waitTask(withID: taskIndex.taskID, timeout: timeout)
    }
  }
  
  public func wait(timeout: TimeInterval?, completion: @escaping (Result<Empty, Swift.Error>) -> Void) {
    let tasksGroup = DispatchGroup()
    for taskIndex in batchesResponse.tasks {
      tasksGroup.enter()
      client.index(withName: taskIndex.indexName).waitTask(withID: taskIndex.taskID) { result in
        tasksGroup.leave()
      }
    }
    tasksGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
      completion(.success(.empty))
    }
  }

}
