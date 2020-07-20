//
//  Index+Rule.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

public extension Index {

  // MARK: - Save rule

  /**
   Create or update a single rule.
   
   - Parameter rule: The Rule to save.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveRule(_ rule: Rule,
                                   forwardToReplicas: Bool? = nil,
                                   requestOptions: RequestOptions? = nil,
                                   completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation {
    let command = Command.Rule.Save(indexName: name, rule: rule, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or update a single rule.

   - Parameter rule: The Rule to save.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func saveRule(_ rule: Rule,
                                   forwardToReplicas: Bool? = nil,
                                   requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Rule.Save(indexName: name, rule: rule, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Save rules

  /**
   Create or update a specified set of rules, or all Rule.
   Each Rule will be created or updated, depending on whether a rule with the same ObjectID already exists.
   
   - Parameter rules: The list of Rule to save.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter clearExistingRules: Whether the batch will remove all existing rules before adding/updating the rules.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveRules(_ rules: [Rule],
                                    forwardToReplicas: Bool? = nil,
                                    clearExistingRules: Bool? = nil,
                                    requestOptions: RequestOptions? = nil,
                                    completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation {
    let command = Command.Rule.SaveList(indexName: name, rules: rules, forwardToReplicas: forwardToReplicas, clearExistingRules: clearExistingRules, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Create or update a specified set of rules, or all Rule.
   Each Rule will be created or updated, depending on whether a rule with the same ObjectID already exists.
   
   - Parameter rules: The list of Rule to save.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter clearExistingRules: Whether the batch will remove all existing rules before adding/updating the rules.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func saveRules(_ rules: [Rule],
                                    forwardToReplicas: Bool? = nil,
                                    clearExistingRules: Bool? = nil,
                                    requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Rule.SaveList(indexName: name, rules: rules, forwardToReplicas: forwardToReplicas, clearExistingRules: clearExistingRules, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Get rule

  /**
   Get a specific Rule.
   
   - Parameter objectID: The ObjectID of the rule to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getRule(withID objectID: ObjectID,
                                  requestOptions: RequestOptions? = nil,
                                  completion: @escaping ResultCallback<Rule>) -> Operation {
    let command = Command.Rule.Get(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Get a specific Rule.

   - Parameter objectID: The ObjectID of the rule to retrieve.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Rule  object
   */
  @discardableResult func getRule(withID objectID: ObjectID,
                                  requestOptions: RequestOptions? = nil) throws -> Rule {
    let command = Command.Rule.Get(indexName: name, objectID: objectID, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Delete rule

  /**
   Delete a specific Rule using its ObjectID.
   
   - Parameter objectID: The ObjectID of the rule to delete.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteRule(withID objectID: ObjectID,
                                     forwardToReplicas: Bool? = nil,
                                     requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation {
    let command = Command.Rule.Delete(indexName: name, objectID: objectID, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Delete a specific Rule using its ObjectID.

   - Parameter objectID: The ObjectID of the rule to delete.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Rule  object
   */
  @discardableResult func deleteRule(withID objectID: ObjectID,
                                     forwardToReplicas: Bool? = nil,
                                     requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Rule.Delete(indexName: name, objectID: objectID, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Search rules

  /**
   Search for Rule matching RuleQuery.
   
   - Parameter query: The RuleQuery
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchRules(_ query: RuleQuery,
                                      requestOptions: RequestOptions? = nil,
                                      completion: @escaping ResultCallback<RuleSearchResponse>) -> Operation {
    let command = Command.Rule.Search(indexName: name, query: query, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Search for Rule matching RuleQuery.

   - Parameter query: The RuleQuery
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RuleSearchResponse  object
   */
  @discardableResult func searchRules(_ query: RuleQuery,
                                      requestOptions: RequestOptions? = nil) throws -> RuleSearchResponse {
    let command = Command.Rule.Search(indexName: name, query: query, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Clear rules

  /**
   Delete all Rule in an index.
   
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func clearRules(forwardToReplicas: Bool? = nil,
                                     requestOptions: RequestOptions? = nil,
                                     completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation {
    let command = Command.Rule.Clear(indexName: name, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Delete all Rule in an index.

   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func clearRules(forwardToReplicas: Bool? = nil,
                                     requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Rule.Clear(indexName: name, forwardToReplicas: forwardToReplicas, requestOptions: requestOptions)
    return try execute(command)
  }

  // MARK: - Replace all rules

  /**
   Push a new set of rules and erase all previous ones.
   This method, like .replaceAllObjects, guarantees zero downtime.
   All existing Rule are deleted and replaced with the new ones, in a single, atomic operation.
   
   - Parameter rules: The list of Rule to replace.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func replaceAllRules(with rules: [Rule],
                                          forwardToReplicas: Bool? = nil,
                                          requestOptions: RequestOptions? = nil,
                                          completion: @escaping ResultTaskCallback<IndexRevision>) -> Operation {
    let command = Command.Rule.SaveList(indexName: name, rules: rules, forwardToReplicas: forwardToReplicas, clearExistingRules: true, requestOptions: requestOptions)
    return execute(command, completion: completion)
  }

  /**
   Push a new set of rules and erase all previous ones.
   This method, like .replaceAllObjects, guarantees zero downtime.
   All existing Rule are deleted and replaced with the new ones, in a single, atomic operation.

   - Parameter rules: The list of Rule to replace.
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func replaceAllRules(with rules: [Rule],
                                          forwardToReplicas: Bool? = nil,
                                          requestOptions: RequestOptions? = nil) throws -> WaitableWrapper<IndexRevision> {
    let command = Command.Rule.SaveList(indexName: name, rules: rules, forwardToReplicas: forwardToReplicas, clearExistingRules: true, requestOptions: requestOptions)
    return try execute(command)
  }

}
