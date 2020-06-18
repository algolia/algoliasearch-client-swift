//
//  ObjectsResponse.swift
//  
//
//  Created by Vladislav Fitc on 28/03/2020.
//

import Foundation

public struct ObjectsResponse<T: Codable>: Codable {

  /// List of requested records. If a record is not found, it will be marked as null in the list.
  public let results: [T?]

  /// Optional error message in case of failure to retrieve a requested record.
  public let message: String?

}
