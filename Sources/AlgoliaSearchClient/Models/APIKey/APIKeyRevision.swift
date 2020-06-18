//
//  APIKeyRevision.swift
//  
//
//  Created by Vladislav Fitc on 09/04/2020.
//

import Foundation

public struct APIKeyRevision: Codable {

  /// The created or restored APIKey.
//  public let key: APIKey

  /// The date at which the APIKey has been created or restored.
  public let updatedAt: Date

}
