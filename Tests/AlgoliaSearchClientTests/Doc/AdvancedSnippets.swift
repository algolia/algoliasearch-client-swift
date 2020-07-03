//
//  AdvancedSnippets.swift
//  
//
//  Created by Vladislav Fitc on 01/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct AdvancedSnippets: SnippetsCollection {}

//MARK: - Get logs

extension AdvancedSnippets {
  
  static var getLogs = """
  client.getLogs(
    #{offset}: __Int?__ = nil,
    #{length}: __Int?__ = nil,
    #{type}: __LogType__ = .all,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<LogsResponse> -> Void__
  )
  """
  
  func getLogs() {
    client.getLogs(offset: 0,
                   length: 10,
                   type: .query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Configuring timeouts

extension AdvancedSnippets {
  
  static var configuringTimeouts = """
  let configuration = SearchConfiguration(applicationID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    .set(\\.#{readTimeout}, to: __TimeInterval__)
    .set(\\.#{writeTimeout}, to: __TimeInterval__)
  """
  
  func configuringTimeouts() {
    let configuration = SearchConfiguration(applicationID: "YourApplicationID", apiKey: "YourAdminAPIKey")
      .set(\.readTimeout, to: 30) // seconds
      .set(\.writeTimeout, to: 30) // seconds
    
    let client = SearchClient(configuration: configuration)
    _ = client//to remove when pasted to doc
  }
  
}

//MARK: - Set extra header

extension AdvancedSnippets {
  
  static var setExtraHeader = """
  let configuration = SearchConfiguration(applicationID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    .set(\\.defaultHeaders, to: [#{headerName}: #{headerValue}]: __[HTTPHeaderKey: String]?__)
  """
  
  func setExtraHeader() {
    let configuration = SearchConfiguration(applicationID: "YourApplicationID", apiKey: "YourAdminAPIKey")
      .set(\.defaultHeaders, to: ["NAME-OF-HEADER": "value-of-header"])
    
    let client = SearchClient(configuration: configuration)
    _ = client//to remove when pasted to doc
  }
  
}

//MARK: - Wait for operations

extension AdvancedSnippets {
  
  static var waitForOperations = """
  WaitableWrapper.wait(
    timeout: __TimeInterval?__ = nil,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __(Result<Empty, Swift.Error>) -> Void__
  )
  """
  
  func waitForOperations() throws {
    struct Contact: Codable {
      let firstName: String
      let lastName: String
    }
    
    let object = Contact(firstName: "Jimmie",
                         lastName: "Barninger")
    
    try index.saveObject(object, autoGeneratingObjectID: true) { result in
        if case .success(let waitableWrapper) = result {
          waitableWrapper.wait() { result in
            if case .success(let response) = result {
              print("New object is indexed")
              _ = response//to remove when pasted to doc
            }
          }
        }
    }
  }

  
  func waitForOperationsExtraHeader() throws {
    struct Contact: Codable {
      let firstName: String
      let lastName: String
    }
    
    let object = Contact(firstName: "Jimmie",
                         lastName: "Barninger")
    
    var requestOptions = RequestOptions()
    requestOptions.headers = ["X-Algolia-User-ID": "user123"]
    
    try index.saveObject(object, autoGeneratingObjectID: true) { result in
        if case .success(let waitableWrapper) = result {
          waitableWrapper.wait(requestOptions: requestOptions) { result in
            if case .success(let response) = result {
              print("New object is indexed")
              _ = response//to remove when pasted to doc
            }
          }
        }
    }
  }
  
}

