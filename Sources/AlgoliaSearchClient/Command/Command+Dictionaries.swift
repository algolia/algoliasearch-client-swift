//
//  Command+Dictionaries.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Dictionaries {

    struct Batch: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?
      
      init<E: DictionaryEntry & Encodable>(requests: [DictionaryRequest<E>],
                                           clearExistingDictionaryEntries: Bool,
                                           requestOptions: RequestOptions?) {
        let path = .dictionaries >>> .dictionaryName(.forEntry(E.self)) >>> DictionaryCompletion.batch
        let body = Payload(requests: requests, clearExistingDictionaryEntries: clearExistingDictionaryEntries).httpBody
        self.urlRequest = URLRequest(method: .post, path: path, body: body, requestOptions: requestOptions)
        self.requestOptions = requestOptions
      }
      
      struct Payload<E: DictionaryEntry & Encodable>: Encodable {
        let requests: [DictionaryRequest<E>]
        let clearExistingDictionaryEntries: Bool
      }

    }
    
    struct Search: AlgoliaCommand {
     
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(dictionaryName: DictionaryName,
           query: DictionaryQuery,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .dictionaries >>> .dictionaryName(dictionaryName) >>> DictionaryCompletion.search
        let body = query.httpBody
        self.urlRequest = .init(method: .post, path: path, body: body, requestOptions: self.requestOptions)
      }
      
    }

    struct GetSettings: AlgoliaCommand {
     
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .dictionaries >>> .common >>> DictionaryCompletion.settings
        self.urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }
      
    }
    
    struct SetSettings: AlgoliaCommand {
     
      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(settings: DictionarySettings,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .dictionaries >>> .common >>> DictionaryCompletion.settings
        self.urlRequest = .init(method: .put, path: path, body: settings.httpBody, requestOptions: self.requestOptions)
      }

    }
    
    struct LanguagesList: AlgoliaCommand {
     
      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .dictionaries >>> .common >>> DictionaryCompletion.languages
        self.urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }
      
    }
    
  }
  
}
