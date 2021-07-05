//
//  APIKeysSnippets.swift
//  
//
//  Created by Vladislav Fitc on 30/06/2020.
//

import Foundation
import AlgoliaSearchClient

struct APIKeysSnippets: SnippetsCollection {}

//MARK: - Create secured API Key

extension APIKeysSnippets {
  
  static var createSecuredAPIKeySnippet = """
  client.generateSecuredApiKey(
    [parentApiKey](#method-param-apikey): __APIKey__,
    with restriction: __SecuredAPIKeyRestriction__
  ) -> __APIKey__

  struct SecuredAPIKeyRestriction {
    var query: __Query?__ = nil // add any #{searchParameter}
    var #{restrictIndices}: __[IndexName]?__ = nil
    var #{restrictSources}: __[String]?__ = nil
    var #{validUntil}: __TimeInterval?__ = nil
    var #{userToken}: __UserToken?__ = nil
  }
  """
  
  func createSecuredAPIKeyContainingFilter() {
    // generate a public API key for user 42. Here, records are tagged with:
    //  - 'user_XXXX' if they are visible by user XXXX
    
    let parentAPIKey = APIKey("SearchOnlyApiKeyKeptPrivate")
    let restriction = SecuredAPIKeyRestriction()
      .set(\.query, to: Query()
        .set(\.filters, to: "_tags:user_42"))
    
    let publicKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    _ = publicKey//to remove when pasted to doc
  }
  
  func createSecuredAPIKeyWithExpirationDate() {
    // generate a public API key that is valid for 1 hour:

    let parentAPIKey = APIKey("SearchOnlyApiKeyKeptPrivate")
    let restriction = SecuredAPIKeyRestriction()
      .set(\.validUntil, to: Date().addingTimeInterval(60 * 60).timeIntervalSince1970)
    
    let publicKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    _ = publicKey//to remove when pasted to doc
  }
  
  func createSecuredAPIKeyIndicesRestriction() {
    // generate a public API key that is restricted to 'index1' and 'index2':

    let parentAPIKey = APIKey("SearchOnlyApiKeyKeptPrivate")
    let restriction = SecuredAPIKeyRestriction()
      .set(\.restrictIndices, to: ["index1", "index2"])
    
    let publicKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    _ = publicKey//to remove when pasted to doc
  }
  
  func createSecuredAPIKeyNetworkRestriction() {
    // generate a public API key that is restricted to '192.168.1.0/24':

    let parentAPIKey = APIKey("SearchOnlyApiKeyKeptPrivate")
    let restriction = SecuredAPIKeyRestriction()
      .set(\.restrictSources, to: ["192.168.1.0/24"])
    
    let publicKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    _ = publicKey//to remove when pasted to doc
  }

  
  func createSecuredAPIKeyRateLimiting() {
    // generate a public API key for user 42. Here, records are tagged with:
    //  - 'user_XXXX' if they are visible by user XXXX
    
    let parentAPIKey = APIKey("SearchOnlyApiKeyKeptPrivate")
    let restriction = SecuredAPIKeyRestriction()
      .set(\.query, to: Query()
        .set(\.filters, to: "_tags:user_42")
        .set(\.userToken, to: "42")
      )
    
    let publicKey = client.generateSecuredApiKey(parentApiKey: parentAPIKey, with: restriction)
    _ = publicKey//to remove when pasted to doc
  }
  
}

//MARK: - Add API Key

extension APIKeysSnippets {
  
  static var addAPIKeySnippet = """
  client.addAPIKey(
    with parameters: __APIKeyParameters__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<APIKeyCreation> -> Void__
  )

  struct APIKeyParameters {
    var [ACLs](#method-param-acl): __[ACL]__
    var #{validity}: __TimeInterval?__
    var #{maxHitsPerQuery}: __Int?__
    var #{maxQueriesPerIPPerHour}: __Int?__
    var #{indices}: __[IndexName]?__
    var #{referers}: __[String]?__
    var #{query}: __Query?__
    var #{description}: __String?__
    var #{restrictSources}: __String?__
  }
  """
  
  func addAPIKey() {
    // Creates a new API key that can only perform search actions
    let params = APIKeyParameters(ACLs: [.search])
    
    client.addAPIKey(with: params) { result in
      if case .success(let apiKeyCreation) = result {
        print(apiKeyCreation.key)
      }
    }
  }
  
  func addAPIKeyWithAdvancedRestrictions() {
    // Creates a new index specific API key valid for 300 seconds,
    // with a rate limit of 100 calls per hour per IP and a maximum of 20 hits
    
    let params = APIKeyParameters(ACLs: [.search])
      .set(\.description, to: "Limited search only API key for algolia.com")
      .set(\.indices, to: ["dev_*"])
      .set(\.maxHitsPerQuery, to: 20)
      .set(\.maxQueriesPerIPPerHour, to: 100)
      .set(\.query, to: Query()
        .set(\.typoTolerance, to: .strict)
        .set(\.ignorePlurals, to: false)
      )
      .set(\.referers, to: ["algolia.com/*"])
      .set(\.validity, to: 300)
      .set(\.restrictSources, to: "192.168.1.0/24")
    
    client.addAPIKey(with: params) { result in
      if case .success(let response) = result {
        _ = response//to remove when pasted to doc
      }
    }
  }
  
}

//MARK: - Update API Key

extension APIKeysSnippets {
  
  static var updateAPIKeySnippet = """
  client.updateAPIKey(
    _ apiKey: __APIKey__,
    with parameters: __APIKeyParameters__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<APIKeyRevision> -> Void__
  )

  struct APIKeyParameters {
    var [ACLs](#method-param-acl): __[ACL]__
    var #{validity}: __TimeInterval?__
    var #{maxHitsPerQuery}: __Int?__
    var #{maxQueriesPerIPPerHour}: __Int?__
    var #{indices}: __[IndexName]?__
    var #{referers}: __[String]?__
    var #{query}: __Query?__
    var #{description}: __String?__
    var #{restrictSources}: __String?__
  }
  """
  
  func updateAPIKey() {
    // Update an existing index specific API key valid for 300 seconds,
    // with a rate limit of 100 calls per hour per IP and a maximum of 20 hits

    let parameters = APIKeyParameters(ACLs: [.search])
      .set(\.indices, to: ["dev_*"])
      .set(\.maxHitsPerQuery, to: 20)
      .set(\.maxQueriesPerIPPerHour, to: 100)
      .set(\.validity, to: 300)
    
    client.updateAPIKey("myAPIKey", with: parameters) { result in
      if case .success(let response) = result {
        _ = response//to remove when pasted to doc
      }
    }
  }
  
}

//MARK: - Delete API Key

extension APIKeysSnippets {
  
  static var deleteAPIKeySnippet = """
  client.deleteAPIKey(
    _ #{apiKey}: __APIKey__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<APIKeyDeletion> -> Void__
  )
  """
  
  func deleteAPIKey() {
    client.deleteAPIKey("myAPIKey") { result in
      if case .success(let response) = result {
        _ = response//to remove when pasted to doc
      }
    }
  }
  
}

//MARK: - Restore API Key

extension APIKeysSnippets {
  
  static var restoreAPIKeySnippet = """
  client.restoreAPIKey(
    _ #{apiKey}: __APIKey__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<APIKeyCreation> -> Void__
  )
  """
  
  func restoreAPIKey() {
    client.restoreAPIKey("myAPIKey") { result in
      if case .success(let response) = result {
        _ = response//to remove when pasted to doc
      }
    }
  }
  
}

//MARK: - Get API Key permissions

extension APIKeysSnippets {
  
  static var getAPIKeypermissionsSnippet = """
  client.getAPIKey(
    _ #{apiKey}: __APIKey__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<APIKeyResponse> -> Void__
  )
  """
  
  func getAPIKeypermissions() {
    client.getAPIKey("YourSearchOnlyAPIKey") { result in
      if case .success(let response) = result {
        _ = response//to remove when pasted to doc
      }
    }
  }
  
}

//MARK: - List API Keys

extension APIKeysSnippets {
  
  static var listAPIKeysSnippet = """
  client.listAPIKeys(
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<ListAPIKeysResponse> -> Void__
  )
  """
  
  func listAPIKeys() {
    client.listAPIKeys { result in
      if case .success(let response) = result {
        _ = response//to remove when pasted to doc
      }
    }
  }
  
}

//MARK: - Get secured API key remaining validity

extension APIKeysSnippets {
  
  static var getSecuredAPIKeyRemainingValiditySnippet = """
  client.getSecuredApiKeyRemainingValidity(_ #{apiKey}: APIKey) -> TimeInterval?
  """
  
  func getSecuredAPIKeyRemainingValidity() {
    let remainingValidity = client.getSecuredApiKeyRemainingValidity("YourSecuredAPIkey")
    _ = remainingValidity//to remove when pasted to doc
  }
  
}

