//
//  ObjectRevision.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation

public struct ObjectRevision: Task, Codable {

  /// The date at which the record has been revised.
  public let updatedAt: Date

  /// The TaskID which can be used with the waitTask method.
  public let taskID: TaskID

  /// The inserted record ObjectID
  public let objectID: ObjectID

}
