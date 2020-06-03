//
//  SynonymRevision.swift
//  
//
//  Created by Vladislav Fitc on 11/05/2020.
//

import Foundation

public struct SynonymRevision: Task {

  /// Date at which the Task to update the synonyms has been created.
  public let updatedAt: Date

  /// ObjectID of the inserted synonym.
  public let objectID: ObjectID

  /// The TaskID which can be used with the .waitTask method.
  public let taskID: TaskID

}

extension SynonymRevision: Codable {

  enum CodingKeys: String, CodingKey {
    case updatedAt
    case objectID = "id"
    case taskID
  }

}
