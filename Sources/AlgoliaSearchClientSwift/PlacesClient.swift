//
//  PlacesClient.swift
//  
//
//  Created by Vladislav Fitc on 10/04/2020.
//

import Foundation

public struct PlacesClient: Credentials {
  
  let transport: Transport
  let operationLauncher: OperationLauncher
  
  public var applicationID: ApplicationID {
    return transport.applicationID
  }
  
  public var apiKey: APIKey {
    return transport.apiKey
  }

  public init(appID: ApplicationID, apiKey: APIKey) {
    
    let configuration = PlacesConfiguration(applicationID: appID, apiKey: apiKey)
    let sessionConfiguration: URLSessionConfiguration = .default
    sessionConfiguration.httpAdditionalHeaders = configuration.defaultHeaders

    let session = URLSession(configuration: sessionConfiguration)
    let retryStrategy = AlgoliaRetryStrategy(configuration: configuration)

    let queue = OperationQueue()
    queue.qualityOfService = .userInitiated
    let operationLauncher = OperationLauncher(queue: queue)
    
    let httpTransport = HttpTransport(requester: session, configuration: configuration, retryStrategy: retryStrategy, credentials: configuration, operationLauncher: operationLauncher)
    self.init(transport: httpTransport, operationLauncher: operationLauncher)
  }

  init(transport: Transport, operationLauncher: OperationLauncher) {
    self.transport = transport
    self.operationLauncher = operationLauncher
  }
  
}

public struct PlacesResponse<T: Codable>: Codable {
  
  public let hits: [T]
  
}

public extension PlacesClient {
  
  //MARK: - Search
  
  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func search(query: PlacesQuery, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<PlacesResponse<MultiLanguagePlace>>) -> Operation {
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PlacesResponse<MultiLanguagePlace>  object
   */
  @discardableResult func search(query: PlacesQuery, requestOptions: RequestOptions? = nil) throws -> PlacesResponse<MultiLanguagePlace> {
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return try transport.execute(command)
  }
  
  //MARK: - Search Multilanguage
  
  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func search(query: PlacesQuery, language: Language, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<PlacesResponse<Place>>) -> Operation {
    let query = query.set(\.language, to: language)
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PlacesResponse<MultiLanguagePlace>  object
   */
  @discardableResult func search(query: PlacesQuery, language: Language, requestOptions: RequestOptions? = nil) throws -> PlacesResponse<Place> {
    let command = Command.Places.Search(query: query.set(\.language, to: language), requestOptions: requestOptions)
    return try transport.execute(command)
  }
  
}
