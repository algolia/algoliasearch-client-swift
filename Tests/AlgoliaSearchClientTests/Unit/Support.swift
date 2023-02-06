//
//  File.swift
//  
//
//  Created by Vladislav Fitc on 02/02/2023.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient
import UIKit

class Support: XCTestCase {
  
  class DataModel: Decodable {
    
    init(json: [String: Any]) {
    }
    
  }
  
  
  var algoliaIndex: AlgoliaSearchClient.Index!
  var query = Query()
  var searchId = 0
  let displayedSearchId = -1
  var loadedPage: Int = 0
  var nbPages: UInt = 0
  
  let tableView = UITableView()
  var datasource: [DataModel] = []
  
  func setAlgoliaAPI() {
    
    let apiClient = SearchClient(appID: "...", apiKey: "...")
    
    algoliaIndex = apiClient.index(withName: "home")
    // ...
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    
    query.query = searchController.searchBar.text
    let curSearchId = searchId
    
    algoliaIndex.search(query: query) { [weak self] (result) in
      guard let weakSelf = self else { return }
      
      switch result {
        
      case .failure(let error):
        print(error.localizedDescription)
        
      case .success(let searchResponse):
        
        if curSearchId <= weakSelf.displayedSearchId {
          return // Newest query already displayed or error
        }
        
        // Decode JSON
        let hits = searchResponse.hits.map(\.object).compactMap { Dictionary($0) }
        guard let nbPages = searchResponse.nbPages else { return } // nbPages is available as a field of `SearchResponse`
        self?.nbPages = UInt(nbPages)
        
        var tmp = [DataModel]()
        for hit in hits {
          
          if let entry = hit.keys.first(where: { $0.lowercased().contains("account") }) {
            
            if let dict = hit[entry] as? [String: AnyObject] {
              tmp.append(DataModel(json: dict))
            }
          }
        }
        
        guard let safeText = searchController.searchBar.text else { return }
        
        if safeText.trimmingCharacters(in: .whitespaces) == "" {
          
          self?.datasource.removeAll()
          
        } else {
          //Reload view with the new data
          
          self?.datasource = tmp
        }
        self?.tableView.reloadData()
      }
    }
    
    searchId += 1
  }
  
  func loadMore() {
    
    if loadedPage + 1 >= nbPages {
      return // All pages already loaded
    }
    var nextQuery = query // Query is now a value type (struct), not reference type (class) so to copy it you only need to instantiate another variable
    nextQuery.page = loadedPage + 1
    algoliaIndex.search(query: nextQuery) { [weak self] result in
      switch result {

      case .failure(let error):
        print(error.localizedDescription)

      case .success(let response):

        if nextQuery.query != self?.query.query {
          return // Query has changed
        }

        guard let safeNextQueryPage = nextQuery.page else { return }
        self?.loadedPage = safeNextQueryPage as Int

        do {
          let hts: [DataModel] = try response.extractHits()
        } catch let error {
          print("hits parsing error: \(error)")
        }
        let hits = response.hits.map(\.object).compactMap { Dictionary($0) }
        var tmp = [DataModel]()
        print("\nhits_count...\(hits.count)\n")

        for hit in hits {
          if let entry = hit.keys.first(where: { $0.lowercased().contains("account") }) {

            if let dict = hit[entry] as? [String: AnyObject] {
              tmp.append(DataModel(json: dict))
            }
          }
        }
        // Display the new loaded page

        self?.datasource.append(contentsOf: tmp)
        self?.tableView.reloadData()
      }
    }
    
  }
  
}
