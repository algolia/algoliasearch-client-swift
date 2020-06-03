//
//  Hosts.swift
//  
//
//  Created by Vladislav Fitc on 19/02/2020.
//

import Foundation

public struct Hosts {

  public static func forApplicationID(_ appID: ApplicationID) -> [RetryableHost] {

    func buildHost(_ components: (suffix: String, callType: RetryableHost.CallTypeSupport)) -> RetryableHost {
      let url = URL(string: "\(appID.rawValue)\(components.suffix)")!
      return RetryableHost(url: url, callType: components.callType)
    }
    let hosts = [
      ("-dsn.algolia.net", .read),
      (".algolia.net", .write)
    ].map(buildHost)

    let commonHosts = [
      ("-1.algolianet.com", .universal),
      ("-2.algolianet.com", .universal),
      ("-3.algolianet.com", .universal)
    ].map(buildHost).shuffled()

    return hosts + commonHosts
  }

  public static func insights(forRegion region: Region? = nil) -> [RetryableHost] {
    let regionComponent = region.flatMap { ".\($0.rawValue)" } ?? ""
    return [.init(url: URL(string: "insights\(regionComponent).algolia.io")!)]
  }

  public static func recommendation(forRegion region: Region? = nil) -> [RetryableHost] {
    let regionComponent = region.flatMap { ".\($0.rawValue)" } ?? ""
    return [.init(url: URL(string: "recommendation\(regionComponent).algolia.com")!)]
  }

  public static var analytics: [RetryableHost] = [
    .init(url: URL(string: "analytics.algolia.com")!)
  ]

  public static var places: [RetryableHost] = [
    .init(url: URL(string: "places-dsn.algolia.net")!),
    .init(url: URL(string: "places-1.algolianet.com")!),
    .init(url: URL(string: "places-2.algolianet.com")!),
    .init(url: URL(string: "places-3.algolianet.com")!)
  ]

}
