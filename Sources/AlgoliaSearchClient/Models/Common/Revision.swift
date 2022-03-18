//
//  Revision.swift
//  
//
//  Created by Vladislav Fitc on 21/01/2021.
//

import Foundation

public struct Revision: IndexTask, Codable {

  /// Date at which the update happened.
  public let updatedAt: Date

  /// The TaskID which can be used with the .waitTask method.
  public let taskID: TaskID

}
