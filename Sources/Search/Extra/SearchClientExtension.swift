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
        indexName: String,
        taskID: Int64,
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
        taskID: Int64,
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
        key: String,
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
                do {
                    return try await self.getApiKey(key: key, requestOptions: requestOptions)
                } catch let AlgoliaError.httpError(error) {
                    if error.statusCode == 404 {
                        return nil
                    }

                    throw error
                }
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
        indexName: String,
        browseParams: BrowseParamsObject,
        validate: (BrowseResponse<T>) -> Bool = { response in
            response.cursor == nil
        },
        aggregator: @escaping (BrowseResponse<T>) -> Void,
        requestOptions: RequestOptions? = nil
    ) async throws -> BrowseResponse<T> {
        var updatedBrowseParams = browseParams
        if updatedBrowseParams.hitsPerPage == nil {
            updatedBrowseParams.hitsPerPage = 1000
        }

        return try await createIterable(
            execute: { previousResponse in
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
        indexName: String,
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
                response.hits.count < hitsPerPage
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
        indexName: String,
        searchSynonymsParams: SearchSynonymsParams,
        validate: ((SearchSynonymsResponse) -> Bool)? = nil,
        aggregator: @escaping (SearchSynonymsResponse) -> Void,
        requestOptions: RequestOptions? = nil
    ) async throws -> SearchSynonymsResponse {
        let hitsPerPage = 1000

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
                response.hits.count < hitsPerPage
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
        action: SearchAction = .addObject,
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
                batchWriteParams: SearchBatchWriteParams(
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
                try await self.waitForTask(
                    indexName: indexName,
                    taskID: batchResponse.taskID,
                    requestOptions: requestOptions
                )
            }
        }

        return responses
    }

    /// Helper: Saves the given array of objects in the given index. The `chunkedBatch` helper is used under the hood,
    /// which creates a `batch` requests with at most 1000 objects in it.
    /// - parameter indexName: The name of the index where to save the objects
    /// - parameter objects: The new objects
    /// - parameter waitForTasks: If we should wait for the batch task to be finished before processing the next one
    /// - parameter batchSize: The maximum number of objects to include in a batch
    /// - parameter requestOptions: The request options
    /// - returns: [BatchResponse]
    func saveObjects(
        indexName: String,
        objects: [some Encodable],
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil
    ) async throws -> [BatchResponse] {
        try await self.chunkedBatch(
            indexName: indexName,
            objects: objects,
            action: .addObject,
            waitForTasks: waitForTasks,
            batchSize: batchSize,
            requestOptions: requestOptions
        )
    }

    /// Helper: Deletes every records for the given objectIDs. The `chunkedBatch` helper is used under the hood, which
    /// creates a `batch` requests with at most 1000 objectIDs in it.
    /// - parameter indexName: The name of the index to delete objectIDs from
    /// - parameter objectIDs: The objectIDs to delete
    /// - parameter waitForTasks: If we should wait for the batch task to be finished before processing the next one
    /// - parameter batchSize: The maximum number of objects to include in a batch
    /// - parameter requestOptions: The request options
    /// - returns: [BatchResponse]
    func deleteObjects(
        indexName: String,
        objectIDs: [String],
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil
    ) async throws -> [BatchResponse] {
        try await self.chunkedBatch(
            indexName: indexName,
            objects: objectIDs.map { AnyCodable(["objectID": $0]) },
            action: .deleteObject,
            waitForTasks: waitForTasks,
            batchSize: batchSize,
            requestOptions: requestOptions
        )
    }

    /// Helper: Replaces object content of all the given objects according to their respective `objectID` field. The
    /// `chunkedBatch` helper is used under the hood, which creates a `batch` requests with at most 1000 objects in it.
    /// - parameter indexName: The name of the index where to update the objects
    /// - parameter objects: The objects to update
    /// - parameter createIfNotExists: To be provided if non-existing objects are passed, otherwise, the call will
    /// fail..
    /// - parameter waitForTasks: If we should wait for the batch task to be finished before processing the next one
    /// - parameter batchSize: The maximum number of objects to include in a batch
    /// - parameter requestOptions: The request options
    /// - returns: [BatchResponse]
    func partialUpdateObjects(
        indexName: String,
        objects: [some Encodable],
        createIfNotExists: Bool = false,
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil
    ) async throws -> [BatchResponse] {
        try await self.chunkedBatch(
            indexName: indexName,
            objects: objects,
            action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate,
            waitForTasks: waitForTasks,
            batchSize: batchSize,
            requestOptions: requestOptions
        )
    }

    /// Replace all objects in an index
    ///
    /// See https://api-clients-automation.netlify.app/docs/custom-helpers/#replaceallobjects for implementation
    /// details.
    /// - parameter indexName: The name of the index where to replace the objects
    /// - parameter objects: The new objects
    /// - parameter batchSize: The maximum number of objects to include in a batch
    /// - parameter scopes: The `scopes` to keep from the index. Defaults to ['settings', 'rules', 'synonyms']
    /// - parameter requestOptions: The request options
    /// - returns: ReplaceAllObjectsResponse
    @discardableResult
    func replaceAllObjects(
        indexName: String,
        objects: [some Encodable],
        batchSize: Int = 1000,
        scopes: [ScopeType] = [.settings, .rules, .synonyms],
        requestOptions: RequestOptions? = nil
    ) async throws -> ReplaceAllObjectsResponse {
        let tmpIndexName = "\(indexName)_tmp_\(Int.random(in: 1_000_000 ..< 10_000_000))"

        do {
            var copyOperationResponse = try await operationIndex(
                indexName: indexName,
                operationIndexParams: OperationIndexParams(
                    operation: .copy,
                    destination: tmpIndexName,
                    scope: scopes
                ),
                requestOptions: requestOptions
            )

            let batchResponses = try await self.chunkedBatch(
                indexName: tmpIndexName,
                objects: objects,
                waitForTasks: true,
                batchSize: batchSize,
                requestOptions: requestOptions
            )
            try await self.waitForTask(indexName: tmpIndexName, taskID: copyOperationResponse.taskID)

            copyOperationResponse = try await operationIndex(
                indexName: indexName,
                operationIndexParams: OperationIndexParams(
                    operation: .copy,
                    destination: tmpIndexName,
                    scope: scopes
                ),
                requestOptions: requestOptions
            )
            try await self.waitForTask(indexName: tmpIndexName, taskID: copyOperationResponse.taskID)

            let moveOperationResponse = try await self.operationIndex(
                indexName: tmpIndexName,
                operationIndexParams: OperationIndexParams(
                    operation: .move,
                    destination: indexName
                ),
                requestOptions: requestOptions
            )
            try await self.waitForTask(indexName: tmpIndexName, taskID: moveOperationResponse.taskID)

            return ReplaceAllObjectsResponse(
                copyOperationResponse: copyOperationResponse,
                batchResponses: batchResponses,
                moveOperationResponse: moveOperationResponse
            )
        } catch {
            _ = try? await self.deleteIndex(indexName: tmpIndexName)

            throw error
        }
    }

    /// Generate a secured API key
    /// - parameter parentApiKey: The parent API key
    /// - parameter restrictions: The restrictions
    /// - returns: String?
    func generateSecuredApiKey(
        parentApiKey: String,
        restrictions: SecuredApiKeyRestrictions = SecuredApiKeyRestrictions()
    ) throws -> String? {
        let queryParams = try restrictions.toURLEncodedString()
        let hash = queryParams.hmac256(withKey: parentApiKey)
        return "\(hash)\(queryParams)".data(using: .utf8)?.base64EncodedString()
    }

    /// Get the remaining validity of a secured API key
    /// - parameter securedApiKey: The secured API key
    /// - returns: TimeInterval?
    func getSecuredApiKeyRemainingValidity(securedApiKey: String) -> TimeInterval? {
        guard let rawDecodedAPIKey = String(data: Data(base64Encoded: securedApiKey) ?? Data(), encoding: .utf8),
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

    func indexExists(indexName: String) async throws -> Bool {
        do {
            _ = try await self.getSettings(indexName: indexName)
        } catch let AlgoliaError.httpError(error) where error.statusCode == 404 {
            return false
        }

        return true
    }

    /// Method used for perform search with disjunctive facets.
    ///
    /// - Parameter indexName: The name of the index in which the search queries should be performed
    /// - Parameter searchParamsObject: The search query params.
    /// - Parameter refinements: Refinements to apply to the search in form of dictionary with
    ///  facet attribute as a key and a list of facet values for the designated attribute.
    ///  Any facet in this list not present in the `disjunctiveFacets` set will be filtered conjunctively (with AND
    /// operator).
    /// - Parameter disjunctiveFacets: Set of facets attributes applied disjunctively (with OR operator)
    /// - Parameter keepSelectedEmptyFacets: Whether the selected facet values might be preserved even
    ///  in case of their absence in the search response
    /// - Parameter requestOptions: Configure request locally with RequestOptions.
    /// - Returns: SearchDisjunctiveFacetingResponse<T> - a struct containing the merge response from all the
    /// disjunctive faceting search queries,
    ///  and a list of disjunctive facets
    func searchDisjunctiveFaceting<T: Codable>(
        indexName: String,
        searchParamsObject: SearchSearchParamsObject,
        refinements: [String: [String]],
        disjunctiveFacets: Set<String>,
        requestOptions: RequestOptions? = nil
    ) async throws -> SearchDisjunctiveFacetingResponse<T> {
        let helper = DisjunctiveFacetingHelper(
            query: SearchForHits(from: searchParamsObject, indexName: indexName),
            refinements: refinements,
            disjunctiveFacets: disjunctiveFacets
        )
        let queries = helper.buildQueries()
        let responses: [SearchResponse<T>] = try await self.searchForHitsWithResponse(
            searchMethodParams: SearchMethodParams(requests: queries),
            requestOptions: requestOptions
        )
        return try helper.mergeResponses(responses)
    }
}
