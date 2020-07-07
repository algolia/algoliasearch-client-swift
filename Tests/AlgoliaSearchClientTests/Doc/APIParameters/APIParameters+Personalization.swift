//
//  APIParameters+Personalization.swift
//  
//
//  Created by Vladislav Fitc on 07/07/2020.
//

import Foundation
import AlgoliaSearchClient

extension APIParameters {
  //MARK: - Personalization
  func personalization() {
    func enablePersonalization() {
      /*
       enablePersonalization = true|false
       */
      func enable_personalization() {
        let query = Query("query")
          .set(\.enablePersonalization, to: true)
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      
      func enable_personalization_with_user_token() {
        let query = Query("query")
          .set(\.enablePersonalization, to: true)
          .set(\.userToken, to: "123456")
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func personalizationImpact() {
      /*
       personalizationImpact = personalization_impact
       */
      func personalization_impact() {
        let query = Query("query")
          .set(\.personalizationImpact, to: 20)
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
    func userToken() {
      /*
       userToken = 'YourCustomUserId'
       */
      func set_user_token() {
        let query = Query("query")
          .set(\.userToken, to: "123456")
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
      func set_user_token_with_personalization() {
        let query = Query("query")
          .set(\.enablePersonalization, to: true)
          .set(\.userToken, to: "123456")
        
        index.search(query: query) { result in
          if case .success(let response) = result {
            print("Response: \(response)")
          }
        }
      }
    }
  }
}
