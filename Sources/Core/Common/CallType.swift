//
//  CallType.swift
//
//
//  Created by Algolia on 15/12/2023.
//

import Foundation

/// Indicate whether the HTTP call performed is of type [read] (GET) or [write] (POST, PUT ..).
/// Used to determine which timeout duration to use.
public enum CallType {
    case read
    case write
}

extension CallType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .read:
            "read"
        case .write:
            "write"
        }
    }
}

public extension HTTPMethod {
    func toCallType() -> CallType {
        switch self {
        case .get:
            .read
        default:
            .write
        }
    }
}
