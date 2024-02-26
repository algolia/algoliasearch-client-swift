//
//  ReplaceAllObjectsResponse.swift
//
//
//  Created by Algolia on 26/02/2024.
//

import Foundation

public struct ReplaceAllObjectsResponse {
    let copyOperationResponse: UpdatedAtResponse
    let batchResponses: [BatchResponse]
    let moveOperationResponse: UpdatedAtResponse
}
