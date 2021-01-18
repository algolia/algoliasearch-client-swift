//
//  Query+URLEncodable.swift
//  
//
//  Created by Vladislav Fitc on 21/04/2020.
//

import Foundation

extension Query {

  struct URLEncoder<Key: RawRepresentable> where Key.RawValue == String {

    var queryItems: [URLQueryItem] = []

    mutating func set<T: URLEncodable>(_ value: T?, for key: Key) {
      guard let value = value else { return }
      queryItems.append(.init(name: key.rawValue, value: value.urlEncodedString))
    }

    mutating func set<S: Sequence>(_ value: S?, for key: Key) where S.Element == String {
      guard let value = value else { return }
      queryItems.append(.init(name: key.rawValue, value: value.map(\.urlEncodedString).sorted().joined(separator: ",")))
    }

    mutating func set<S: Sequence>(_ value: S?, for key: Key) where S.Element: RawRepresentable, S.Element.RawValue == String {
      guard let value = value else { return }
      queryItems.append(.init(name: key.rawValue, value: value.map(\.rawValue).map(\.urlEncodedString).sorted().joined(separator: ",")))
    }

    mutating func set<S: Sequence>(_ value: S?, for key: Key) where S.Element == [String] {
      guard let value = value else { return }
      let valueToSet = value.map { $0.map(\.urlEncodedString).sorted().joined(separator: ",").wrappedInBrackets() }.joined(separator: ",").wrappedInBrackets()
      queryItems.append(.init(name: key.rawValue, value: valueToSet))
    }

    mutating func set(_ value: FiltersStorage?, for key: Key) {
      guard let value = value?.rawValue else { return }
      func toString(_ singleOrList: SingleOrList<String>) -> String {
        switch singleOrList {
        case .single(let value):
          return value.wrappedInQuotes()
        case .list(let list):
          return list.map { $0.wrappedInQuotes() }.joined(separator: ",").wrappedInBrackets()
        }
      }
      let valueToSet = value.map(toString).joined(separator: ",").wrappedInBrackets()
      queryItems.append(.init(name: key.rawValue, value: valueToSet))
    }

    mutating func set<S: Sequence>(_ value: S?, for key: Key) where S.Element == BoundingBox {
      guard let value = value else { return }
      let valueToSet = value.map(\.urlEncodedString).joined(separator: ",").wrappedInBrackets()
      queryItems.append(.init(name: key.rawValue, value: valueToSet))
    }

    mutating func set<S: Sequence>(_ value: S?, for key: Key) where S.Element == AroundPrecision {
      guard let value = value else { return }
      let valueToSet = value.map(\.urlEncodedString).joined(separator: ",").wrappedInBrackets()
      queryItems.append(.init(name: key.rawValue, value: valueToSet))
    }

    mutating func set<S: Sequence>(_ value: S?, for key: Key) where S.Element == Polygon {
      guard let value = value else { return }
      let valueToSet = value.map(\.urlEncodedString).joined(separator: ",").wrappedInBrackets()
      queryItems.append(.init(name: key.rawValue, value: valueToSet))
    }

    mutating func set(_ value: [String: JSON]?) {

      guard let value = value else { return }

      func extract(_ value: JSON) -> String? {
        switch value {
        case .string(let value):
          return value

        case .bool(let value):
          return String(value)

        case .number(let value):
          return String(value)

        default:
          return nil
        }
      }

      let sortedKeyValues = value.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }
      for (key, value) in sortedKeyValues {
        if let extracted = extract(value) {
          queryItems.append(.init(name: key, value: extracted))
        } else if case .array(let values) = value {
          let value = values.compactMap(extract).joined(separator: ",")
          if !value.isEmpty {
            queryItems.append(.init(name: key, value: value))
          }
        }
      }

    }

    func encode() -> String? {
      var components = URLComponents()
      components.queryItems = queryItems
      return components.percentEncodedQuery
    }

  }

}

extension Query: URLEncodable {

  public var urlEncodedString: String {

    var urlEncoder = URLEncoder<SearchParametersStorage.CodingKeys>()

    urlEncoder.set(query, for: .query)
    urlEncoder.set(similarQuery, for: .similarQuery)
    urlEncoder.set(distinct, for: .distinct)
    urlEncoder.set(getRankingInfo, for: .getRankingInfo)
    urlEncoder.set(explainModules, for: .explainModules)
    urlEncoder.set(attributesToRetrieve, for: .attributesToRetrieve)
    urlEncoder.set(restrictSearchableAttributes, for: .restrictSearchableAttributes)
    urlEncoder.set(filters, for: .filters)
    urlEncoder.set(facetFilters, for: .facetFilters)
    urlEncoder.set(optionalFilters, for: .optionalFilters)
    urlEncoder.set(numericFilters, for: .numericFilters)
    urlEncoder.set(tagFilters, for: .tagFilters)
    urlEncoder.set(sumOrFiltersScores, for: .sumOrFiltersScores)
    urlEncoder.set(facets, for: .facets)
    urlEncoder.set(maxValuesPerFacet, for: .maxValuesPerFacet)
    urlEncoder.set(facetingAfterDistinct, for: .facetingAfterDistinct)
    urlEncoder.set(sortFacetsBy, for: .sortFacetsBy)
    urlEncoder.set(maxFacetHits, for: .maxFacetHits)
    urlEncoder.set(attributesToHighlight, for: .attributesToHighlight)
    urlEncoder.set(attributesToSnippet, for: .attributesToSnippet)
    urlEncoder.set(highlightPreTag, for: .highlightPreTag)
    urlEncoder.set(highlightPostTag, for: .highlightPostTag)
    urlEncoder.set(snippetEllipsisText, for: .snippetEllipsisText)
    urlEncoder.set(restrictHighlightAndSnippetArrays, for: .restrictHighlightAndSnippetArrays)
    urlEncoder.set(page, for: .page)
    urlEncoder.set(hitsPerPage, for: .hitsPerPage)
    urlEncoder.set(offset, for: .offset)
    urlEncoder.set(length, for: .length)
    urlEncoder.set(minWordSizeFor1Typo, for: .minWordSizeFor1Typo)
    urlEncoder.set(minWordSizeFor2Typos, for: .minWordSizeFor2Typos)
    urlEncoder.set(typoTolerance, for: .typoTolerance)
    urlEncoder.set(allowTyposOnNumericTokens, for: .allowTyposOnNumericTokens)
    urlEncoder.set(disableTypoToleranceOnAttributes, for: .disableTypoToleranceOnAttributes)
    urlEncoder.set(aroundLatLng?.stringForm, for: .aroundLatLng)
    urlEncoder.set(aroundLatLngViaIP, for: .aroundLatLngViaIP)
    urlEncoder.set(aroundRadius, for: .aroundRadius)
    urlEncoder.set(aroundPrecision, for: .aroundPrecision)
    urlEncoder.set(minimumAroundRadius, for: .minimumAroundRadius)
    urlEncoder.set(insideBoundingBox, for: .insideBoundingBox)
    urlEncoder.set(insidePolygon, for: .insidePolygon)
    urlEncoder.set(queryType, for: .queryType)
    urlEncoder.set(removeWordsIfNoResults, for: .removeWordsIfNoResults)
    urlEncoder.set(advancedSyntax, for: .advancedSyntax)
    urlEncoder.set(advancedSyntaxFeatures, for: .advancedSyntaxFeatures)
    urlEncoder.set(optionalWords, for: .optionalWords)
    urlEncoder.set(removeStopWords, for: .removeStopWords)
    urlEncoder.set(disableExactOnAttributes, for: .disableExactOnAttributes)
    urlEncoder.set(exactOnSingleWordQuery, for: .exactOnSingleWordQuery)
    urlEncoder.set(alternativesAsExact, for: .alternativesAsExact)
    urlEncoder.set(ignorePlurals, for: .ignorePlurals)
    urlEncoder.set(queryLanguages, for: .queryLanguages)
    urlEncoder.set(enableRules, for: .enableRules)
    urlEncoder.set(ruleContexts, for: .ruleContexts)
    urlEncoder.set(enablePersonalization, for: .enablePersonalization)
    urlEncoder.set(personalizationImpact, for: .personalizationImpact)
    urlEncoder.set(userToken, for: .userToken)
    urlEncoder.set(analytics, for: .analytics)
    urlEncoder.set(analyticsTags, for: .analyticsTags)
    urlEncoder.set(enableABTest, for: .enableABTest)
    urlEncoder.set(clickAnalytics, for: .clickAnalytics)
    urlEncoder.set(synonyms, for: .synonyms)
    urlEncoder.set(replaceSynonymsInHighlight, for: .replaceSynonymsInHighlight)
    urlEncoder.set(minProximity, for: .minProximity)
    urlEncoder.set(responseFields, for: .responseFields)
    urlEncoder.set(percentileComputation, for: .percentileComputation)
    urlEncoder.set(naturalLanguages, for: .naturalLanguages)
    urlEncoder.set(customParameters)

    return urlEncoder.encode()!
  }

}
