//
//  ABTestStatus.swift
//  
//
//  Created by Vladislav Fitc on 28/05/2020.
//

import Foundation

/// ABTest server-side status.
public struct ABTestStatus: StringOption, ProvidingCustomOption, URLEncodable {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  /// The Analytics created the ABTest and performed a successful request to the engine.
  public static var active: Self { .init(rawValue: #function) }

  /// The ABTest was stopped by a user: it was deleted from the engine but we have to keep the data for historical purposes.
  public static var stopped: Self { .init(rawValue: #function) }

  /// The ABTest reached its end date and was automatically stopped. It is removed from the engine but the metadata/metrics are kept.
  public static var expired: Self { .init(rawValue: #function) }

  /// The ABTest creation failed.
  public static var failed: Self { .init(rawValue: #function) }

}
