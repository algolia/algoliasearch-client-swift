//
//  SynonymsSnippets.swift
//  
//
//  Created by Vladislav Fitc on 29/06/2020.
//

import Foundation
import AlgoliaSearchClient

struct SynonymsSnippets: SnippetsCollection {}

//MARK: - Save synonym
extension SynonymsSnippets {
  
  static var saveSynonym: String = """
  index.saveSynonym(
    _ #{synonym}: __Synonym__,
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<SynonymRevision> -> Void__
  )
  """
  
  func saveRegular() {
    let synonym: Synonym = .multiWay(objectID: "myID",
                                     synonyms: ["car", "vehicle", "auto"])
    
    index.saveSynonym(synonym, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveOneWay() {
    let synonym: Synonym = .oneWay(objectID: "myID",
                                   input: "car",
                                   synonyms: ["vehicle", "auto"])
    
    index.saveSynonym(synonym, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveAltCorr1() {
    let synonym: Synonym = .alternativeCorrection(objectID: "myID",
                                                  word: "car",
                                                  corrections: ["vehicle", "auto"],
                                                  typo: .one)
    
    index.saveSynonym(synonym, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func saveAltCoor2() {
    let synonym: Synonym = .alternativeCorrection(objectID: "myID",
                                                  word: "car",
                                                  corrections: ["vehicle", "auto"],
                                                  typo: .two)
    
    index.saveSynonym(synonym, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
  func savePlaceholder() {
    let synonym: Synonym = .placeholder(objectID: "myID",
                                        placeholder: "street",
                                        replacements: ["street", "st"])
    
    index.saveSynonym(synonym, forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Batch synonyms

extension SynonymsSnippets {
  
  static var saveSynonyms: String = """
  index.saveSynonyms(
    _ #{synonyms}: __[Synonym]__,
    #{forwardToReplicas}: __Bool?__ = nil,
    #{replaceExistingSynonyms}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<IndexRevision> -> Void__
  )
  """
  
  func saveSynonyms() {
    let synonyms: [Synonym] = [
      .multiWay(objectID: "myID1", synonyms: ["car", "vehicle", "auto"]),
      .multiWay(objectID: "myID2", synonyms: ["street", "st"])
    ]
    
    index.saveSynonyms(synonyms, forwardToReplicas: true, replaceExistingSynonyms: false) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Delete synonym

extension SynonymsSnippets {
  
  static var deleteSynonym = """
  index.deleteSynonym(
    withID #{objectID}: __ObjectID__,
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<IndexDeletion> -> Void__
  )
  """
  
  func deleteSynonym() {
    // Delete and forward to replicas
    index.deleteSynonym(withID: "myID", forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Clear synonyms

extension SynonymsSnippets {
  
  static var clearSynonyms = """
  index.clearSynonyms(
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<IndexRevision> -> Void__
  )
  """
  
  func clearSynonyms() {
    index.clearSynonyms(forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Get synonym

extension SynonymsSnippets {
  
  static var getSynonym = """
  index.getSynonym(
    withID #{objectID}: __ObjectID__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<Synonym> -> Void__
  )
  """
  
  func getSynonym() {
    index.getSynonym(withID: "myID") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Search synonyms

extension SynonymsSnippets {
  
  static var searchSynonyms = """
    index.searchSynonyms(
      _ query: __SynonymQuery__,
      requestOptions: __RequestOptions?__ = nil,
      completion: __SynonymSearchResponse -> Void__
    )

    struct SynonymQuery {
      var #{query}: __String?__ = nil
      var #{page}: __Int?__ = nil
      var #{hitsPerPage}: __Int?__ = nil
      var [synonymTypes](#method-param-type): __[SynonymType]?__ = nil
    }
  """
  
  func searchSynonyms() {
    var query = SynonymQuery()
    query.query = "street"
    query.hitsPerPage = 10
    query.page = 1
    query.synonymTypes = [.multiWay, .oneWay]
    
    index.searchSynonyms(query) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Replace all synonyms

extension SynonymsSnippets {
  
  static var replaceAll = """
  index.replaceAllSynonyms(
    #{synonyms}: __[Synonym]__,
    #{forwardToReplicas}: __Bool?__ = nil,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<IndexRevision> -> Void__
  )
  """
  
  func replaceAll() {
    let client = SearchClient(appID: "YourApplicationID", apiKey: "YourAdminAPIKey")
    let index = client.index(withName: "your_index_name")
    
    let synonyms: [Synonym] = [/* Fetch your synonyms */]
    
    index.replaceAllSynonyms(with: synonyms,
                             forwardToReplicas: true) { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Copy Synonyms

extension SynonymsSnippets {
  
  static var copySynonyms = """
  client.copySynonyms(
    from [source](#method-param-indexnamesrc): __IndexName__,
    to [destination](#method-param-indexnamedest): __IndexName__,
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<WaitableWrapper<IndexRevision>> -> Void__
  )
  """
  
  func copySynonyms() {
    client.copySynonyms(from: "indexNameSrc", to: "indexNameDest") { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}

//MARK: - Export Synonyms

extension SynonymsSnippets {
  
  static var exportSynonyms = """
  index.browseSynonyms(
    query: __SynonymQuery__ = .init(),
    requestOptions: __RequestOptions?__ = nil,
    completion: __Result<[SynonymSearchResponse]> -> Void__
  )
  """
  
  func exportSynonyms() {
    index.browseSynonyms { result in
      if case .success(let response) = result {
        print("Response: \(response)")
      }
    }
  }
  
}
