//
//  DictionaryRevision.swift
//  
//
//  Created by Vladislav Fitc on 21/01/2021.
//

import Foundation

public struct DictionaryRevision: AppTask, Codable {

  /// Date at which the Task to update the dictionary has been created.
  public let updatedAt: Date

  /// The TaskID which can be used with the .waitTask method.
  public let taskID: AppTaskID

}
