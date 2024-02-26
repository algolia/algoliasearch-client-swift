//
//  SecuredAPIKeyRestriction.swift
//
//
//  Created by Algolia on 26/02/2024.
//

import Core
import Foundation

public struct SecuredAPIKeyRestriction {
    let searchParams: SearchParamsObject?
    let validUntil: TimeInterval?
    let restrictIndices: [String]?
    let restrictSources: [String]?
    let userToken: String?

    public init(
        searchParams: SearchParamsObject? = nil,
        validUntil: TimeInterval? = nil,
        restrictIndices: [String]? = nil,
        restrictSources: [String]? = nil,
        userToken: String? = nil
    ) {
        self.searchParams = searchParams
        self.validUntil = validUntil
        self.restrictIndices = restrictIndices
        self.restrictSources = restrictSources
        self.userToken = userToken
    }

    func toURLEncodedString() throws -> String {
        var queryDictionary: [String: Any] = [:]

        if let searchParams {
            let searchParamsData = try CodableHelper.jsonEncoder.encode(self.searchParams)
            guard let searchParamsDictionary = try JSONSerialization.jsonObject(
                with: searchParamsData,
                options: .fragmentsAllowed
            ) as? [String: Any] else {
                throw AlgoliaError.runtimeError("Unable to encode Secured API Key Restrictions search parameters")
            }

            queryDictionary = searchParamsDictionary
        }

        if let validUntil {
            queryDictionary["validUntil"] = Int(validUntil)
        }
        if let restrictIndices {
            queryDictionary["restrictIndices"] = restrictIndices
        }
        if let restrictSources {
            queryDictionary["restrictSources"] = restrictSources
        }
        if let userToken {
            queryDictionary["userToken"] = userToken
        }

        return (APIHelper.mapValuesToQueryItems(queryDictionary) ?? [])
            .map { "\($0.name)=\($0.value ?? "null")" }
            .joined(separator: "&")
    }
}
