// Extensions.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
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

private func encodeIfPossible(_ object: some Any) -> Any {
    if let encodableObject = object as? JSONEncodable {
        encodableObject.encodeToJSON()
    } else {
        object
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

extension Dictionary: JSONEncodable where Key == String {
    public func encodeToJSON() -> Any {
        var dictionary = [String: Any]()
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
        guard let jsonData,
              let json = try? CodableHelper.jsonDecoder.decode([String: AnyCodable].self, from: jsonData) else {
            fatalError("Could not decode from data holder: `{\"data\":\(selfString)}`")
        }

        return json["data"] as Any
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
    mutating func encodeArray(_ values: [some Encodable], forKey key: Self.Key) throws {
        var arrayContainer = nestedUnkeyedContainer(forKey: key)
        try arrayContainer.encode(contentsOf: values)
    }

    mutating func encodeArrayIfPresent(_ values: [some Encodable]?, forKey key: Self.Key) throws {
        if let values {
            try self.encodeArray(values, forKey: key)
        }
    }

    mutating func encodeMap(_ pairs: [Self.Key: some Encodable]) throws {
        for (key, value) in pairs {
            try self.encode(value, forKey: key)
        }
    }

    mutating func encodeMapIfPresent(_ pairs: [Self.Key: some Encodable]?) throws {
        if let pairs {
            try self.encodeMap(pairs)
        }
    }
}

public extension KeyedDecodingContainerProtocol {
    func decodeArray<T>(_: T.Type, forKey key: Self.Key) throws -> [T]
    where T: Decodable {
        var tmpArray = [T]()

        var nestedContainer = try nestedUnkeyedContainer(forKey: key)
        while !nestedContainer.isAtEnd {
            let arrayValue = try nestedContainer.decode(T.self)
            tmpArray.append(arrayValue)
        }

        return tmpArray
    }

    func decodeArrayIfPresent<T>(_: T.Type, forKey key: Self.Key) throws -> [T]?
    where T: Decodable {
        var tmpArray: [T]?

        if contains(key) {
            tmpArray = try self.decodeArray(T.self, forKey: key)
        }

        return tmpArray
    }

    func decodeMap<T>(_: T.Type, excludedKeys: Set<Self.Key>) throws -> [Self.Key: T]
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
}

extension HTTPURLResponse {
    var isStatusCodeSuccessful: Bool {
        HTTPStatusCategory.success.contains(statusCode)
    }
}

public extension URLRequest {
    enum FormatError: LocalizedError {
        case missingURL
        case malformedURL(String)
        case badHost(String)
        case invalidPath(String)
        case invalidQueryItems

        public var errorDescription: String? {
            let contactUs = "Please contact https://alg.li/support if this problem occurs."
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
