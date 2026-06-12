//
//  SearchClientTransformationExtension.swift
//
//  Helpers that push records through the Algolia Ingestion pipeline before indexing.
//  TransformationOptions must be set via SearchClientConfiguration(transformationOptions:)
//  before calling these methods.
//
//  See https://www.algolia.com/doc/libraries/sdk/methods/ingestion

#if canImport(AlgoliaCore)
    import AlgoliaCore
#endif
#if canImport(AlgoliaIngestion)
    import AlgoliaIngestion
#endif
import Foundation

public extension SearchClient {
    private static let notSetError =
        "transformationOptions must be set in the client config before calling this method." +
        " It defaults to the Ingestion API defaults." +
        " See https://www.algolia.com/doc/libraries/sdk/methods/ingestion"

    /// Lazily builds (and caches) the ingestion transporter from the client's
    /// `transformationOptions`. Building here, rather than in the client initializer, lets
    /// invalid options surface as a thrown error at the call site instead of crashing.
    private func resolvedIngestionClient() throws -> IngestionClient {
        if let ingestionClient = self._ingestionClient {
            return ingestionClient
        }
        guard let options = self.configuration.transformationOptions else {
            throw AlgoliaError.runtimeError(SearchClient.notSetError)
        }
        let ingestionConfig = try IngestionClientConfiguration(
            appID: self.configuration.appID,
            apiKey: self.configuration.apiKey,
            region: options.region,
            writeTimeout: options.writeTimeout ?? 25,
            readTimeout: options.readTimeout ?? 25,
            defaultHeaders: options.defaultHeaders,
            hosts: options.hosts,
            compression: options.compression ?? .none
        )
        let ingestionClient = IngestionClient(configuration: ingestionConfig)
        self._ingestionClient = ingestionClient
        return ingestionClient
    }

    // MARK: - chunkedPush

    /// Chunks `objects` and pushes them through the Ingestion pipeline with the given `action`.
    /// - parameter indexName: The index name to push objects to.
    /// - parameter objects: The objects to push. Each must include an `objectID` key.
    /// - parameter action: The ingestion action to apply.
    /// - parameter waitForTasks: Whether to wait for each batch to finish before moving to the next.
    /// - parameter batchSize: Number of records per push call. Defaults to 1000.
    /// - parameter referenceIndexName: Source index whose transformation is applied to `indexName`.
    /// - parameter requestOptions: Optional per-request options.
    /// - parameter chunkedOptions: Shared options forwarded to every nested ingestion event wait (currently
    ///   `maxRetries`).
    /// - returns: `[IngestionWatchResponse]`
    @discardableResult
    internal func chunkedPush(
        indexName: String,
        objects: [[String: AnyCodable]],
        action: IngestionAction,
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        referenceIndexName: String? = nil,
        requestOptions: RequestOptions? = nil,
        chunkedOptions: ChunkedHelperOptions = ChunkedHelperOptions()
    ) async throws -> [IngestionWatchResponse] {
        guard batchSize > 0 else {
            throw AlgoliaError.runtimeError("`batchSize` must be greater than 0")
        }
        let ingestionClient = try self.resolvedIngestionClient()

        var responses: [IngestionWatchResponse] = []
        let batches = stride(from: 0, to: objects.count, by: batchSize).map {
            Array(objects[$0 ..< min($0 + batchSize, objects.count)])
        }

        for batch in batches {
            let records = try batch.map { obj -> PushTaskRecords in
                guard let objectID = obj["objectID"]?.value as? String, !objectID.isEmpty else {
                    throw AlgoliaError.runtimeError(
                        "each object must have an `objectID` key in order to be indexed"
                    )
                }
                var rest = obj
                rest.removeValue(forKey: "objectID")
                var record = PushTaskRecords(objectID: objectID)
                record.additionalProperties = rest
                return record
            }

            let response = try await ingestionClient.push(
                indexName: indexName,
                pushTaskPayload: PushTaskPayload(action: action, records: records),
                referenceIndexName: referenceIndexName,
                requestOptions: requestOptions
            )
            responses.append(response)
        }

        if waitForTasks {
            for response in responses {
                guard let eventID = response.eventID else { continue }
                try await waitForIngestionEvent(
                    ingestionClient: ingestionClient,
                    runID: response.runID,
                    eventID: eventID,
                    maxRetries: chunkedOptions.maxRetries,
                    requestOptions: requestOptions
                )
            }
        }

        return responses
    }

    // MARK: - Public helpers

    /// Helper: Similar to `saveObjects` but routes records through the Ingestion transformation pipeline.
    /// `transformationOptions` must be set via `SearchClientConfiguration(transformationOptions:)` before creating the
    /// client.
    /// - parameter indexName: The index to save objects into.
    /// - parameter objects: The objects to save. Each must include an `objectID` key.
    /// - parameter waitForTasks: Whether to wait for ingestion tasks to complete. Defaults to `false`.
    /// - parameter batchSize: Number of records per push call. Defaults to 1000.
    /// - parameter requestOptions: Optional per-request options.
    /// - parameter chunkedOptions: Shared options forwarded to the nested `chunkedPush` call.
    /// - returns: `[IngestionWatchResponse]`
    @discardableResult
    func saveObjectsWithTransformation(
        indexName: String,
        objects: [[String: AnyCodable]],
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil,
        chunkedOptions: ChunkedHelperOptions = ChunkedHelperOptions()
    ) async throws -> [IngestionWatchResponse] {
        try await self.chunkedPush(
            indexName: indexName,
            objects: objects,
            action: .addObject,
            waitForTasks: waitForTasks,
            batchSize: batchSize,
            requestOptions: requestOptions,
            chunkedOptions: chunkedOptions
        )
    }

    /// Helper: Similar to `partialUpdateObjects` but routes records through the Ingestion transformation pipeline.
    /// `transformationOptions` must be set via `SearchClientConfiguration(transformationOptions:)` before creating the
    /// client.
    /// - parameter indexName: The index to update objects in.
    /// - parameter objects: The objects to update. Each must include an `objectID` key.
    /// - parameter createIfNotExists: Whether to create the object if it does not exist. Defaults to `true`.
    /// - parameter waitForTasks: Whether to wait for ingestion tasks to complete. Defaults to `false`.
    /// - parameter batchSize: Number of records per push call. Defaults to 1000.
    /// - parameter requestOptions: Optional per-request options.
    /// - parameter chunkedOptions: Shared options forwarded to the nested `chunkedPush` call.
    /// - returns: `[IngestionWatchResponse]`
    @discardableResult
    func partialUpdateObjectsWithTransformation(
        indexName: String,
        objects: [[String: AnyCodable]],
        createIfNotExists: Bool = true,
        waitForTasks: Bool = false,
        batchSize: Int = 1000,
        requestOptions: RequestOptions? = nil,
        chunkedOptions: ChunkedHelperOptions = ChunkedHelperOptions()
    ) async throws -> [IngestionWatchResponse] {
        try await self.chunkedPush(
            indexName: indexName,
            objects: objects,
            action: createIfNotExists ? .partialUpdateObject : .partialUpdateObjectNoCreate,
            waitForTasks: waitForTasks,
            batchSize: batchSize,
            requestOptions: requestOptions,
            chunkedOptions: chunkedOptions
        )
    }

    /// Helper: Similar to `replaceAllObjects` but routes records through the Ingestion transformation pipeline.
    /// `transformationOptions` must be set via `SearchClientConfiguration(transformationOptions:)` before creating the
    /// client.
    /// - parameter indexName: The index to replace objects in.
    /// - parameter objects: The new objects. Each must include an `objectID` key.
    /// - parameter batchSize: Number of records per push call. Defaults to 1000.
    /// - parameter scopes: Index data to copy before pushing. Defaults to `[.settings, .rules, .synonyms]`.
    /// - parameter requestOptions: Optional per-request options.
    /// - parameter chunkedOptions: Shared options forwarded to the nested `chunkedPush` call and to every
    ///   internal `waitForTask` call (copy, copy-rules, move).
    /// - returns: `ReplaceAllObjectsWithTransformationResponse`
    @discardableResult
    func replaceAllObjectsWithTransformation(
        indexName: String,
        objects: [[String: AnyCodable]],
        batchSize: Int = 1000,
        scopes: [ScopeType] = [.settings, .rules, .synonyms],
        requestOptions: RequestOptions? = nil,
        chunkedOptions: ChunkedHelperOptions = ChunkedHelperOptions()
    ) async throws -> ReplaceAllObjectsWithTransformationResponse {
        _ = try self.resolvedIngestionClient()

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

            let ingestionWatchResponses = try await chunkedPush(
                indexName: tmpIndexName,
                objects: objects,
                action: .addObject,
                waitForTasks: true,
                batchSize: batchSize,
                referenceIndexName: indexName,
                requestOptions: requestOptions,
                chunkedOptions: chunkedOptions
            )

            try await waitForTask(
                indexName: tmpIndexName,
                taskID: copyOperationResponse.taskID,
                maxRetries: chunkedOptions.maxRetries,
                requestOptions: requestOptions
            )

            copyOperationResponse = try await operationIndex(
                indexName: indexName,
                operationIndexParams: OperationIndexParams(
                    operation: .copy,
                    destination: tmpIndexName,
                    scope: scopes
                ),
                requestOptions: requestOptions
            )
            try await waitForTask(
                indexName: tmpIndexName,
                taskID: copyOperationResponse.taskID,
                maxRetries: chunkedOptions.maxRetries,
                requestOptions: requestOptions
            )

            let moveOperationResponse = try await operationIndex(
                indexName: tmpIndexName,
                operationIndexParams: OperationIndexParams(
                    operation: .move,
                    destination: indexName
                ),
                requestOptions: requestOptions
            )
            try await waitForTask(
                indexName: tmpIndexName,
                taskID: moveOperationResponse.taskID,
                maxRetries: chunkedOptions.maxRetries,
                requestOptions: requestOptions
            )

            let watchResponses = try ingestionWatchResponses.map { r -> SearchWatchResponse in
                let data = try JSONEncoder().encode(r)
                return try JSONDecoder().decode(SearchWatchResponse.self, from: data)
            }

            return ReplaceAllObjectsWithTransformationResponse(
                copyOperationResponse: copyOperationResponse,
                watchResponses: watchResponses,
                moveOperationResponse: moveOperationResponse
            )
        } catch {
            _ = try? await deleteIndex(indexName: tmpIndexName)
            throw error
        }
    }
}

// MARK: - Private helpers

private func waitForIngestionEvent(
    ingestionClient: IngestionClient,
    runID: String,
    eventID: String,
    maxRetries: Int = ChunkedHelperOptions.defaultMaxRetries,
    requestOptions: RequestOptions? = nil
) async throws {
    var retryCount = 0

    _ = try await createIterable(
        execute: { _ in
            do {
                return try await ingestionClient.getEvent(
                    runID: runID,
                    eventID: eventID,
                    requestOptions: requestOptions
                )
            } catch let AlgoliaError.httpError(error) where error.statusCode == 404 {
                return nil
            }
        },
        validate: { response in
            response != nil
        },
        aggregator: { _ in
            retryCount += 1
        },
        timeout: {
            min(TimeInterval(retryCount + 1) * 1.5, 5)
        },
        error: IterableError(
            validate: { _ in
                retryCount >= maxRetries
            },
            message: { _ in
                "Stopped waiting for the task after \(maxRetries) retries. This does not mean the operation failed; it may still complete. If you need to keep polling, retry with a higher maxRetries."
            }
        )
    )
}
