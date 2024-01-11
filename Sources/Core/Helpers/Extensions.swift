// Extensions.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if canImport(AnyCodable)
  import AnyCodable
#endif

extension Bool: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension Float: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension Int: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension Int32: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension Int64: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension Double: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension Decimal: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension String: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension URL: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension UUID: JSONEncodable {
  public func encodeToJSON() -> Any { self }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public func encodeToJSON() -> Any { return self.rawValue }
}

private func encodeIfPossible<T>(_ object: T) -> Any {
  if let encodableObject = object as? JSONEncodable {
    return encodableObject.encodeToJSON()
  } else {
    return object
  }
}

extension Array: JSONEncodable {
  public func encodeToJSON() -> Any {
    return self.map(encodeIfPossible)
  }
}

extension Set: JSONEncodable {
  public func encodeToJSON() -> Any {
    return Array(self).encodeToJSON()
  }
}

extension Dictionary: JSONEncodable {
  public func encodeToJSON() -> Any {
    var dictionary = [AnyHashable: Any]()
    for (key, value) in self {
      dictionary[key] = encodeIfPossible(value)
    }
    return dictionary
  }
}

extension Data: JSONEncodable {
  public func encodeToJSON() -> Any {
    return self.base64EncodedString(options: Data.Base64EncodingOptions())
  }
}

extension Date: JSONEncodable {
  public func encodeToJSON() -> Any {
    return CodableHelper.dateFormatter.string(from: self)
  }
}

extension JSONEncodable where Self: Encodable {
  public func encodeToJSON() -> Any {
    guard let data = try? CodableHelper.jsonEncoder.encode(self) else {
      fatalError("Could not encode to json: \(self)")
    }
    return data.encodeToJSON()
  }
}

extension String: CodingKey {

  public var stringValue: String {
    return self
  }

  public init?(stringValue: String) {
    self.init(stringLiteral: stringValue)
  }

  public var intValue: Int? {
    return nil
  }

  public init?(intValue: Int) {
    return nil
  }

}

extension KeyedEncodingContainerProtocol {

  public mutating func encodeArray<T>(_ values: [T], forKey key: Self.Key) throws
  where T: Encodable {
    var arrayContainer = nestedUnkeyedContainer(forKey: key)
    try arrayContainer.encode(contentsOf: values)
  }

  public mutating func encodeArrayIfPresent<T>(_ values: [T]?, forKey key: Self.Key) throws
  where T: Encodable {
    if let values = values {
      try encodeArray(values, forKey: key)
    }
  }

  public mutating func encodeMap<T>(_ pairs: [Self.Key: T]) throws where T: Encodable {
    for (key, value) in pairs {
      try encode(value, forKey: key)
    }
  }

  public mutating func encodeMapIfPresent<T>(_ pairs: [Self.Key: T]?) throws where T: Encodable {
    if let pairs = pairs {
      try encodeMap(pairs)
    }
  }

  public mutating func encode(_ value: Decimal, forKey key: Self.Key) throws {
    var mutableValue = value
    let stringValue = NSDecimalString(&mutableValue, Locale(identifier: "en_US"))
    try encode(stringValue, forKey: key)
  }

  public mutating func encodeIfPresent(_ value: Decimal?, forKey key: Self.Key) throws {
    if let value = value {
      try encode(value, forKey: key)
    }
  }
}

extension KeyedDecodingContainerProtocol {

  public func decodeArray<T>(_ type: T.Type, forKey key: Self.Key) throws -> [T]
  where T: Decodable {
    var tmpArray = [T]()

    var nestedContainer = try nestedUnkeyedContainer(forKey: key)
    while !nestedContainer.isAtEnd {
      let arrayValue = try nestedContainer.decode(T.self)
      tmpArray.append(arrayValue)
    }

    return tmpArray
  }

  public func decodeArrayIfPresent<T>(_ type: T.Type, forKey key: Self.Key) throws -> [T]?
  where T: Decodable {
    var tmpArray: [T]?

    if contains(key) {
      tmpArray = try decodeArray(T.self, forKey: key)
    }

    return tmpArray
  }

  public func decodeMap<T>(_ type: T.Type, excludedKeys: Set<Self.Key>) throws -> [Self.Key: T]
  where T: Decodable {
    var map: [Self.Key: T] = [:]

    for key in allKeys {
      if !excludedKeys.contains(key) {
        let value = try decode(T.self, forKey: key)
        map[key] = value
      }
    }

    return map
  }

  public func decode(_ type: Decimal.Type, forKey key: Self.Key) throws -> Decimal {
    let stringValue = try decode(String.self, forKey: key)
    guard let decimalValue = Decimal(string: stringValue) else {
      let context = DecodingError.Context(
        codingPath: [key],
        debugDescription: "The key \(key) couldn't be converted to a Decimal value")
      throw DecodingError.typeMismatch(type, context)
    }

    return decimalValue
  }

  public func decodeIfPresent(_ type: Decimal.Type, forKey key: Self.Key) throws -> Decimal? {
    guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
      return nil
    }
    guard let decimalValue = Decimal(string: stringValue) else {
      let context = DecodingError.Context(
        codingPath: [key],
        debugDescription: "The key \(key) couldn't be converted to a Decimal value")
      throw DecodingError.typeMismatch(type, context)
    }

    return decimalValue
  }

}

extension HTTPURLResponse {
  var isStatusCodeSuccessful: Bool {
    return HTTPStatusCategory.success.contains(statusCode)
  }
}

extension URLRequest: Builder {}
extension URLComponents: Builder {}

extension URLRequest {

  @discardableResult func switchingHost(
    by host: RetryableHost, withBaseTimeout baseTimeout: TimeInterval
  ) throws -> URLRequest {
    guard let url = url else { throw FormatError.missingURL }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      throw FormatError.malformedURL(url.absoluteString)
    }
    guard let updatedURL = components.set(\.host, to: host.url.absoluteString).url else {
      throw FormatError.badHost(host.url.absoluteString)
    }
    let updatedTimeout = TimeInterval(host.retryCount + 1) * baseTimeout
    return
      self
      .set(\.url, to: updatedURL)
      .set(\.timeoutInterval, to: updatedTimeout)
  }

}

extension URLRequest {

  public enum FormatError: LocalizedError {
    case missingURL
    case malformedURL(String)
    case badHost(String)
    case invalidPath(String)
    case invalidQueryItems

    public var errorDescription: String? {
      let contactUs = "Please contact support@algolia.com if this problem occurs."
      switch self {
      case .badHost(let host):
        return "Bad host: \(host). Will retry with next host. " + contactUs
      case .malformedURL(let url):
        return "Command's request URL is malformed: \(url). " + contactUs
      case .missingURL:
        return "Command's request doesn't contain URL. " + contactUs
      case .invalidPath(let path):
        return "Invalid path: \(path)"
      case .invalidQueryItems:
        return "Invalid query items. " + contactUs
      }
    }
  }

}
