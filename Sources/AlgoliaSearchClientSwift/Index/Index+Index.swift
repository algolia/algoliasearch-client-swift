//
//  Index+Index.swift
//  
//
//  Created by Vladislav Fitc on 01/04/2020.
//

import Foundation

extension Index {
  
  //MARK: - Delete index
  
  /**
   Delete the index and all its settings, including links to its replicas.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: Launched asynchronous operation
   */
  @discardableResult func delete(requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<DeletionIndex>) -> Operation {
    let command = Command.Index.DeleteIndex(indexName: name, requestOptions: requestOptions)
    return launch(command, completion: completion)
  }

  /**
   Delete the index and all its settings, including links to its replicas.
   - Parameter requestOptions: Configure request locally with RequestOptions.
   - Returns: DeletionIndex object
   */
  @discardableResult func delete(requestOptions: RequestOptions? = nil) throws -> DeletionIndex {
    let command = Command.Index.DeleteIndex(indexName: name, requestOptions: requestOptions)
    return try launch(command)
  }

}
