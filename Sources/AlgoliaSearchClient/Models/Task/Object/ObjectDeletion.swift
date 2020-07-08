//
//  ObjectDeletion.swift
//  
//
//  Created by Vladislav Fitc on 26/03/2020.
//

import Foundation

public struct ObjectDeletion: Task, Codable {

  /// The date at which the record has been deleted.
  public let deletedAt: Date

  /// The TaskID which can be used with the waitTask method.
  public let taskID: TaskID

  /// The deleted record ObjectID
  public let objectID: ObjectID

}
