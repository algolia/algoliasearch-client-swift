//
//  Hosts.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct Hosts {

  public static func forApplicationID(_ appID: ApplicationID) -> [RetryableHost] {
    let hostSuffixes: [(suffix: String, callType: CallType?)] = [
      ("-dsn.algolia.net", .read),
      (".algolia.net", .write),
      ("-1.algolianet.com", nil),
      ("-2.algolianet.com", nil),
      ("-3.algolianet.com", nil),
    ]
    return hostSuffixes.map {
      let url = URL(string: "\(appID.rawValue)\($0.suffix)")!
      return RetryableHost(url: url, callType: $0.callType)
    }
  }
  
  public static var insights: [RetryableHost] = [
    .init(url: URL(string: "insights.algolia.io")!)
  ]
  
  public static var analytics: [RetryableHost] = [
    .init(url: URL(string: "analytics.algolia.com")!)
  ]
  
  public static var places: [RetryableHost] = [
    .init(url: URL(string: "places-dsn.algolia.net")!),
    .init(url: URL(string: "places-1.algolianet.com")!),
    .init(url: URL(string: "places-2.algolianet.com")!),
    .init(url: URL(string: "places-3.algolianet.com")!),
  ]
  
}
