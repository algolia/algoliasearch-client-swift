// APIHelper.swift
//
// Created by Algolia on 08/01/2024
//

import Foundation

public enum APIHelper {
    public static func rejectNil(_ source: [String: Any?]) -> [String: Any]? {
        let destination = source.reduce(into: [String: Any]()) { result, item in
            if let value = item.value {
                result[item.key] = value
            }
        }

        if destination.isEmpty {
            return nil
        }
        return destination
    }

    public static func rejectNilHeaders(_ source: [String: Any?]?) -> [String: String]? {
        guard let source else {
            return nil
        }

        return source.reduce(into: [String: String]()) { result, item in
            if let collection = item.value as? [Any?] {
                result[item.key] =
                    collection
                        .compactMap { value in self.convertAnyToString(value) }
                        .joined(separator: ",")
            } else if let value: Any = item.value {
                result[item.key] = self.convertAnyToString(value)
            }
        }
    }

    public static func convertAnyToString(_ value: Any?) -> String? {
        guard let value else { return nil }
        if let value = value as? any RawRepresentable {
            return "\(value.rawValue)"
        } else {
            return "\(value)"
        }
    }

    public static func mapValueToPathItem(_ source: Any) -> Any {
        if let collection = source as? [Any?] {
            return
                collection
                    .compactMap { value in self.convertAnyToString(value) }
                    .joined(separator: ",")
        }

        if let source = source as? any RawRepresentable {
            return source.rawValue
        }
        return source
    }

    /// maps all values from source to query parameters
    ///
    /// collection values are always exploded
    public static func mapValuesToQueryItems(_ source: [String: Any?]?) -> [URLQueryItem]? {
        guard let source else {
            return nil
        }

        let destination = source.filter { $0.value != nil }
            .reduce(into: [URLQueryItem]()) {
                result, item in
                if let collection = item.value as? [Any?] {
                    let collectionValues: [String] = collection
                        .compactMap { value in
                            self.convertAnyToString(value)
                        }
                    if let encodedKey = item.key.addingPercentEncoding(
                        withAllowedCharacters: .urlPathAlgoliaAllowed
                    ) {
                        result.append(
                            URLQueryItem(
                                name: encodedKey,
                                value: collectionValues.joined(separator: ",")
                                    .addingPercentEncoding(
                                        withAllowedCharacters: .urlPathAlgoliaAllowed
                                    )
                            )
                        )
                    }
                } else if let value = item.value {
                    if let encodedKey = item.key.addingPercentEncoding(
                        withAllowedCharacters: .urlPathAlgoliaAllowed
                    ) {
                        result.append(
                            URLQueryItem(
                                name: encodedKey,
                                value: self.convertAnyToString(value)?
                                    .addingPercentEncoding(
                                        withAllowedCharacters: .urlPathAlgoliaAllowed
                                    )
                            )
                        )
                    }
                }
            }

        if destination.isEmpty {
            return nil
        }
        return destination
    }
}
