//
//  GettingStarted.swift
//  
//
//  Created by Vladislav Fitc on 06/07/2020.
//

import Foundation
import AlgoliaSearchClient

struct GettingStarted: SnippetsCollection {
  
  func attributesOrder() {
    let settings = Settings()
      .set(\.searchableAttributes, to: ["lastname", "firstname", "company", "email", "city", "address"])
    index.setSettings(settings) { result in
      switch result {
      case .failure(let error):
        print("Error when applying settings: \(error)")
      case .success:
        print("Success")
      }
    }
  }
  
  func customRanking() {
    let settings = Settings()
      .set(\.customRanking, to: [.desc("followers")])
    index.setSettings(settings) { result in
      switch result {
      case .failure(let error):
        print("Error when applying settings: \(error)")
      case .success:
        print("Success")
      }
    }
  }
  
  func newIndex() {
    struct Contact: Encodable {
      let firstname: String
      let lastname: String
      let followers: Int
      let company: String
    }

    let contacts: [Contact] = [
      .init(firstname: "Jimmie", lastname: "Barninger", followers: 93, company: "California Paint"),
      .init(firstname: "Warren", lastname: "Speach", followers: 42, company: "Norwalk Crmc")
    ]
    
    let index = client.index(withName: "contacts")
    index.saveObjects(contacts, autoGeneratingObjectID: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func changeSettings() {
    let index = client.index(withName: "contacts")
    
    func setCustomRanking() {
      let settings = Settings()
        .set(\.customRanking, to: [.desc("followers")])
      index.setSettings(settings) { result in
        if case .failure(let error) = result {
          print("Error when applying settings: \(error)")
        }
      }

    }

    func setSearchableAttributes() {
      let settings = Settings()
        .set(\.searchableAttributes, to: ["lastname", "firstname", "company"])
      index.setSettings(settings) { result in
        if case .failure(let error) = result {
          print("Error when applying settings: \(error)")
        }
      }
    }

  }
  
  func quickStartSearch() {
    // Search for a first name
    index.search(query: "jimmie") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
    // Search for a first name with typo
    index.search(query: "jimie") { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
    }
    // Search for a company
    index.search(query: "california paint") { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
    }
    // Search for a first name and a company
    index.search(query: "jimmie paint") { result in
        if case .success(let response) = result {
          print("Response: \(response)")
        }
    }
  }
  
}
