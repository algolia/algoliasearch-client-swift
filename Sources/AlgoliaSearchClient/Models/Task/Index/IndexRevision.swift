//
//  IndexRevision.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

public struct IndexRevision: Task, Codable {

  /// Date at which the Task to update the Index has been created.
  public let updatedAt: Date

  /// The TaskID which can be used with the .waitTask method.
  public let taskID: TaskID

}
