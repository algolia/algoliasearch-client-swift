//
//  BrowseSynonyms.swift
//
//  Created by Vladislav Fitc on 02/08/2021.
//

import Foundation

class BrowseSynonymsOperation: AsyncOperation {

  let index: Index
  let query: SynonymQuery
  let requestOptions: RequestOptions?

  var page = 0
  var responses: [SynonymSearchResponse] = []
  var result: Result<[SynonymSearchResponse], Swift.Error> = .failure(SyncOperationError.notFinished) {
    didSet {
      state = .finished
    }
  }

  init(index: Index, query: SynonymQuery, requestOptions: RequestOptions?) {
    self.index = index
    self.query = query
    self.requestOptions = requestOptions
  }

  override func main() {
    perform()
  }

  func perform() {
    index.searchSynonyms(query.set(\.page, to: page), requestOptions: requestOptions) { result in
      switch result {
      case .failure(let error):
        self.result = .failure(error)
      case .success(let response):
        if response.hits.isEmpty {
          self.result = .success(self.responses)
        } else {
          self.responses.append(response)
          self.page += 1
          self.perform()
        }
      }
    }
  }

}
