//
//  APIKeyPath.swift
//  
//
//  Created by Vladislav Fitc on 23/02/2021.
//

import Foundation

struct APIKeyCompletion: PathComponent {

  var parent: Path?

  let rawValue: String

  private init(_ rawValue: String) { self.rawValue = rawValue }

  static func apiKey(_ value: APIKey) -> Self { .init(value.rawValue) }
  static func restoreAPIKey(_ value: APIKey) -> Self { .init("\(value.rawValue)/restore")}
}
