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
  
  public typealias SingleLanguageResponse = PlacesResponse<Hit<Place>>
  public typealias MultiLanguageResponse = PlacesResponse<Hit<MultiLanguagePlace>>
  
}

public extension PlacesClient {
  
  //MARK: - Search
  
  /**
     
    
   - Parameter query: The PlacesQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func search(query: PlacesQuery, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<MultiLanguageResponse>) -> Operation {
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
     
   
   - Parameter query: The PlacesQuery used to search.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PlacesResponse<MultiLanguagePlace>  object
   */
  @discardableResult func search(query: PlacesQuery, requestOptions: RequestOptions? = nil) throws -> MultiLanguageResponse {
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return try transport.execute(command)
  }
  
  //MARK: - Search Multilanguage
  
  /**
     
   
   - Parameter query: The PlacesQuery used to search.
   - Parameter language: The language used to specialize the results localization
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func search(query: PlacesQuery, language: Language, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<SingleLanguageResponse>) -> Operation {
    let query = query.set(\.language, to: language)
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
     
   
   - Parameter query: The PlacesQuery used to search.
   - Parameter language: The language used to specialize the results localization
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PlacesResponse<MultiLanguagePlace>  object
   */
  @discardableResult func search(query: PlacesQuery, language: Language, requestOptions: RequestOptions? = nil) throws -> SingleLanguageResponse {
    let query = query.set(\.language, to: language)
    let command = Command.Places.Search(query: query, requestOptions: requestOptions)
    return try transport.execute(command)
  }
  
  //MARK: - Get object
  
  /**
   
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getObject(withID objectID: ObjectID, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<Hit<MultiLanguagePlace>>) -> Operation {
    let command = Command.Places.GetObject(objectID: objectID, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
   
   
   - Parameter objectID: The ObjectID to identify the record.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: MultiLanguagePlace  object
   */
  @discardableResult func getObject(withID objectID: ObjectID, requestOptions: RequestOptions? = nil) throws -> Hit<MultiLanguagePlace> {
    let command = Command.Places.GetObject(objectID: objectID, requestOptions: requestOptions)
    return try transport.execute(command)
  }
    
  //MARK: - Reverse geocoding
  
  /**
   
   
   - Parameter geolocation:
   - Parameter hitsPerPage: Specify the maximum number of entries to retrieve starting at the page.
   - Parameter language: The language used to specialize the results localization
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func reverseGeocoding(geolocation: Point, hitsPerPage: Int? = nil, language: Language, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<SingleLanguageResponse>) -> Operation {
    let command = Command.Places.ReverseGeocoding(geolocation: geolocation, language: language, hitsPerPage: hitsPerPage, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
   
   
   - Parameter geolocation:
   - Parameter hitsPerPage: Specify the maximum number of entries to retrieve starting at the page.
   - Parameter language: The language used to specialize the results localization
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PlacesResponse<Hit<Place>>  object
   */
  @discardableResult func reverseGeocoding(geolocation: Point, hitsPerPage: Int? = nil, language: Language,requestOptions: RequestOptions? = nil) throws -> SingleLanguageResponse {
    let command = Command.Places.ReverseGeocoding(geolocation: geolocation, language: language, hitsPerPage: hitsPerPage, requestOptions: requestOptions)
    return try transport.execute(command)
  }
  
  
  //MARK: - Reverse geocoding multilanguage
  
  /**
   
   - Parameter geolocation:
   - Parameter hitsPerPage: Specify the maximum number of entries to retrieve starting at the page.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func reverseGeocoding(geolocation: Point, hitsPerPage: Int? = nil, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<MultiLanguageResponse>) -> Operation {
    let command = Command.Places.ReverseGeocoding(geolocation: geolocation, language: nil, hitsPerPage: hitsPerPage, requestOptions: requestOptions)
    return transport.execute(command, completion: completion)
  }
  
  /**
   
   - Parameter geolocation:
   - Parameter hitsPerPage: Specify the maximum number of entries to retrieve starting at the page.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: PlacesResponse<Hit<MultiLanguagePlace>>  object
   */
  @discardableResult func reverseGeocoding(geolocation: Point, hitsPerPage: Int? = nil,requestOptions: RequestOptions? = nil) throws -> MultiLanguageResponse {
    let command = Command.Places.ReverseGeocoding(geolocation: geolocation, language: nil, hitsPerPage: hitsPerPage, requestOptions: requestOptions)
    return try transport.execute(command)
  }

}
