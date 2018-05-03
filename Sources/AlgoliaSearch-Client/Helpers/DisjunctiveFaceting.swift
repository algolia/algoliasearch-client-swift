//
//  Copyright (c) 2016 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation


/// Disjunctive faceting helper.
///
internal class DisjunctiveFaceting {
    typealias MultipleQuerier = (_ queries: [Query], _ completionHandler: @escaping CompletionHandler) -> Operation

    /// Block used to perform the multiple queries.
    private let multipleQuerier: MultipleQuerier

    internal init(multipleQuerier: @escaping MultipleQuerier) {
        self.multipleQuerier = multipleQuerier
    }
    
    /// Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets (helper).
    ///
    /// - parameter query: The query.
    /// - parameter disjunctiveFacets: List of disjunctive facets.
    /// - parameter refinements: The current refinements, mapping facet names to a list of values.
    /// - parameter completionHandler: Completion handler to be notified of the request's outcome.
    /// - returns: A cancellable operation.
    ///
    @discardableResult
    func searchDisjunctiveFaceting(_ query: Query, disjunctiveFacets: [String], refinements: [String: [String]], completionHandler: @escaping CompletionHandler) -> Operation {
        var queries = [Query]()
        
        // Build the first, global query.
        let globalQuery = Query(copy: query)
        globalQuery.facetFilters = DisjunctiveFaceting._buildFacetFilters(disjunctiveFacets: disjunctiveFacets, refinements: refinements, excludedFacet: nil)
        queries.append(globalQuery)
        
        // Build the refined queries.
        for disjunctiveFacet in disjunctiveFacets {
            let disjunctiveQuery = Query(copy: query)
            disjunctiveQuery.facets = [disjunctiveFacet]
            disjunctiveQuery.facetFilters = DisjunctiveFaceting._buildFacetFilters(disjunctiveFacets: disjunctiveFacets, refinements: refinements, excludedFacet: disjunctiveFacet)
            // We are not interested in the hits for this query, only the facet counts, so let's limit the output.
            disjunctiveQuery.hitsPerPage = 0
            disjunctiveQuery.attributesToRetrieve = []
            disjunctiveQuery.attributesToHighlight = []
            disjunctiveQuery.attributesToSnippet = []
            // Do not show this query in analytics, either.
            disjunctiveQuery.analytics = false
            queries.append(disjunctiveQuery)
        }
        
        // Run all the queries.
        let operation = self.multipleQuerier(queries) { (content, error) -> Void in
            var finalContent: [String: Any]? = nil
            var finalError: Error? = error
            if error == nil {
                do {
                    finalContent = try DisjunctiveFaceting._aggregateResults(disjunctiveFacets: disjunctiveFacets, refinements: refinements, content: content!)
                } catch let e {
                    finalError = e
                }
            }
            assert(finalContent != nil || finalError != nil)
            completionHandler(finalContent, finalError)
        }
        return operation
    }
    
    /// Aggregate disjunctive faceting search results.
    private class func _aggregateResults(disjunctiveFacets: [String], refinements: [String: [String]], content: [String: Any]) throws -> [String: Any] {
        guard let results = content["results"] as? [AnyObject] else {
            throw InvalidJSONError(description: "No results in response")
        }
        // The first answer is used as the basis for the response.
        guard var mainContent = results[0] as? [String: Any] else {
            throw InvalidJSONError(description: "Invalid results in response")
        }
        // Following answers are just used for their facet counts.
        var disjunctiveFacetCounts = [String: Any]()
        var facetsStats = [String: Any]()
        for i in 0..<results.count { // for each answer (= each disjunctive facet)
            guard let result = results[i] as? [String: Any] else {
                throw InvalidJSONError(description:  "Invalid results in response")
            }
            // Facets stats, starts from element 0
            if let allStats = result["facets_stats"] as? [String: [String: Any]] {
                for (facetName, stats) in allStats {
                    facetsStats[facetName] = stats
                }
            }
            // Disjunctive facet should start from element 1
            if i <= 0 {
                continue
            }
            guard let allFacetCounts = result["facets"] as? [String: [String: Any]] else {
                throw InvalidJSONError(description:  "Invalid results in response")
            }
            // NOTE: Iterating, but there should be just one item.
            for (facetName, facetCounts) in allFacetCounts {
                var newFacetCounts = facetCounts
                // Add zeroes for missing values.
                if disjunctiveFacets.contains(facetName) {
                    if let refinedValues = refinements[facetName] {
                        for refinedValue in refinedValues {
                            if facetCounts[refinedValue] == nil {
                                newFacetCounts[refinedValue] = 0
                            }
                        }
                    }
                }
                disjunctiveFacetCounts[facetName] = newFacetCounts
            }
            // If facet counts are not exhaustive, propagate this information to the main results.
            // Because disjunctive queries are less restrictive than the main query, it can happen that the main query
            // returns exhaustive facet counts, while the disjunctive queries do not.
            if let exhaustiveFacetsCount = result["exhaustiveFacetsCount"] as? Bool {
                if !exhaustiveFacetsCount {
                    mainContent["exhaustiveFacetsCount"] = false
                }
            }
        }
        mainContent["disjunctiveFacets"] = disjunctiveFacetCounts
        mainContent["facets_stats"] = facetsStats
        return mainContent
    }
    
    /// Build the facet filters, either global or for the selected disjunctive facet.
    ///
    /// - parameter excludedFacet: The disjunctive facet to exclude from the filters. If nil, no facet is
    ///   excluded (thus building the global filters).
    ///
    private class func _buildFacetFilters(disjunctiveFacets: [String], refinements: [String: [String]], excludedFacet: String?) -> [Any] {
        var facetFilters: [Any] = []
        for (facetName, facetValues) in refinements {
            // Disjunctive facet: OR all values, and AND with the rest of the filters.
            if disjunctiveFacets.contains(facetName) {
                // Skip the specified disjunctive facet, if any.
                if facetName == excludedFacet {
                    continue
                }
                var disjunctiveOperator = [String]()
                for facetValue in facetValues {
                    disjunctiveOperator.append("\(facetName):\(facetValue)")
                }
                facetFilters.append(disjunctiveOperator)
            }
                // Conjunctive facet: AND all values with the rest of the filters.
            else {
                assert(facetName != excludedFacet)
                for facetValue in facetValues {
                    facetFilters.append("\(facetName):\(facetValue)")
                }
            }
        }
        return facetFilters
    }
}
