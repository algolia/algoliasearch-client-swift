//
//  AccountClient.swift
//  
//
//  Created by Vladislav Fitc on 02/07/2020.
//

import Foundation

/// Client to perform operations between applications.
public struct AccountClient {

  static var operationLauncher: OperationLauncher = {
    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    return OperationLauncher(queue: queue)
  }()

  // MARK: - Copy Index

  /**
   Copy settings, synonyms, rules and objects from the source index to the destination index.
   
   - Parameter source: source Index
   - Parameter destination: destination Index
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: WaitableWrapper objects embedding all the tasks created while copying
   - Throws: AccountClient.Error.sameApplicationID if source and destination have the same ApplicationID.
   AccountClient.Error.sourceNotFound if source doesnt exist
   AccountClient.Error.existingDestination if destination index already exists.
   */

  @discardableResult public static func copyIndex(source: Index,
                                                  destination: Index,
                                                  requestOptions: RequestOptions? = nil,
                                                  completion: @escaping (Result<WaitableWrapper<[Task]>, Swift.Error>) -> Void) throws -> Operation {
    let operation = BlockOperation {
      completion(.init { try AccountClient.copyIndex(source: source, destination: destination, requestOptions: requestOptions) })
    }
    return operationLauncher.launch(operation)
  }

  /**
   Copy settings, synonyms, rules and objects from the source index to the destination index.
   
   - Parameter source: source Index
   - Parameter destination: destination Index
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: WaitableWrapper objects embedding all the tasks created while copying
   - Throws: AccountClient.Error.sameApplicationID if source and destination have the same ApplicationID.
   AccountClient.Error.sourceNotFound if source doesnt exist
   AccountClient.Error.existingDestination if destination index already exists.
   */

  @discardableResult public static func copyIndex(source: Index,
                                                  destination: Index,
                                                  requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<[Task]> {

    guard source.applicationID != destination.applicationID else {
      throw Error.sameApplicationID
    }

    guard try source.exists() else {
      throw Error.sourceNotFound
    }

    guard try !destination.exists() else {
      throw Error.existingDestination
    }

    let objects = try source.browseObjects().flatMap(\.hits).map(\.object)
    let synonyms = try source.browseSynonyms().flatMap(\.hits).map(\.synonym)
    let rules = try source.browseRules().flatMap(\.hits).map(\.rule)
    let settings = try source.getSettings()

    let waitObjects = try destination.saveObjects(objects)
    let waitSynonyms = try destination.saveSynonyms(synonyms)
    let waitRules = try destination.saveRules(rules)
    let waitSettings = try destination.setSettings(settings)

    let tasks: [Task] = [
      waitSynonyms,
      waitRules,
      waitSettings
      ].map(\.task) + waitObjects.batchesResponse.tasks

    let waitService = WaitService(taskIndices: tasks.map { (destination, $0.taskID) })
    return WaitableWrapper(wrapped: tasks, waitService: waitService)
  }

}

extension AccountClient {

  public enum Error: Swift.Error {
    case sourceNotFound
    case existingDestination
    case sameApplicationID
  }

}
