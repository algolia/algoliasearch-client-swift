//
//  Rule+Condition.swift
//  
//
//  Created by Vladislav Fitc on 04/05/2020.
//

import Foundation

extension Rule {

  public struct Condition: Codable, Builder {

    public var anchoring: Anchoring?
    public var pattern: Pattern?

    /// Rule context (format: [A-Za-z0-9_-]+). When specified, the rule is contextual and applies only when the
    /// same context is specified at query time (using the ruleContexts parameter). When absent, the rule is generic
    /// and always applies (provided that its other conditions are met, of course).
    public var context: String?

    /// Indicates if the rule can be applied with alternatives.
    public var alternatives: Alternatives?

    public init(anchoring: Anchoring? = nil,
                pattern: Pattern? = nil,
                context: String? = nil,
                alternatives: Alternatives? = nil) {
      self.anchoring = anchoring
      self.pattern = pattern
      self.context = context
      self.alternatives = alternatives
    }

  }

}
