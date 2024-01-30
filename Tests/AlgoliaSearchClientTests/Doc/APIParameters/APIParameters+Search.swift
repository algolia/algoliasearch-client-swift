//
//  APIParameters+Search.swift
//
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import AlgoliaSearchClient
import Foundation

extension APIParameters {
  // MARK: - Search

  func search() {
    func query() {
      /*
             index.search(query: "my query")
             */
      func search_a_query() {
        index.search(query: "my query") { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func search_everything() {
        index.search(query: "") { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func similarQuery() {
      /*
             similarQuery = "query"
             */
      func search_a_query() {
        let query = Query()
          .set(
            \.similarQuery, to: "Comedy Drama Crime McDormand Macy Buscemi Stormare Presnell Coen"
          )
          .set(\.filters, to: "year:1991 TO 2001")

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
