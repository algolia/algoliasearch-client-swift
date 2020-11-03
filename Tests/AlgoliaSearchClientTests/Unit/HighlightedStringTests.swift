//
//  HighlightedStringTests.swift
//  
//
//  Created by Vladislav Fitc on 05/06/2020.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class HighlightedStringTests: XCTestCase {
  
    func testWithDecodedString() throws {

      let expectedHighlightedPart = "rennais"
      
      let inlineString = "VIDÉO. Des CRS déployés devant un lycée <em>rennais</em> pour les épreuves anticipées du bac"

      let stringData = try Data(filename: "HighlightedString.json")
      let decodedString = try XCTUnwrap(String(data: stringData, encoding: .utf8))

      let inlineHiglighted = HighlightedString(string: inlineString)
      let decodedHighlighted = HighlightedString(string: decodedString)
      
      func extractHighlightedPart(from title: HighlightedString) -> String {
        var taggedString = title.taggedString
        let highlightedRange = taggedString.taggedRanges.first!
        let highlightedPart = taggedString.output[highlightedRange]
        return String(highlightedPart)
      }
      
      XCTAssertEqual(expectedHighlightedPart, extractHighlightedPart(from: inlineHiglighted))
      XCTAssertEqual(expectedHighlightedPart, extractHighlightedPart(from: decodedHighlighted))

    }
  
  func testDiacritic() throws {
    let input = """
    Le 30 octobre, un concert de musiques gaéliques irlandaises <ém>e</ëm>t <em>é</em>cossaises <em>e</em>st au programme. À travers de nombreux airs, pour la plupart de compositeurs inconnus ou anonymes, The Curious Bards vous feront découvrir leur « livre de chevet musical » ; ces collections d’airs, propres aux musiciens itinérants du XVIIe <em>e</em>t XVIIIe siècle <em>e</em>n <em>Irlande</em> <em>e</em>t <em>e</em>n <em>E</em>́cosse, ils vous amèneront au plus près de l’âme celte <em>e</em>t gaélique. L’<èm>e</em>nsemble sera composé d’Alix Boivert, violon baroque, Sarah Van Oudenhove, viole de gambe, Bruno Harlé, flûtes, Louis Capeille, harpe, <em>e</em>t Jean-Christophe Morel, cistre. Vendredi 30 octobre, à 20 h 30, à la Maison de la culture <êm>e</em>t des loisirs. Tarifs : plein 15 <em>€</em>́ ; réduit 10 <em>€</em>.
    """
    
    let highlightedString = HighlightedString(string: input)
    var taggedString = highlightedString.taggedString
    
    let taggedRanges = taggedString.taggedRanges
    let output = taggedString.output
    let highlightedStrings: [String] = taggedRanges.map { output[$0] }.map(String.init)
    
    let expectedHighlightedStrings = [
      "e", "é", "e", "e", "e", "Irlande", "e", "e", "E", "e", "e", "e", "e", "€", "€"
    ]
    
    XCTAssertEqual(highlightedStrings, expectedHighlightedStrings)
    
  }


}

