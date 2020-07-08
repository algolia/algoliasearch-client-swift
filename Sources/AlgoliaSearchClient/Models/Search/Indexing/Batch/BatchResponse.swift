//
//  BatchResponse.swift
//  
//
//  Created by Vladislav Fitc on 18/03/2020.
//

import Foundation

public struct BatchResponse: Codable, Task {

  public let taskID: TaskID
  public let objectIDs: [ObjectID?]

}
