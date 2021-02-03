//
//  AppRevision.swift
//  
//
//  Created by Vladislav Fitc on 01/02/2021.
//

import Foundation

public struct AppRevision: AppTask, Codable {

  /// Date at which the update happened.
  public let updatedAt: Date

  /// The TaskID which can be used with the .waitTask method.
  public let taskID: AppTaskID

}
