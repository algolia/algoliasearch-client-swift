//
//  SnippetsCollection.swift
//
//
//  Created by Vladislav Fitc on 28/06/2020.
//

import AlgoliaSearchClient
import Foundation

protocol SnippetsCollection {
  var index: Index { get }
  var client: SearchClient { get }
}

extension SnippetsCollection {
  var index: Index { client.index(withName: "") }
  var client: SearchClient { .init(appID: "", apiKey: "") }
}
