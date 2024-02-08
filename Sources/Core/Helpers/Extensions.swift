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

public extension RawRepresentable where RawValue: JSONEncodable {
    func encodeToJSON() -> Any { rawValue }
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
        map(encodeIfPossible)
    }
}

extension Set: JSONEncodable {
    public func encodeToJSON() -> Any {
        Array(self).encodeToJSON()
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
        guard let selfString = String(data: self, encoding: .utf8) else {
            fatalError("Could not decode data string: \(self)")
        }

        let jsonData = "{\"data\":\(selfString)}".data(using: .utf8)
        guard let jsonData = jsonData, let json = try? CodableHelper.jsonDecoder.decode([String: String].self, from: jsonData) else {
            fatalError("Could not decode from data holder: \(jsonData)")
        }

        return json["data"]
    }
}

extension Date: JSONEncodable {
    public func encodeToJSON() -> Any {
        CodableHelper.dateFormatter.string(from: self)
    }
}

public extension AbstractEncodable {
    func encodeToJSON() -> Any {
        encodeIfPossible(GetActualInstance())
    }
}

public extension JSONEncodable where Self: Encodable {
    func encodeToJSON() -> Any {
        guard let data = try? CodableHelper.jsonEncoder.encode(self) else {
            fatalError("Could not encode to json: \(self)")
        }
        return data.encodeToJSON()
    }
}

extension String: CodingKey {
    public var stringValue: String {
        self
    }

    public init?(stringValue: String) {
        self.init(stringLiteral: stringValue)
    }

    public var intValue: Int? {
        nil
    }

    public init?(intValue _: Int) {
        nil
    }
}

public extension KeyedEncodingContainerProtocol {
    mutating func encodeArray<T>(_ values: [T], forKey key: Self.Key) throws
        where T: Encodable
    {
        var arrayContainer = nestedUnkeyedContainer(forKey: key)
        try arrayContainer.encode(contentsOf: values)
    }

    mutating func encodeArrayIfPresent<T>(_ values: [T]?, forKey key: Self.Key) throws
        where T: Encodable
    {
        if let values = values {
            try encodeArray(values, forKey: key)
        }
    }

    mutating func encodeMap<T>(_ pairs: [Self.Key: T]) throws where T: Encodable {
        for (key, value) in pairs {
            try encode(value, forKey: key)
        }
    }

    mutating func encodeMapIfPresent<T>(_ pairs: [Self.Key: T]?) throws where T: Encodable {
        if let pairs = pairs {
            try encodeMap(pairs)
        }
    }

    mutating func encode(_ value: Decimal, forKey key: Self.Key) throws {
        var mutableValue = value
        let stringValue = NSDecimalString(&mutableValue, Locale(identifier: "en_US"))
        try encode(stringValue, forKey: key)
    }

    mutating func encodeIfPresent(_ value: Decimal?, forKey key: Self.Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
}

public extension KeyedDecodingContainerProtocol {
    func decodeArray<T>(_: T.Type, forKey key: Self.Key) throws -> [T]
        where T: Decodable
    {
        var tmpArray = [T]()

        var nestedContainer = try nestedUnkeyedContainer(forKey: key)
        while !nestedContainer.isAtEnd {
            let arrayValue = try nestedContainer.decode(T.self)
            tmpArray.append(arrayValue)
        }

        return tmpArray
    }

    func decodeArrayIfPresent<T>(_: T.Type, forKey key: Self.Key) throws -> [T]?
        where T: Decodable
    {
        var tmpArray: [T]?

        if contains(key) {
            tmpArray = try decodeArray(T.self, forKey: key)
        }

        return tmpArray
    }

    func decodeMap<T>(_: T.Type, excludedKeys: Set<Self.Key>) throws -> [Self.Key: T]
        where T: Decodable
    {
        var map: [Self.Key: T] = [:]

        for key in allKeys {
            if !excludedKeys.contains(key) {
                let value = try decode(T.self, forKey: key)
                map[key] = value
            }
        }

        return map
    }

    func decode(_ type: Decimal.Type, forKey key: Self.Key) throws -> Decimal {
        let stringValue = try decode(String.self, forKey: key)
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(
                codingPath: [key],
                debugDescription: "The key \(key) couldn't be converted to a Decimal value"
            )
            throw DecodingError.typeMismatch(type, context)
        }

        return decimalValue
    }

    func decodeIfPresent(_ type: Decimal.Type, forKey key: Self.Key) throws -> Decimal? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(
                codingPath: [key],
                debugDescription: "The key \(key) couldn't be converted to a Decimal value"
            )
            throw DecodingError.typeMismatch(type, context)
        }

        return decimalValue
    }
}

extension HTTPURLResponse {
    var isStatusCodeSuccessful: Bool {
        HTTPStatusCategory.success.contains(statusCode)
    }
}

extension URLRequest: Builder {}
extension URLComponents: Builder {}

public extension URLRequest {
    enum FormatError: LocalizedError {
        case missingURL
        case malformedURL(String)
        case badHost(String)
        case invalidPath(String)
        case invalidQueryItems

        public var errorDescription: String? {
            let contactUs = "Please contact support@algolia.com if this problem occurs."
            switch self {
            case let .badHost(host):
                return "Bad host: \(host). Will retry with next host. " + contactUs
            case let .malformedURL(url):
                return "Command's request URL is malformed: \(url). " + contactUs
            case .missingURL:
                return "Command's request doesn't contain URL. " + contactUs
            case let .invalidPath(path):
                return "Invalid path: \(path)"
            case .invalidQueryItems:
                return "Invalid query items. " + contactUs
            }
        }
    }
}
