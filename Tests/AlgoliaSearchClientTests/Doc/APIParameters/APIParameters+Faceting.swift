//
//  APIParameters+Faceting.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation
import AlgoliaSearchClient

extension APIParameters {
  //MARK: - Faceting
  func faceting() {
    func facets() {
      /*
       query.facets = [
         "attribute",
         ...
       ]
       */
      
      let query = Query("query")
        .set(\.facets, to: ["category", "author"])

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
      
    }
    
    func maxFacetsPerValue() {
      /*
       "maxValuesPerFacet": max_value
       */
      
      func set_default_max_values_per_facet() {
        let settings = Settings()
          .set(\.maxValuesPerFacet, to: 100)
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func override_default_max_values_per_facet() {
        let query = Query("query")
          .set(\.maxValuesPerFacet, to: 50)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
    }
    
    func facetingAfterDistinct() {
      /*
       facetingAfterDistinct = true|false
       */
      
      let query = Query("query")
        .set(\.facetingAfterDistinct, to: true)

      index.search(query: query) { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
      }
    }
    
    func sortFacetsValuesBy() {
      /*
       sortFacetValuesBy: "#{count}"|"#{alpha}"
       */
      
      func set_default_sort_facet_values_by() {
        let settings = Settings()
          .set(\.sortFacetsBy, to: .alpha)
        
        index.setSettings(settings) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func sort_facet_values_alphabetically() {
        let query = Query("query")
          .set(\.sortFacetsBy, to: .count)

        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
