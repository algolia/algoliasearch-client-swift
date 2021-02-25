//
//  Command+Dictionaries.swift
//  
//
//  Created by Vladislav Fitc on 20/01/2021.
//

import Foundation

extension Command {

  enum Dictionaries {

    struct Batch: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: DictionaryCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init<D: CustomDictionary>(dictionary: D.Type,
                                requests: [DictionaryRequest<D.Entry>],
                                clearExistingDictionaryEntries: Bool,
                                requestOptions: RequestOptions?) where D.Entry: Encodable {
        self.path = (.dictionaries >>> .dictionaryName(D.name) >>> .batch)
        self.body = Payload(requests: requests, clearExistingDictionaryEntries: clearExistingDictionaryEntries).httpBody
        self.requestOptions = requestOptions
      }

      // swiftlint:disable:next nesting
      struct Payload<E: DictionaryEntry & Encodable>: Encodable {
        let requests: [DictionaryRequest<E>]
        let clearExistingDictionaryEntries: Bool
      }

    }

    struct Search: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: DictionaryCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(dictionaryName: DictionaryName,
           query: DictionaryQuery,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.dictionaries >>> .dictionaryName(dictionaryName) >>> .search)
        self.body = query.httpBody
      }

      init<D: CustomDictionary>(dictionary: D.Type,
                                query: DictionaryQuery,
                                requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.dictionaries >>> .dictionaryName(D.name) >>> .search)
        self.body = query.httpBody
      }

    }

    struct GetSettings: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: DictionaryCompletion
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.dictionaries >>> .common >>> .settings)
      }

    }

    struct SetSettings: AlgoliaCommand {

      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: DictionaryCompletion
      let body: Data?
      let requestOptions: RequestOptions?

      init(settings: DictionarySettings,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.dictionaries >>> .common >>> .settings)
        self.body = settings.httpBody
      }

    }

    struct LanguagesList: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: DictionaryCompletion
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = (.dictionaries >>> .common >>> .languages)
      }

    }

  }

}
