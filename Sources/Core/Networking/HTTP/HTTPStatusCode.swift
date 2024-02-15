//
//  HTTPStatusCode.swift
//
//
//  Created by Algolia on 20/02/2020.
//

import Foundation

public typealias HTTPStatusСode = Int

extension HTTPStatusСode {
    static let badRequest: HTTPStatusСode = 400
    static let notFound: HTTPStatusСode = 404
    static let requestTimeout: HTTPStatusСode = 408
    static let tooManyRequests: HTTPStatusСode = 429

    func belongs(to categories: HTTPStatusCategory...) -> Bool {
        categories.map { $0.contains(self) }.contains(true)
    }

    var isError: Bool {
        self.belongs(to: .clientError, .serverError)
    }
}

// MARK: - HTTPStatusCategory

enum HTTPStatusCategory {
    case informational
    case success
    case redirection
    case clientError
    case serverError

    var range: Range<Int> {
        switch self {
        case .informational:
            100 ..< 200
        case .success:
            200 ..< 300
        case .redirection:
            300 ..< 400
        case .clientError:
            400 ..< 500
        case .serverError:
            500 ..< 600
        }
    }

    func contains(_ statusCode: HTTPStatusСode) -> Bool {
        self.range.contains(statusCode)
    }
}
