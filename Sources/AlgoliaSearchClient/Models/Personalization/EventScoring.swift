//
//  EventScoring.swift
//  
//
//  Created by Vladislav Fitc on 27/05/2020.
//

import Foundation

/// Scoring the event
public struct EventScoring: Codable {

  /// Name of the event.
  public let eventName: String

  /// Type of the event.
  public let eventType: InsightsEvent.EventType

  /// Score of the event
  public let score: Int?

}
