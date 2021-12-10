//
//  Command+Rule.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

extension Command {

  enum Rule {

    struct Save: AlgoliaCommand {

      let method: HTTPMethod = .put
      let callType: CallType = .write
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, rule: AlgoliaSearchClient.Rule, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.rules)
          .appending(rule.objectID)
        self.body = rule.httpBody
      }

    }

    struct Get: AlgoliaCommand {

      let method: HTTPMethod = .get
      let callType: CallType = .read
      let path: URL
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.rules)
          .appending(objectID)
      }

    }

    struct Delete: AlgoliaCommand {

      let method: HTTPMethod = .delete
      let callType: CallType = .write
      let path: URL
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.rules)
          .appending(objectID)
      }

    }

    struct Search: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .read
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: RuleQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.rules)
          .appending(.search)
        self.body = query.httpBody
      }

    }

    struct Clear: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: URL
      let requestOptions: RequestOptions?

      init(indexName: IndexName, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.rules)
          .appending(.clear)
      }

    }

    struct SaveList: AlgoliaCommand {

      let method: HTTPMethod = .post
      let callType: CallType = .write
      let path: URL
      let body: Data?
      let requestOptions: RequestOptions?

      init(indexName: IndexName, rules: [AlgoliaSearchClient.Rule], forwardToReplicas: Bool?, clearExistingRules: Bool?, requestOptions: RequestOptions?) {
        var parameters: [HTTPParameterKey: String] = [:]
        forwardToReplicas.flatMap { parameters[.forwardToReplicas] = String($0) }
        clearExistingRules.flatMap { parameters[.clearExistingRules] = String($0) }
        self.requestOptions = requestOptions.updateOrCreate(parameters)
        self.path = URL
          .indexesV1
          .appending(indexName)
          .appending(.rules)
          .appending(.batch)
        self.body = rules.httpBody
      }

    }

  }

}
