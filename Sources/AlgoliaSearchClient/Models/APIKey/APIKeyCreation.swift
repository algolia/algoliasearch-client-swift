//
//  APIKeyCreation.swift
//  
//
//  Created by Vladislav Fitc on 09/04/2020.
//

import Foundation

public struct APIKeyCreation: Codable {

  /// The created or restored APIKey.
  public let key: APIKey

  /// The date at which the APIKey has been created or restored.
  public let createdAt: Date

  static func transform(_ apiKey: APIKey) -> (Creation) -> Self {
    return { creation in .init(key: apiKey, createdAt: creation.createdAt) }
  }

}
