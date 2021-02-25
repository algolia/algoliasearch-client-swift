//
//  TaskPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct TaskCompletion: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func task(withID taskID: AppTaskID) -> Self { .init(taskID.rawValue) }

}
