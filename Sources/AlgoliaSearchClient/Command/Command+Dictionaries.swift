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
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init<D: CustomDictionary>(dictionary: D.Type,
                                requests: [DictionaryRequest<D.Entry>],
                                clearExistingDictionaryEntries: Bool,
                                requestOptions: RequestOptions?) where D.Entry: Encodable {
        self.path = URL
          .dictionaries
          .appending(D.name)
          .appending(.batch)
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
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(dictionaryName: DictionaryName,
           query: DictionaryQuery,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .dictionaries
          .appending(dictionaryName)
          .appending(.search)
        self.body = query.httpBody
      }

      init<D: CustomDictionary>(dictionary: D.Type,
                                query: DictionaryQuery,
                                requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .dictionaries
          .appending(D.name)
          .appending(.search)
        self.body = query.httpBody
      }

    }

    struct GetSettings: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .dictionaries
          .appending(.asterisk)
          .appending(.settings)
      }

    }

    struct SetSettings: AlgoliaCommand {

      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(settings: DictionarySettings,
           requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .dictionaries
          .appending(.asterisk)
          .appending(.settings)
        self.body = settings.httpBody
      }

    }

    struct LanguagesList: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .dictionaries
          .appending(.asterisk)
          .appending(.languages)
      }

    }

  }

}
