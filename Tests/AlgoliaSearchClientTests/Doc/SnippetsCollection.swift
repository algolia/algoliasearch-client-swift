//
//  SnippetsCollection.swift
//  
//
//  Created by Vladislav Fitc on 28/06/2020.
//

import Foundation
import AlgoliaSearchClient

protocol SnippetsCollection {
  var index: Index { get }
  var client: SearchClient { get }
}

extension SnippetsCollection {
  
  var index: Index { return client.index(withName: "") }
  var client: SearchClient { return .init(appID: "", apiKey: "") }
  
}
