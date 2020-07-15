//
//  SearchIndexSnippets.swift
//  
//
//  Created by Vladislav Fitc on 28/06/2020.
//

import Foundation
import AlgoliaSearchClient

struct SearchIndexSnippets: SnippetsCollection {}

//MARK: - Search

extension SearchIndexSnippets {
  
  static var search = """
  index.search(
    #{query}:  __Query__,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<SearchResponse> -> Void__
  )

  // any #{searchParameters} can be set in the query object
  """
  
  func search() {
    let index = client.index(withName: "contacts")
    index.search(query: "s") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }

    var query = Query("s")
    query.attributesToRetrieve = ["firstname", "lastname"]
    query.hitsPerPage = 50
    index.search(query: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func searchWithExtraHeaders() {
    let index = client.index(withName: "your_index_name")
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-UserToken"] = "user123"
    index.search(query: "s", requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
}

//MARK: - Search for facet values

extension SearchIndexSnippets {
  
  static var searchForFacetValues = """
  index.searchForFacetValues(
    of #{facetName}: __Attribute__,
    matching #{facetQuery}: __String__ ,
    applicableFor searchQuery: __Query?__ = nil,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<FacetSearchResponse> -> Void__
  )
  // #{searchParameters} can be added in the Query object
  """

  func sffv() {
    index.searchForFacetValues(of: "category", matching: "phone") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func sffvForQuery() {
    // Search the "category" facet for values matching "phone" in records
    // having "Apple" in their "brand" facet.
    var query = Query()
    query.filters = "brand:Apple"
    index.searchForFacetValues(of: "cateogry",
                               matching: "phone",
                               applicableFor: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func sffvWithExtraHeaders() {
    // Search the "category" facet for values matching "phone" in records
    // having "Apple" in their "brand" facet.
    var query = Query()
    query.filters = "brand:Apple"

    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-UserToken"] = "user123"

    index.searchForFacetValues(of: "category",
                               matching: "phone",
                               applicableFor: query,
                               requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Multi index search

extension SearchIndexSnippets {
  
  static var multiIndexSearch = """
  client.multipleQueries(
    #{queries}: __[IndexedQuery]__ ,
    #{strategy}: __MultipleQueriesStrategy__ = .none,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<FacetSearchResponse> -> Void__
  )
  """
  
  func multiIndexSearch() {
    // Perform 3 queries in a single API call:
    //    - 1st query target index `categories`
    //    - 2nd and 3rd queries target index `products`
    let queries: [IndexedQuery] = [
      .init(indexName: "categories", query: Query("electronics").set(\.hitsPerPage, to: 3)),
      .init(indexName: "products", query: Query("iPhone").set(\.hitsPerPage, to: 3).set(\.filters, to: "_tags:promotions")),
      .init(indexName: "products", query: Query("Galaxy").set(\.hitsPerPage, to: 10)),
    ]

    client.multipleQueries(queries: queries) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func multiIndexSearchWithExtraHeaders() {
    // Perform 3 queries in a single API call:
    //    - 1st query target index `categories`
    //    - 2nd and 3rd queries target index `products`
    let queries: [IndexedQuery] = [
      .init(indexName: "categories", query: Query("electronics").set(\.hitsPerPage, to: 3)),
      .init(indexName: "products", query: Query("iPhone").set(\.hitsPerPage, to: 3).set(\.filters, to: "_tags:promotions")),
      .init(indexName: "products", query: Query("Galaxy").set(\.hitsPerPage, to: 10)),
    ]

    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-UserToken"] = "user123"
    client.multipleQueries(queries: queries, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Browse Index

extension SearchIndexSnippets {
  
  static var browseIndex = """
  index.browse(
    #{query}: __Query__,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<SearchResponse> -> Void__
  )

  // #{browseParameters} can be set on the Query object

  """
  
  func browseIndex() {
    var query = Query("") // Empty query will match all records
    query.filters = "i<42"
    index.browse(query: query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func browseIndexWithExtraHeaders() {
    var requestOptions = RequestOptions()
    requestOptions.headers["X-Algolia-User-ID"] = "user123"
    var query = Query("") // Empty query will match all records
    query.filters = "i<42"
    index.browse(query: query, requestOptions: requestOptions) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    
  }
  
}

//MARK: - Find Object
  
extension SearchIndexSnippets {
  
  static var findObject = """
  index.findObject<T: Codable>(
    matching [predicate](#method-param-callback): __(T) -> Bool__,
    for #{query}: __Query__ = Query(),
    #{paginate}: __Bool__ = true,
    #{requestOptions}: __RequestOptions?__ = nil,
    completion: __Result<HitWithPosition<T>?> -> Void__
  )
  """
  
  func findObject() {
    
    let predicate: (JSON) -> Bool = { hit in
      return hit["firstname"] == "Jimmie"
    }

    index.findObject(matching: predicate) { result in
      if case .success(let response) = result {
        print("Response: \(String(describing: response))")
      }
    }

    // With a query
    index.findObject(matching: predicate, for: Query("query string")) { result in
      if case .success(let response) = result {
        print("Response: \(String(describing: response))")
      }
    }

    // With a query and only in the first page
    index.findObject(matching: predicate,
                     for: Query("query string"),
                     paginate: false) { result in
      if case .success(let response) = result {
        print("Response: \(String(describing: response))")
      }
    }
    
  }
  

}

//MARK: - Get object position

extension SearchIndexSnippets {
  
  static var getObjectPosition = """
  func SearchReponse.getPositionOfObject(withID #{objectID}: __ObjectID__) -> Int?
  """
  
  func getObjectPosition() {
    var searchResponse: SearchResponse!
    let position = searchResponse.getPositionOfObject(withID: "a-unique-identifier")
    _ = (searchResponse.facets = [:], position)//to remove when pasted to doc
  }

}
