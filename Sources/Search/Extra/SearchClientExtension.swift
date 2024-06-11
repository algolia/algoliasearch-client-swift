//
//  SearchClientExtension.swift
//
//
//  Created by Algolia on 26/02/2024.
//

#if canImport(Core)
    import Core
#endif
import Foundation

public extension SearchClient {
    /// Wait for a task to complete
    /// - parameter taskID: The id of the task to wait for
    /// - parameter indexName: The name of the index to wait for
    /// - parameter maxRetries: The maximum number of retries
    /// - parameter initialDelay: The initial delay between retries
    /// - parameter maxDelay: The maximum delay between retries
    /// - returns: GetTaskResponse
    @discardableResult
    func waitForTask(
        with taskID: Int64,
        in indexName: String,
        maxRetries: Int = 50,
        timeout: (Int) -> TimeInterval = { count in
            min(TimeInterval(count) * 0.2, 5)
        },
        requestOptions: RequestOptions? = nil
    ) async throws -> GetTaskResponse {
        var retryCount = 0

        return try await createIterable(
            execute: { _ in
                try await self.getTask(indexName: indexName, taskID: taskID, requestOptions: requestOptions)
            },
            validate: { response in
                response.status == SearchTaskStatus.published
            },
            aggregator: { _ in
                retryCount += 1
            },
            timeout: {
                timeout(retryCount)
            },
            error: IterableError(
                validate: { _ in
                    retryCount >= maxRetries
                },
                message: { _ in
                    "The maximum number of retries exceeded. (\(retryCount)/\(maxRetries))"
                }
            )
        )
    }

    /// Wait for an application-level task to complete
    /// - parameter taskID: The id of the task to wait for
    /// - parameter maxRetries: The maximum number of retries
    /// - parameter initialDelay: The initial delay between retries
    /// - parameter maxDelay: The maximum delay between retries
    /// - returns: GetTaskResponse
    @discardableResult
    func waitForAppTask(
        with taskID: Int64,
        maxRetries: Int = 50,
        timeout: (Int) -> TimeInterval = { count in
            min(TimeInterval(count) * 0.2, 5)
        },
        requestOptions: RequestOptions? = nil
    ) async throws -> GetTaskResponse {
        var retryCount = 0

        return try await createIterable(
            execute: { _ in
                try await self.getAppTask(taskID: taskID, requestOptions: requestOptions)
            },
            validate: { response in
                response.status == SearchTaskStatus.published
            },
            aggregator: { _ in
                retryCount += 1
            },
            timeout: {
                timeout(retryCount)
            },
            error: IterableError(
                validate: { _ in
                    retryCount >= maxRetries
                },
                message: { _ in
                    "The maximum number of retries exceeded. (\(retryCount)/\(maxRetries))"
                }
            )
        )
    }

    /// Wait for an API key to be available
    /// - parameter key: The key to wait for
    /// - parameter operation: The type of operation
    /// - parameter apiKey: The original API key
    /// - parameter maxRetries: The maximum number of retries
    /// - parameter timeout: A closure that computes the timeout in seconds for the next retry
    /// - parameter requestOptions: The request options
    /// - returns: GetApiKeyResponse?
    @discardableResult
    func waitForApiKey(
        with key: String,
        operation: ApiKeyOperation,
        apiKey: ApiKey? = nil,
        maxRetries: Int = 50,
        timeout: (Int) -> TimeInterval = { retryCount in
            min(TimeInterval(retryCount) * 0.2, 5)
        },
        requestOptions: RequestOptions? = nil
    ) async throws -> GetApiKeyResponse? {
        var retryCount = 0

        if operation == .update {
            guard let apiKey else {
                throw AlgoliaError.runtimeError("Missing API key optimistic value")
            }

            return try await createIterable(
                execute: { _ in
                    try await self.getApiKey(key: key, requestOptions: requestOptions)
                },
                validate: { response in
                    if apiKey.description != response.description {
                        return false
                    }

                    if apiKey.queryParameters != response.queryParameters {
                        return false
                    }

                    if apiKey.maxHitsPerQuery != response.maxHitsPerQuery {
                        return false
                    }

                    if apiKey.maxQueriesPerIPPerHour != response.maxQueriesPerIPPerHour {
                        return false
                    }

                    if apiKey.validity != response.validity {
                        return false
                    }

                    let expectedACLs = apiKey.acl.sorted { $0.rawValue > $1.rawValue }
                    let responseACLs = response.acl.sorted { $0.rawValue > $1.rawValue }
                    if expectedACLs != responseACLs {
                        return false
                    }

                    let expectedIndexes = apiKey.indexes?.sorted { $0 > $1 }
                    let responseIndexes = response.indexes?.sorted { $0 > $1 }
                    if expectedIndexes != responseIndexes {
                        return false
                    }

                    let expectedReferers = apiKey.referers?.sorted { $0 > $1 }
                    let responseReferers = response.referers?.sorted { $0 > $1 }
                    if expectedReferers != responseReferers {
                        return false
                    }

                    return true
                },
                aggregator: { _ in
                    retryCount += 1
                },
                timeout: {
                    timeout(retryCount)
                },
                error: IterableError(
                    validate: { _ in
                        retryCount >= maxRetries
                    },
                    message: { _ in
                        "The maximum number of retries exceeded. (\(retryCount)/\(maxRetries))"
                    }
                )
            )
        }

        return try await createIterable(
            execute: { _ in
                let response = try await self.getApiKeyWithHTTPInfo(key: key, requestOptions: requestOptions)
                if response.statusCode == 404 {
                    return nil
                }

                return response.body
            },
            validate: { response in
                switch operation {
                case .add:
                    guard let response else {
                        return false
                    }

                    return response.createdAt > 0
                case .delete:
                    return response == nil
                default:
                    return false
                }
            },
            aggregator: { _ in
                retryCount += 1
            },
            timeout: {
                timeout(retryCount)
            },
            error: IterableError(
                validate: { _ in
                    retryCount >= maxRetries
                },
                message: { _ in
                    "The maximum number of retries exceeded. (\(retryCount)/\(maxRetries))"
                }
            )
        )
    }

    /// Allows to aggregate all the hits returned by the API calls
    /// - parameter indexName: The name of the index to browse
    /// - parameter browseParams: The browse request parameters
    /// - parameter validate: A closure that validates the response
    /// - parameter aggregator: A closure that aggregates the response
    /// - parameter requestOptions: The request options
    /// - returns: BrowseResponse
    @discardableResult
    func browseObjects<T: Codable>(
        in indexName: String,
        browseParams: BrowseParamsObject,
        validate: (BrowseResponse<T>) -> Bool = { response in
            response.cursor == nil
        },
        aggregator: @escaping (BrowseResponse<T>) -> Void,
        requestOptions: RequestOptions? = nil
    ) async throws -> BrowseResponse<T> {
        try await createIterable(
            execute: { previousResponse in
                var updatedBrowseParams = browseParams
                if let previousResponse {
                    updatedBrowseParams.cursor = previousResponse.cursor
                }

                return try await self.browse(
                    indexName: indexName,
                    browseParams: .browseParamsObject(updatedBrowseParams),
                    requestOptions: requestOptions
                )
            },
            validate: validate,
            aggregator: aggregator
        )
    }

    /// Allows to aggregate all the rules returned by the API calls
    /// - parameter indexName: The name of the index to browse
    /// - parameter searchRulesParams: The search rules request parameters
    /// - parameter validate: A closure that validates the response
    /// - parameter aggregator: A closure that aggregates the response
    /// - parameter requestOptions: The request options
    /// - returns: SearchRulesResponse
    @discardableResult
    func browseRules(
        in indexName: String,
        searchRulesParams: SearchRulesParams,
        validate: ((SearchRulesResponse) -> Bool)? = nil,
        aggregator: @escaping (SearchRulesResponse) -> Void,
        requestOptions: RequestOptions? = nil
    ) async throws -> SearchRulesResponse {
        let hitsPerPage = searchRulesParams.hitsPerPage ?? 1000

        return try await createIterable(
            execute: { previousResponse in
                var updatedSearchRulesParams = searchRulesParams

                updatedSearchRulesParams.hitsPerPage = hitsPerPage

                if let previousResponse {
                    updatedSearchRulesParams.page = previousResponse.page + 1
                }
                if updatedSearchRulesParams.page == nil {
                    updatedSearchRulesParams.page = 0
                }

                return try await self.searchRules(
                    indexName: indexName,
                    searchRulesParams: updatedSearchRulesParams,
                    requestOptions: requestOptions
                )
            },
            validate: validate ?? { response in
                response.nbHits < hitsPerPage
            },
            aggregator: aggregator
        )
    }

    /// Allows to aggregate all the synonyms returned by the API calls
    /// - parameter indexName: The name of the index to browse
    /// - parameter searchSynonymsParams: The search synonyms request parameters
    /// - parameter validate: A closure that validates the response
    /// - parameter aggregator: A closure that aggregates the response
    /// - parameter requestOptions: The request options
    /// - returns: SearchSynonymsResponse
    @discardableResult
    func browseSynonyms(
        in indexName: String,
        searchSynonymsParams: SearchSynonymsParams,
        validate: ((SearchSynonymsResponse) -> Bool)? = nil,
        aggregator: @escaping (SearchSynonymsResponse) -> Void,
        requestOptions: RequestOptions? = nil
    ) async throws -> SearchSynonymsResponse {
        let hitsPerPage = searchSynonymsParams.hitsPerPage ?? 1000

        var updatedSearchSynonymsParams = searchSynonymsParams
        if updatedSearchSynonymsParams.page == nil {
            updatedSearchSynonymsParams.page = 0
        }

        return try await createIterable(
            execute: { _ in
                updatedSearchSynonymsParams.hitsPerPage = hitsPerPage

                defer {
                    updatedSearchSynonymsParams.page! += 1
                }

                return try await self.searchSynonyms(
                    indexName: indexName,
                    searchSynonymsParams: updatedSearchSynonymsParams,
                    requestOptions: requestOptions
                )
            },
            validate: validate ?? { response in
                response.nbHits < hitsPerPage
            },
            aggregator: aggregator
        )
    }

    /// Helper: calls the `search` method but with certainty that we will only request Algolia records (hits) and not
    /// facets. In the responses, the `hits` property is list of records casted as the provided generic type parameter.
    /// You can use `Hit` as a default.
    /// Disclaimer: We don't assert that the parameters you pass to this method only contains `hits` requests to prevent
    /// impacting search performances, this helper is purely for typing purposes.
    func searchForHitsWithResponse<T: Codable>(
        searchMethodParams: SearchMethodParams,
        requestOptions: RequestOptions? = nil
    ) async throws -> [SearchResponse<T>] {
        let searchResponses: SearchResponses<T> = try await self.search(
            searchMethodParams: searchMethodParams,
            requestOptions: requestOptions
        )
        return searchResponses.results.reduce(into: [SearchResponse<T>]()) { acc, cur in
            switch cur {
            case let .searchResponse(searchResponse):
                acc.append(searchResponse)
            case .searchForFacetValuesResponse:
                break
            }
        }
    }

    /// Helper: calls the `search` method but with certainty that we will only request Algolia records (hits) and not
    /// facets. It returns the records casted as the provided generic type parameter. You can use `Hit` as a default.
    /// Disclaimer: We don't assert that the parameters you pass to this method only contains `hits` requests to prevent
    /// impacting search performances, this helper is purely for typing purposes.
    func searchForHits<T: Codable>(
        searchMethodParams: SearchMethodParams,
        requestOptions: RequestOptions? = nil
    ) async throws -> [T] {
        let searchResponses: SearchResponses<T> = try await self.search(
            searchMethodParams: searchMethodParams,
            requestOptions: requestOptions
        )
        return searchResponses.results.reduce(into: [T]()) { acc, cur in
            switch cur {
            case let .searchResponse(searchResponse):
                acc.append(contentsOf: searchResponse.hits)
            case .searchForFacetValuesResponse:
                break
            }
        }
    }

    /// Helper: calls the `search` method but with certainty that we will only request Algolia facets and not records
    /// (hits).
    /// Disclaimer: We don't assert that the parameters you pass to this method only contains `facets` requests to
    /// prevent impacting search performances, this helper is purely for typing purposes.
    func searchForFacets(
        searchMethodParams: SearchMethodParams,
        requestOptions: RequestOptions? = nil
    ) async throws -> [SearchForFacetValuesResponse] {
        let searchResponses: SearchResponses<Hit> = try await self.search(
            searchMethodParams: searchMethodParams,
            requestOptions: requestOptions
        )
        return searchResponses.results.reduce(into: [SearchForFacetValuesResponse]()) { acc, cur in
            switch cur {
            case .searchResponse:
                break
            case let .searchForFacetValuesResponse(searchForFacet):
                acc.append(searchForFacet)
            }
        }
    }

    /// Chunks the given `objects` list in subset of `batchSize` elements max in order to make it fit in `batch`
    /// requests.
    /// - parameter indexName: The name of the index where to replace the objects
    /// - parameter objects: The new objects
    /// - parameter action: The type of action to apply of each object
    /// - parameter waitForTasks: If we should wait for the batch task to be finished before processing the next one
    /// - parameter batchSize: The maximum number of objects to include in a batch
    /// - parameter requestOptions: The request options
    /// - returns: [BatchResponse]
    func chunkedBatch(
        indexName: String,
        objects: [some Encodable],
        action: Action = .addObject,
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil
    ) async throws -> [BatchResponse] {
        let batches = stride(from: 0, to: objects.count, by: batchSize).map {
            Array(objects[$0 ..< min($0 + batchSize, objects.count)])
        }

        var responses: [BatchResponse] = []
        for batch in batches {
            let batchResponse = try await self.batch(
                indexName: indexName,
                batchWriteParams: BatchWriteParams(
                    requests: batch.map {
                        .init(action: action, body: AnyCodable($0))
                    }
                ),
                requestOptions: requestOptions
            )

            responses.append(batchResponse)
        }

        if waitForTasks {
            for batchResponse in responses {
                try await self.waitForTask(with: batchResponse.taskID, in: indexName)
            }
        }

        return responses
    }

    /// Replace all objects in an index
    /// - parameter objects: The new objects
    /// - parameter indexName: The name of the index where to replace the objects
    /// - parameter requestOptions: The request options
    /// - returns: ReplaceAllObjectsResponse
    @discardableResult
    func replaceAllObjects(
        with objects: [some Encodable],
        in indexName: String,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil
    ) async throws -> ReplaceAllObjectsResponse {
        let tmpIndexName = try "\(indexName)_tmp_\(randomString())"

        // Copy all index resources from production index
        let copyOperationResponse = try await operationIndex(
            indexName: indexName,
            operationIndexParams: OperationIndexParams(
                operation: .copy,
                destination: tmpIndexName,
                scope: [.rules, .settings, .synonyms]
            ),
            requestOptions: requestOptions
        )

        try await self.waitForTask(with: copyOperationResponse.taskID, in: indexName)

        // Send records to the tmp index (batched)
        let batchResponses = try await self.chunkedBatch(
            indexName: tmpIndexName,
            objects: objects,
            waitForTasks: true,
            batchSize: batchSize,
            requestOptions: requestOptions
        )

        // Move the temporary index to replace the main one
        let moveOperationResponse = try await self.operationIndex(
            indexName: tmpIndexName,
            operationIndexParams: OperationIndexParams(
                operation: .move,
                destination: indexName
            ),
            requestOptions: requestOptions
        )

        try await self.waitForTask(with: moveOperationResponse.taskID, in: tmpIndexName)

        return ReplaceAllObjectsResponse(
            copyOperationResponse: copyOperationResponse,
            batchResponses: batchResponses,
            moveOperationResponse: moveOperationResponse
        )
    }

    /// Generate a secured API key
    /// - parameter parentApiKey: The parent API key
    /// - parameter restriction: The restrictions
    /// - returns: String?
    func generateSecuredApiKey(
        parentApiKey: String,
        with restriction: SecuredAPIKeyRestrictions = SecuredAPIKeyRestrictions()
    ) throws -> String? {
        let queryParams = try restriction.toURLEncodedString()
        let hash = queryParams.hmac256(withKey: parentApiKey)
        return "\(hash)\(queryParams)".data(using: .utf8)?.base64EncodedString()
    }

    /// Get the remaining validity of a secured API key
    /// - parameter securedAPIKey: The secured API key
    /// - returns: TimeInterval?
    func getSecuredApiKeyRemainingValidity(for securedAPIKey: String) -> TimeInterval? {
        guard let rawDecodedAPIKey = String(data: Data(base64Encoded: securedAPIKey) ?? Data(), encoding: .utf8),
              !rawDecodedAPIKey.isEmpty else {
            return nil
        }

        let prefix = "validUntil="

        guard let range = rawDecodedAPIKey.range(of: "\(prefix)\\d+", options: .regularExpression) else {
            return nil
        }

        let validitySubstring = String(rawDecodedAPIKey[range].dropFirst(prefix.count))

        guard let timestamp = TimeInterval(validitySubstring) else {
            return nil
        }
        let timestampDate = Date(timeIntervalSince1970: timestamp)

        return timestampDate.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
}
