//
//  Credentials.swift
//  
//
//  Created by Vladislav Fitc on 20/02/2020.
//

import Foundation

public protocol Credentials {

  /// ApplicationID to target. Is passed as a HTTP header.
  var applicationID: ApplicationID { get }

  /**
   * APIKey for a given ApplicationID. Is passed as a HTTP header.
   * To maintain security, never use your Admin APIKey on your front end or share it with anyone.
   * In your front end, use the Search-only APIKey or any other key that has search-only rights.
   */
  var apiKey: APIKey { get }

}
