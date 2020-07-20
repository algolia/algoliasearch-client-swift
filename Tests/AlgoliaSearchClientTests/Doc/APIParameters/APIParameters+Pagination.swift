//
//  APIParameters+Pagination.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation
import AlgoliaSearchClient

extension APIParameters {
  //MARK: - Pagination
  func pagination() {
    
    func page() {
      /*
       page = page_number
      */
      
      let query = Query("query")
        .set(\.page, to: 0)

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }

    }
    
    func hitsPerPage() {
      /*
       hitsPerPage = number_of_hits
      */
      
      func set_default_hits_per_page() {
        let settings = Settings()
          .set(\.hitsPerPage, to: 20)
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func override_default_hits_per_page() {
        let query = Query("query")
          .set(\.hitsPerPage, to: 10)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
    }
    
    func offset() {
      /*
       offset = record_number
      */
      
      let query = Query("query")
        .set(\.offset, to: 4)

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
    
    func length() {
      /*
       length = number_of_records
      */
      
      let query = Query("query")
        .set(\.length, to: 4)

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
    
    func paginationLimitedTo() {
      /*
       paginationLimitedTo: number_of_records
       */
      let settings = Settings()
        .set(\.paginationLimitedTo, to: 1000)
      
      index.setSettings(settings) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
  }
}
