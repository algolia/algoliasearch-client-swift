//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/03/2020.
//

import Foundation

protocol SearchEndpoint {
  
  /**
   Method used for querying an index.
   The search query only allows for the retrieval of up to 1000 hits.
   If you need to retrieve more than 1000 hits (e.g. for SEO), you can either leverage
   the [Browse index](https://www.algolia.com/doc/api-reference/api-methods/browse/) method or increase
   the [paginationLimitedTo](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/) parameter.
   - parameter query: The Query used to search.
   - parameter requestOptions: Configure request locally with RequestOptions.
   */
  @discardableResult func search(query: Query,
                                 requestOptions: RequestOptions?,
                                 completion: @escaping ResultCallback<SearchResponse>) -> Operation
  
}
