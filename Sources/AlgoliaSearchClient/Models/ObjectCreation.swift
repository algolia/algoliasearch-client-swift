//
//  ObjectCreation.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public struct ObjectCreation: Task, Codable {

  /// The date at which the record has been created.
  public let createdAt: Date

  /// The TaskID which can be used with the [EndpointAdvanced.waitTask] method.
  public let taskID: TaskID

  /// The inserted record ObjectID
  public let objectID: ObjectID

}
