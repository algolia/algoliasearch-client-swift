//
//  IndicesListResponse.swift
//  
//
//  Created by Vladislav Fitc on 04/04/2020.
//

import Foundation

public struct IndicesListResponse: Codable {

  public let items: [Item]

  /**
   The value is always 1.
   There is currently no pagination for this method. Every index is returned on the first call.
  */
  public let nbPages: Int

}

extension IndicesListResponse {

  public struct Item: Codable {

    /// Index name.
    public let name: IndexName

    /// Index creation date.
    public let createdAt: Date

    /// Date of last update.
    public let updatedAt: Date

    /// Number of records contained in the index.
    public let entries: Int

    /// Number of bytes of the index in minified format.
    public let dataSize: Double

    /// Number of bytes of the index binary file.
    public let fileSize: Double

    /// Last build time in seconds.
    public let lastBuildTimeS: Int

    /// Number of pending indexing operations.
    public let numberOfPendingTasks: Int

    /// A boolean which says whether the index has pending tasks.
    public let pendingTask: Bool

    public let replicas: [IndexName]?
    public let primary: IndexName?
    public let sourceABTest: IndexName?
    public let abTest: ABTestShortResponse?

  }

}
