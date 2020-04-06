//
//  Command+Advanced.swift
//  
//
//  Created by Vladislav Fitc on 10.03.2020.
//

import Foundation

extension Command {

  enum Advanced {

    struct TaskStatus: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, taskID: TaskID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> IndexCompletion.task(for: taskID)
        urlRequest = .init(method: .get, path: path, requestOptions: requestOptions)
      }
    }
    
    struct GetLogs: AlgoliaCommand {
      
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init(indexName: IndexName, page: Int? = 0, hitsPerPage: Int? = 0, logType: LogType, requestOptions: RequestOptions?) {
        let requestOptions = requestOptions.updateOrCreate(
          [
            .indexName: indexName.rawValue,
            .offset: page.flatMap(String.init),
            .length: hitsPerPage.flatMap(String.init),
            .type: logType.rawValue
          ]
        )
        self.requestOptions = requestOptions
        urlRequest = .init(method: .get, path: Path.logs, requestOptions: requestOptions)
      }
      
    }

  }

}

public struct LogType: Codable {
  
  let rawValue: String
  
  init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  /// Retrieve all the logs.
  static var all: Self { return .init(rawValue: #function) }
  
  /// Retrieve only the queries.
  static var query: Self { return .init(rawValue: #function) }
  
  /// Retrieve only the build operations.
  static var build: Self { return .init(rawValue: #function) }
  
  /// Retrieve only the errors.
  static var error: Self { return .init(rawValue: #function) }
  
  static func other(_ rawValue: String) -> Self { return .init(rawValue: rawValue) }
  
}

public struct LogsResponse: Codable {
  
  public let logs: [Log]
  
}

extension LogsResponse {
  
  public struct Log {
    
    /// Method timestamp
    public let timestamp: Date
    
    /// Rest type of the method.
    public let method: String
    
    /// Http response code.
    public let answerCode: String
    
    /// Request body. It’s truncated after 1000 characters.
    public let queryBody: String
    
    /// Answer body. It’s truncated after 1000 characters.
    public let answer: String
    
    /// Request URL.
    public let url: String
    
    /// Client ip of the call.
    public let ip: String
    
    /// Request Headers (API Key is obfuscated).
    public let queryHeaders: String
    
    /// SHA1 ID of entry.
    public let sha1: String
    
    /// Number of API calls.
    public let nbApiCalls: Double?
    
    /// Processing time for the query. This does not include network time.
    public let processingTimeMS: Double
    
    /// Number of hits returned for the query Query.
    public let queryNbHits: Int?
    
    /// IndexName of the log.
    public let indexName: IndexName?
    
    public let exhaustiveNbHits: Bool?
    
    public let exhaustiveFaceting: Bool?
    
    public let queryParams: String?
    
  }
  
}

extension LogsResponse.Log: Codable {
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case method
    case answerCode = "answer_code"
    case queryBody = "query_body"
    case answer
    case url
    case ip
    case queryHeaders = "query_headers"
    case sha1
    case nbAPICalls = "nb_api_calls"
    case processingTimeMS = "processing_time_ms"
    case queryNbHits = "query_nb_hits"
    case indexName = "index"
    case exhaustiveNbHits = "exhaustive_nb_hits"
    case exhaustiveFaceting = "exhaustive_faceting"
    case queryParams = "query_params"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    timestamp = try container.decode(forKey: .timestamp)
    method = try container.decode(forKey: .method)
    answerCode = try container.decode(forKey: .answerCode)
    queryBody = try container.decode(forKey: .queryBody)
    answer = try container.decode(forKey: .answer)
    url = try container.decode(forKey: .url)
    ip = try container.decode(forKey: .ip)
    queryHeaders = try container.decode(forKey: .queryHeaders)
    sha1 = try container.decode(forKey: .sha1)
    nbApiCalls = try container.decodeIfPresent(forKey: .nbAPICalls)
    processingTimeMS = try container.decode(forKey: .processingTimeMS)
    queryNbHits = try container.decodeIfPresent(forKey: .queryNbHits)
    indexName = try container.decodeIfPresent(forKey: .indexName)
    exhaustiveNbHits = try container.decode(forKey: .exhaustiveNbHits)
    exhaustiveFaceting = try container.decode(forKey: .exhaustiveFaceting)
    queryParams = try container.decodeIfPresent(forKey: .queryParams)

  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(timestamp, forKey: .timestamp)
    try container.encode(method, forKey: .method)
    try container.encode(answerCode, forKey: .answerCode)
    try container.encode(queryBody, forKey: .queryBody)
    try container.encode(answer, forKey: .answer)
    try container.encode(url, forKey: .url)
    try container.encode(ip, forKey: .ip)
    try container.encode(queryHeaders, forKey: .queryHeaders)
    try container.encode(sha1, forKey: .sha1)
    try container.encodeIfPresent(nbApiCalls, forKey: .nbAPICalls)
    try container.encode(processingTimeMS, forKey: .processingTimeMS)
    try container.encodeIfPresent(queryNbHits, forKey: .queryNbHits)
    try container.encodeIfPresent(indexName, forKey: .indexName)
    try container.encode(exhaustiveNbHits, forKey: .exhaustiveNbHits)
    try container.encode(exhaustiveFaceting, forKey: .exhaustiveFaceting)
    try container.encodeIfPresent(queryParams, forKey: .queryParams)
  }
  
}
