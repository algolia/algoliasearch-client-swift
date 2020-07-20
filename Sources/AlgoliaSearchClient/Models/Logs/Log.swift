//
//  Log.swift
//  
//
//  Created by Vladislav Fitc on 07/04/2020.
//

import Foundation

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
  public let nbApiCalls: Int?

  /// Processing time for the query. This does not include network time.
  public let processingTimeMS: Int

  /// Number of hits returned for the query Query.
  public let queryNbHits: Int?

  /// IndexName of the log.
  public let indexName: IndexName?

  /// Contains an object for each performed query with the indexName, queryID, offset, and userToken.
  public let innerQueries: [InnerQuery]?

  public let exhaustiveNbHits: Bool?

  public let exhaustiveFaceting: Bool?

  public let queryParams: String?

}

extension Log: CustomStringConvertible {

  public var description: String {
    return "\(url) \(method) \(answerCode) \(timestamp)"
  }

}

extension Log: Codable {

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
    case innerQueries = "inner_queries"
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
    nbApiCalls = (try container.decodeIfPresent(StringNumberContainer.self, forKey: .nbAPICalls))?.intValue
    processingTimeMS = (try container.decode(StringNumberContainer.self, forKey: .processingTimeMS)).intValue
    queryNbHits = (try container.decodeIfPresent(StringNumberContainer.self, forKey: .queryNbHits))?.intValue
    indexName = try container.decodeIfPresent(forKey: .indexName)
    exhaustiveNbHits = try container.decodeIfPresent(forKey: .exhaustiveNbHits)
    exhaustiveFaceting = try container.decodeIfPresent(forKey: .exhaustiveFaceting)
    queryParams = try container.decodeIfPresent(forKey: .queryParams)
    innerQueries = try container.decodeIfPresent(forKey: .innerQueries)
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
    try container.encodeIfPresent(exhaustiveNbHits, forKey: .exhaustiveNbHits)
    try container.encodeIfPresent(exhaustiveFaceting, forKey: .exhaustiveFaceting)
    try container.encodeIfPresent(queryParams, forKey: .queryParams)
    try container.encodeIfPresent(innerQueries, forKey: .innerQueries)
  }

}

extension Log {

  public struct InnerQuery: Codable {

    public let indexName: IndexName?
    public let queryID: QueryID?
    public let offset: Int?
    public let userToken: UserToken?

    enum CodingKeys: String, CodingKey {
      case indexName = "index_name"
      case queryID = "query_id"
      case offset
      case userToken = "user_token"
    }

  }

}
