// Models.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol JSONEncodable {
  func encodeToJSON() -> Any
}

/// An enum where the last case value can be used as a default catch-all.
protocol CaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable
where RawValue: Decodable, AllCases: BidirectionalCollection {}

extension CaseIterableDefaultsLast {
  /// Initializes an enum such that if a known raw value is found, then it is decoded.
  /// Otherwise the last case is used.
  /// - Parameter decoder: A decoder.
  public init(from decoder: Decoder) throws {
    if let value = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) {
      self = value
    } else if let lastValue = Self.allCases.last {
      self = lastValue
    } else {
      throw DecodingError.valueNotFound(
        Self.Type.self,
        .init(codingPath: decoder.codingPath, debugDescription: "CaseIterableDefaultsLast")
      )
    }
  }
}

/// A flexible type that can be encoded (`.encodeNull` or `.encodeValue`)
/// or not encoded (`.encodeNothing`). Intended for request payloads.
public enum NullEncodable<Wrapped: Hashable>: Hashable {
  case encodeNothing
  case encodeNull
  case encodeValue(Wrapped)
}

extension NullEncodable: Codable where Wrapped: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(Wrapped.self) {
      self = .encodeValue(value)
    } else if container.decodeNil() {
      self = .encodeNull
    } else {
      self = .encodeNothing
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .encodeNothing: return
    case .encodeNull: try container.encodeNil()
    case .encodeValue(let wrapped): try container.encode(wrapped)
    }
  }
}

public enum ErrorResponse: Error {
  case error(Int, Data?, URLResponse?, Error)
}

public enum DownloadException: Error {
  case responseDataMissing
  case responseFailed
  case requestMissing
  case requestMissingPath
  case requestMissingURL
}

public enum DecodableRequestBuilderError: Error {
  case emptyDataResponse
  case nilHTTPResponse
  case unsuccessfulHTTPStatusCode
  case jsonDecoding(DecodingError)
  case generalError(Error)
}

open class Response<T> {
  public let statusCode: Int
  public let headers: [String: String]
  public let body: T
  public let bodyData: Data?
  public let httpResponse: HTTPURLResponse

  public init(response: HTTPURLResponse, body: T, bodyData: Data?) {
    let rawHeader = response.allHeaderFields
    var responseHeaders = [String: String]()
    for (key, value) in rawHeader {
      if let key = key.base as? String, let value = value as? String {
        responseHeaders[key] = value
      }
    }

    self.statusCode = response.statusCode
    self.headers = responseHeaders
    self.body = body
    self.bodyData = bodyData
    self.httpResponse = response
  }
}
