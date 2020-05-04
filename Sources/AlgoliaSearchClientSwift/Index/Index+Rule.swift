//
//  Index+Rule.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

extension Index {
  
  //MARK: - Save rule
  
  /**
   Create or update a single rule.
   
   - Parameter rule: The Rule to save.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveRule(_ rule: Rule, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<RevisionIndex>) -> Operation {
    let command = Command.Template.init()
    return execute(command, completion: completion)
  }
  
  /**
   Create or update a single rule.

   - Parameter rule: The Rule to save.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func saveRule(_ rule: Rule, requestOptions: RequestOptions? = nil) throws -> RevisionIndex {
    let command = Command.Template.init()
    return try execute(command)
  }
  
  //MARK: - Save rules
  
  /**
   Create or update a specified set of rules, or all Rule.
   Each Rule will be created or updated, depending on whether a rule with the same ObjectID already exists.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func saveRules(_ rules: [Rule], requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<RevisionIndex>) -> Operation {
    let command = Command.Template.init()
    return execute(command, completion: completion)
  }
  
  /**
   Create or update a specified set of rules, or all Rule.
   Each Rule will be created or updated, depending on whether a rule with the same ObjectID already exists.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func saveRules(_ rules: [Rule], requestOptions: RequestOptions? = nil) throws -> RevisionIndex {
    let command = Command.Template.init()
    return try execute(command)
  }
  
  //MARK: - Get rule
  
  /**
   Get a specific Rule.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func getRule(withID objectID: ObjectID, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<Rule>) -> Operation {
    let command = Command.Template.init()
    return execute(command, completion: completion)
  }
  
  /**
   Get a specific Rule.

   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Rule  object
   */
  @discardableResult func getRule(withID objectID: ObjectID, requestOptions: RequestOptions? = nil) throws -> Rule {
    let command = Command.Template.init()
    return try execute(command)
  }
  
  //MARK: - Delete rule
  
  /**
   Delete a specific Rule using its ObjectID.
   
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func deleteRule(withID objectID: ObjectID, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<Rule>) -> Operation {
    let command = Command.Template.init()
    return execute(command, completion: completion)
  }
  
  /**
   Delete a specific Rule using its ObjectID.

   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: Rule  object
   */
  @discardableResult func deleteRule(withID objectID: ObjectID, requestOptions: RequestOptions? = nil) throws -> Rule {
    let command = Command.Template.init()
    return try execute(command)
  }

  //MARK: - Search rules
  
  /**
   Search for Rule matching RuleQuery.
   
   - Parameter query: The RuleQuery
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func searchRules(_ query: RuleQuery, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<RuleSearchResponse>) -> Operation {
    let command = Command.Template.init()
    return execute(command, completion: completion)
  }
  
  /**
   Search for Rule matching RuleQuery.

   - Parameter query: The RuleQuery
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RuleSearchResponse  object
   */
  @discardableResult func searchRules(_ query: RuleQuery, requestOptions: RequestOptions? = nil) throws -> RuleSearchResponse {
    let command = Command.Template.init()
    return try execute(command)
  }
  
  //MARK: - Clear rules
  
  /**
   Delete all Rule in an index.
   
   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Parameter completion: Result completion
   - Returns: Launched asynchronous operation
   */
  @discardableResult func clearRules(forwardToReplicas: Bool? = nil, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<RevisionIndex>) -> Operation {
    let command = Command.Template.init()
    return execute(command, completion: completion)
  }
  
  /**
   Delete all Rule in an index.

   - Parameter forwardToReplicas: Whether to forward the operation to the replica indices.
   - Parameter requestOptions: Configure request locally with RequestOptions
   - Returns: RevisionIndex  object
   */
  @discardableResult func clearRules(forwardToReplicas: Bool? = nil, requestOptions: RequestOptions? = nil) throws -> RevisionIndex {
    let command = Command.Template.init()
    return try execute(command)
  }
  
  //MARK: - Replace all rules
  
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
  @discardableResult func replaceAllRules(with rules: [Rule], forwardToReplicas: Bool? = nil, requestOptions: RequestOptions? = nil, completion: @escaping ResultCallback<RevisionIndex>) -> Operation {
    let command = Command.Template.init()
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
  @discardableResult func replaceAllRules(with rules: [Rule], forwardToReplicas: Bool? = nil, requestOptions: RequestOptions? = nil) throws -> RevisionIndex {
    let command = Command.Template.init()
    return try execute(command)
  }
  
}
