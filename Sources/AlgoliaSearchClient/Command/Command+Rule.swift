//
//  Command+Rule.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Command {

  enum Rule {

    struct Save: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, rule: AlgoliaSearchClient.Rule, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .rules >>> RuleCompletion.objectID(rule.objectID)
        urlRequest = .init(method: .put, path: path, body: rule.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct Get: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .rules >>> RuleCompletion.objectID(objectID)
        urlRequest = .init(method: .get, path: path, requestOptions: self.requestOptions)
      }

    }

    struct Delete: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, objectID: ObjectID, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .rules >>> RuleCompletion.objectID(objectID)
        urlRequest = .init(method: .delete, path: path, requestOptions: self.requestOptions)
      }

    }

    struct Search: AlgoliaCommand {

      let callType: CallType = .read
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, query: RuleQuery, requestOptions: RequestOptions?) {
        self.requestOptions = requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .rules >>> RuleCompletion.search
        urlRequest = .init(method: .post, path: path, body: query.httpBody, requestOptions: self.requestOptions)
      }

    }

    struct Clear: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, forwardToReplicas: Bool?, requestOptions: RequestOptions?) {
        self.requestOptions = forwardToReplicas.flatMap { requestOptions.updateOrCreate([.forwardToReplicas: String($0)]) } ?? requestOptions
        let path = .indexesV1 >>> .index(indexName) >>> .rules >>> RuleCompletion.clear
        urlRequest = .init(method: .post, path: path, requestOptions: self.requestOptions)
      }

    }

    struct SaveList: AlgoliaCommand {

      let callType: CallType = .write
      let urlRequest: URLRequest
      let requestOptions: RequestOptions?

      init(indexName: IndexName, rules: [AlgoliaSearchClient.Rule], forwardToReplicas: Bool?, clearExistingRules: Bool?, requestOptions: RequestOptions?) {
        var parameters: [HTTPParameterKey: String] = [:]
        forwardToReplicas.flatMap { parameters[.forwardToReplicas] = String($0) }
        clearExistingRules.flatMap { parameters[.clearExistingRules] = String($0) }
        self.requestOptions = requestOptions.updateOrCreate(parameters)
        let path = .indexesV1 >>> .index(indexName) >>> .rules >>> RuleCompletion.batch
        urlRequest = .init(method: .post, path: path, body: rules.httpBody, requestOptions: self.requestOptions)
      }

    }

  }

}
