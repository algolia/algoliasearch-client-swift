//
//  UserAgentController.swift
//  
//
//  Created by Vladislav Fitc on 15/06/2020.
//

import Foundation

public struct UserAgentController {

  public internal(set) static var userAgents: [UserAgent] = [.operatingSystem, .library]

  /// Append user agent info which will be includede in each API call.
  public static func append(userAgent: UserAgent) {
    userAgents.append(userAgent)
  }

}
