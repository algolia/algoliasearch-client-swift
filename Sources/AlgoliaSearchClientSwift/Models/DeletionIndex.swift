//
//  DeletionIndex.swift
//  
//
//  Created by Vladislav Fitc on 05/03/2020.
//

import Foundation

struct DeletionIndex: Task, Codable {
  
  /// Date at which the Task to delete the Index has been created.
  let deletionDate: Date

  /// The TaskID which can be used with the .waitTask method.
  let taskID: TaskID

  enum CodingKeys: String, CodingKey {
    case deletionDate = "deletedAt"
    case taskID
  }

}
