//
//  TestCredentials.swift
//
//
//  Created by Vladislav Fitc on 14/11/2020.
//

import Foundation

@testable import AlgoliaSearchClient

struct TestCredentials: Credentials {
  let applicationID: ApplicationID
  let apiKey: APIKey

  init(applicationID: ApplicationID, apiKey: APIKey) {
    self.applicationID = applicationID
    self.apiKey = apiKey
  }

  init(environment: Environment) throws {
    guard
      let appID = String(environmentVariable: environment.variables.appID),
      let apiKey = String(environmentVariable: environment.variables.apiKey)
    else {
      let missingEnvVariables = [environment.variables.appID, environment.variables.apiKey].filter {
        String(environmentVariable: $0) == nil
      }
      throw EnvironmentError.missingEnvironmentVariables(missingEnvVariables)
    }
    self.init(applicationID: ApplicationID(rawValue: appID), apiKey: APIKey(rawValue: apiKey))
  }

  enum Environment {
    case primary
    case secondary
    case places
    case answers
    case mcm
    case custom(appID: String, apiKey: String)

    var variables: (appID: String, apiKey: String) {
      switch self {
      case .primary:
        return ("ALGOLIA_APPLICATION_ID_1", "ALGOLIA_ADMIN_KEY_1")
      case .secondary:
        return ("ALGOLIA_APPLICATION_ID_2", "ALGOLIA_ADMIN_KEY_2")
      case .places:
        return ("ALGOLIA_PLACES_APPLICATION_ID", "ALGOLIA_PLACES_API_KEY")
      case .answers:
        return ("ALGOLIA_ANSWERS_APPLICATION_ID", "ALGOLIA_ANSWERS_API_KEY")
      case .mcm:
        return ("ALGOLIA_APPLICATION_ID_MCM", "ALGOLIA_ADMIN_KEY_MCM")
      case .custom(appID: let appID, apiKey: let apiKey):
        return (appID, apiKey)
      }
    }
  }
}

enum EnvironmentError: Error, CustomStringConvertible {
  case missingEnvironmentVariables([String])

  var description: String {
    switch self {
    case .missingEnvironmentVariables(let variables):
      return "Missing environment variables: \(variables.joined(separator: ", "))"
    }
  }
}
