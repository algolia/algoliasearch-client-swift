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

#import <XCTest/XCTest.h>

@import AlgoliaSearch;


/// Verifies that all the features are accessible from Objective-C.
///
/// + Warning: This tests mostly **compilation**! The behavior is already tested in Swift test cases.
///
/// + Note: Only the public API is tested here.
///
@interface ObjectiveCBridging : XCTestCase

@end


@implementation ObjectiveCBridging

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testQuery {
    // Init
    // ----
    Query* query = [Query new];
    query = [[Query alloc] initWithQuery:@"text"];
    query = [[Query alloc] initWithParameters:@{ @"foo": @"bar" }];

    // Methods
    // -------
    // Parameter accessors.
    [query setParameterWithName:@"foo" to:@"bar"];
    XCTAssertNotNil([query parameterWithName:@"foo"]);

    // Subscript.
    query[@"foo"] = [query[@"foo"] stringByAppendingString:@"baz"];

    // Copying.
    Query* query2 = [query copy];
    XCTAssertEqualObjects([query2 class], [Query class]);
    XCTAssertEqualObjects(query, query2);

    // Building/parsing.
    Query* query3 = [Query parse:[query build]];
    XCTAssertEqualObjects(query, query3);

    // Properties
    // ----------
    query.query = @"text";
    query.queryType = @"prefixAll";
    query.typoTolerance = @"strict";
    query.minWordSizefor1Typo = [NSNumber numberWithInt:5];
    query.minWordSizefor2Typos = [NSNumber numberWithInt:10];
    query.allowTyposOnNumericTokens = [NSNumber numberWithBool:YES];
    query.ignorePlurals = [NSNumber numberWithBool:YES];
    query.restrictSearchableAttributes = @[ @"foo", @"bar" ];
    query.advancedSyntax = [NSNumber numberWithBool:YES];
    query.analytics = [NSNumber numberWithBool:YES];
    query.analyticsTags = @[ @"foo", @"bar" ];
    query.synonyms = [NSNumber numberWithBool:YES];
    query.replaceSynonymsInHighlight = [NSNumber numberWithBool:YES];
    query.optionalWords = @[ @"foo", @"bar" ];
    query.minProximity = [NSNumber numberWithInt:6];
    query.removeWordsIfNoResults = @"allOptional";
    query.disableTypoToleranceOnAttributes = @[ @"foo", @"bar" ];
    query.removeStopWords = @[ @"en", @"fr" ];
    query.disableExactOnAttributes = @[ @"foo", @"bar" ];
    query.exactOnSingleWordQuery = @"attribute";
    query.alternativesAsExact = @[ @"foo", @"bar" ];
    query.page = [NSNumber numberWithInt:6];
    query.hitsPerPage = [NSNumber numberWithInt:66];
    query.offset = [NSNumber numberWithInt:4];
    query.length = [NSNumber numberWithInt:4];
    query.attributesToRetrieve = @[ @"foo", @"bar" ];
    query.attributesToHighlight = @[ @"foo", @"bar" ];
    query.attributesToSnippet = @[ @"foo", @"bar" ];
    query.getRankingInfo = [NSNumber numberWithBool:YES];
    query.highlightPreTag = @"<mark>";
    query.highlightPostTag = @"</mark>";
    query.snippetEllipsisText = @"...";
    query.restrictHighlightAndSnippetArrays = false;
    query.numericFilters = @[ @"foo > 0", @"baz < 1000" ];
    query.tagFilters = @[ @"foo", @"bar" ];
    query.distinct = [NSNumber numberWithInt:6];
    query.facets = @[ @"foo", @"bar" ];
    query.facetFilters = @[ @"foo:bar", @"baz:blip" ];
    query.maxValuesPerFacet = [NSNumber numberWithInt:666];
    query.filters = @"foo = 0 AND bar < 1000";
    query.aroundLatLng = [[LatLng alloc] initWithLat:123.45 lng:67.89];
    query.aroundLatLngViaIP = [NSNumber numberWithBool:YES];
    query.aroundRadius = [NSNumber numberWithInt:666];
    query.aroundRadius = [Query aroundRadiusAll];
    query.aroundPrecision = [NSNumber numberWithInt:66];
    query.minimumAroundRadius = [NSNumber numberWithInt:666];
    query.insideBoundingBox = @[ [[GeoRect alloc] initWithP1:[[LatLng alloc] initWithLat:123.45 lng:67.89] p2:[[LatLng alloc] initWithLat:129.99 lng:69.99]] ];
    query.insidePolygon = @[
        @[ [[LatLng alloc] initWithLat:123.45 lng:67.89], [[LatLng alloc] initWithLat:129.99 lng:69.99], [[LatLng alloc] initWithLat:0.0 lng:0.0] ]
    ];
    query.responseFields = @[ @"foo", @"bar" ];
    query.facetingAfterDistinct = @YES;
}

- (void)testClient {
    Client* client = [[Client alloc] initWithAppID:@"APPID" apiKey:@"APIKEY"];

    // Properties
    // ----------

    // API key.
    client.apiKey = [client.apiKey stringByAppendingString:@"EVENMORENONSENSE"];

    // Headers.
    [client setHeaderWithName:@"Foo-Bar" to:[client headerWithName:@"User-Agent"]];

    NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithDictionary:[client headers]];
    [headers setValue:@"baz" forKey:@"Foo-Bar"];
    client.headers = headers;

    // Timeouts.
    client.timeout = client.timeout + 10;
    client.searchTimeout = client.searchTimeout + 5;

    // Hosts.
    client.readHosts = [client.readHosts arrayByAddingObject:@"nowhere.net"];
    client.writeHosts = [client.writeHosts arrayByAddingObject:@"nobody.com"];
    [client setHosts:@[ @"nowhere.net", @"nobody.com", @"never.org" ]];
    client.hostStatusTimeout = [Client defaultHostStatusTimeout];

    // Completion queue.
    client.completionQueue = NSOperationQueue.mainQueue;
    
    // Operations
    // ----------
    [client listIndexes:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client deleteIndexWithName:@"name" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client moveIndexFrom:@"from" to:@"to" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client copyIndexFrom:@"from" to:@"to" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    // TODO: Strategy constant
    [client multipleQueries:@[ [[IndexQuery alloc] initWithIndexName:@"name" query:[Query new]] ] strategy:@"stopIfEnoughMatches" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client batchOperations:@[ @{@"dummy": @"operation" } ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client isAlive:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
}

- (void)testIndex {
    Client* client = [[Client alloc] initWithAppID:@"APPID" apiKey:@"APIKEY"];
    Index* index = [client indexWithName:@"unknown"];

    // Properties
    // ----------
    // Client.
    XCTAssertEqual(client, index.client);

    // Name.
    XCTAssertEqual(@"unknown", index.name);

    // Operations
    // ----------
    NSDictionary<NSString*, id>* DUMMY_JSON = @{ @"objectID": @"snoopy", @"kind": @"dog" };
    [index addObject:DUMMY_JSON completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index addObject:DUMMY_JSON withID:@"snoopy" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index addObjects:@[ DUMMY_JSON ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index saveObject:DUMMY_JSON completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index saveObjects:@[ DUMMY_JSON ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index deleteObjectWithID:@"snoopy" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index deleteObjectsWithIDs:@[ @"snoopy", @"woodstock" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index getObjectWithID:@"snoopy" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index getObjectWithID:@"snoopy" attributesToRetrieve:@[ @"foo", @"bar" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index getObjectsWithIDs:@[ @"snoopy", @"woodstock" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index getObjectsWithIDs:@[ @"snoopy", @"woodstock" ] attributesToRetrieve:@[ @"foo", @"bar" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index partialUpdateObject:DUMMY_JSON withID:@"snoopy" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index partialUpdateObject:DUMMY_JSON withID:@"snoopy" createIfNotExists:NO completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index partialUpdateObjects:@[ DUMMY_JSON ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index partialUpdateObjects:@[ DUMMY_JSON ] createIfNotExists:NO completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index search:[Query new] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index searchForFacetValuesOf:@"facet" matching:@"text" query:nil completionHandler:^(NSDictionary<NSString *,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index getSettings:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index setSettings:DUMMY_JSON completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index setSettings:DUMMY_JSON forwardToReplicas:YES completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index clearIndex:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index batchOperations:@[ @{@"dummy": @"operation" } ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index browseWithQuery:[Query new] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index browseFromCursor:@"cursor" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index waitTaskWithID:666 completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index deleteByQuery:[Query new] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index searchDisjunctiveFaceting:[Query new] disjunctiveFacets:@[ @"disjunctive", @"facets" ] refinements:@{ @"facets": @[ @"refinements" ] } completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    // TODO: Constant
    [index multipleQueries:@[ [Query new] ] strategy:@"stopIfEnoughMatches" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];

    // Search cache
    // ------------
    index.searchCacheEnabled = YES;
    index.searchCacheExpiringTimeInterval = 60.0;
    [index clearSearchCache];
}

// MARK: Test specific query properties

- (void)test_queryType {
    Query* query1 = [Query new];
    XCTAssertNil(query1.queryType);

    for (NSString* value in @[ @"prefixAll", @"prefixLast", @"prefixNone" ]) {
        query1.queryType = value;
        XCTAssertEqualObjects(query1[@"queryType"], value);
        Query* query2 = [Query parse:[query1 build]];
        XCTAssertEqualObjects(query2.queryType, value);
    }

    query1[@"queryType"] = @"invalid";
    XCTAssertNil(query1.queryType);
}

- (void)test_typoTolerance {
    Query* query1 = [Query new];
    XCTAssertNil(query1.typoTolerance);

    for (NSString* value in @[ @"true", @"false", @"min", @"strict" ]) {
        query1.typoTolerance = value;
        XCTAssertEqualObjects(query1[@"typoTolerance"], value);
        Query* query2 = [Query parse:[query1 build]];
        XCTAssertEqualObjects(query2.typoTolerance, value);
    }

    query1[@"typoTolerance"] = @"invalid";
    XCTAssertNil(query1.typoTolerance);
}

- (void)test_minWordSizefor1Typo {
    Query* query1 = [Query new];
    XCTAssertNil(query1.minWordSizefor1Typo);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.minWordSizefor1Typo = value;
    XCTAssertEqualObjects(query1[@"minWordSizefor1Typo"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.minWordSizefor1Typo, value);
}

- (void)test_minWordSizefor2Typos {
    Query* query1 = [Query new];
    XCTAssertNil(query1.minWordSizefor2Typos);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.minWordSizefor2Typos = value;
    XCTAssertEqualObjects(query1[@"minWordSizefor2Typos"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.minWordSizefor2Typos, value);
}

- (void)test_allowTyposOnNumericTokens {
    Query* query1 = [Query new];
    XCTAssertNil(query1.allowTyposOnNumericTokens);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.allowTyposOnNumericTokens = value;
    XCTAssertEqualObjects(query1[@"allowTyposOnNumericTokens"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.allowTyposOnNumericTokens, value);
}

- (void)test_ignorePlurals {
    Query* query1 = [Query new];
    XCTAssertNil(query1.ignorePlurals);

    NSArray* VALUES = @[ [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], @[ @"de", @"en", @"fr"] ];
    NSArray* RAW_VALUES = @[ @"true", @"false", @"de,en,fr" ];
    for (int i = 0; i < VALUES.count; ++i) {
        query1.ignorePlurals = VALUES[i];
        XCTAssertEqualObjects(query1[@"ignorePlurals"], RAW_VALUES[i]);
        Query* query2 = [Query parse:[query1 build]];
        XCTAssertEqualObjects(query2.ignorePlurals, VALUES[i]);
    }

    // WARNING: There is no validation of ISO codes, so any string is interpreted as a single language.
    query1[@"ignorePlurals"] = @"invalid";
    XCTAssertNotNil(query1.ignorePlurals);
    XCTAssertEqual(1, ((NSArray*)query1.ignorePlurals).count);
}

- (void)test_advancedSyntax {
    Query* query1 = [Query new];
    XCTAssertNil(query1.advancedSyntax);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.advancedSyntax = value;
    XCTAssertEqualObjects(query1[@"advancedSyntax"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.advancedSyntax, value);
}

- (void)test_analytics {
    Query* query1 = [Query new];
    XCTAssertNil(query1.analytics);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.analytics = value;
    XCTAssertEqualObjects(query1[@"analytics"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.analytics, value);
}

- (void)test_synonyms {
    Query* query1 = [Query new];
    XCTAssertNil(query1.synonyms);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.synonyms = value;
    XCTAssertEqualObjects(query1[@"synonyms"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.synonyms, value);
}

- (void)test_replaceSynonymsInHighlight {
    Query* query1 = [Query new];
    XCTAssertNil(query1.replaceSynonymsInHighlight);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.replaceSynonymsInHighlight = value;
    XCTAssertEqualObjects(query1[@"replaceSynonymsInHighlight"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.replaceSynonymsInHighlight, value);
}

- (void)test_minProximity {
    Query* query1 = [Query new];
    XCTAssertNil(query1.minProximity);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.minProximity = value;
    XCTAssertEqualObjects(query1[@"minProximity"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.minProximity, value);
}

- (void)test_removeWordsIfNoResults {
    Query* query1 = [Query new];
    XCTAssertNil(query1.removeWordsIfNoResults);

    for (NSString* value in @[ @"allOptional", @"firstWords", @"lastWords", @"none" ]) {
        query1.removeWordsIfNoResults = value;
        XCTAssertEqualObjects(query1[@"removeWordsIfNoResults"], value);
        Query* query2 = [Query parse:[query1 build]];
        XCTAssertEqualObjects(query2.removeWordsIfNoResults, value);
    }

    query1[@"removeWordsIfNoResults"] = @"invalid";
    XCTAssertNil(query1.removeWordsIfNoResults);
}

- (void)test_removeStopWords {
    Query* query1 = [Query new];
    XCTAssertNil(query1.removeStopWords);

    NSArray* VALUES = @[ [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], @[ @"en", @"fr"] ];
    NSArray* RAW_VALUES = @[ @"true", @"false", @"en,fr" ];
    for (int i = 0; i < VALUES.count; ++i) {
        query1.removeStopWords = VALUES[i];
        XCTAssertEqualObjects(query1[@"removeStopWords"], RAW_VALUES[i]);
        Query* query2 = [Query parse:[query1 build]];
        XCTAssertEqualObjects(query2.removeStopWords, VALUES[i]);
    }

    // WARNING: There is no validation of ISO codes, so any string is interpreted as a single language.
    query1[@"removeStopWords"] = @"invalid";
    XCTAssertNotNil(query1.removeStopWords);
    XCTAssertEqual(1, ((NSArray*)query1.removeStopWords).count);
}

- (void)test_exactOnSingleWordQuery {
    Query* query1 = [Query new];
    XCTAssertNil(query1.exactOnSingleWordQuery);

    for (NSString* value in @[ @"none", @"word", @"attribute" ]) {
        query1.exactOnSingleWordQuery = value;
        XCTAssertEqualObjects(query1[@"exactOnSingleWordQuery"], value);
        Query* query2 = [Query parse:[query1 build]];
        XCTAssertEqualObjects(query2.exactOnSingleWordQuery, value);
    }

    query1[@"exactOnSingleWordQuery"] = @"invalid";
    XCTAssertNil(query1.exactOnSingleWordQuery);
}

- (void)test_alternativesAsExact {
    Query* query1 = [Query new];
    XCTAssertNil(query1.alternativesAsExact);

    NSArray* VALUES = @[ @"ignorePlurals", @"singleWordSynonym", @"multiWordsSynonym" ];
    query1.alternativesAsExact = VALUES;
    XCTAssertEqualObjects(query1.alternativesAsExact, VALUES);
    XCTAssertEqualObjects(query1[@"alternativesAsExact"], [VALUES componentsJoinedByString:@","]);
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.alternativesAsExact, VALUES);

    query1[@"alternativesAsExact"] = @"invalid";
    XCTAssertNotNil(query1.alternativesAsExact);
    XCTAssertEqual(0, query1.alternativesAsExact.count);
}

- (void)test_page {
    Query* query1 = [Query new];
    XCTAssertNil(query1.page);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.page = value;
    XCTAssertEqualObjects(query1[@"page"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.page, value);
}

- (void)test_hitsPerPage {
    Query* query1 = [Query new];
    XCTAssertNil(query1.hitsPerPage);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.hitsPerPage = value;
    XCTAssertEqualObjects(query1[@"hitsPerPage"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.hitsPerPage, value);
}

- (void)test_offset {
    Query* query1 = [Query new];
    XCTAssertNil(query1.offset);
    
    NSNumber* value = [NSNumber numberWithInt:4];
    query1.offset = value;
    XCTAssertEqualObjects(query1[@"offset"], @"4");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.offset, value);
}

- (void)test_length {
    Query* query1 = [Query new];
    XCTAssertNil(query1.length);
    
    NSNumber* value = [NSNumber numberWithInt:4];
    query1.length = value;
    XCTAssertEqualObjects(query1[@"length"], @"4");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.length, value);
}

- (void)test_getRankingInfo {
    Query* query1 = [Query new];
    XCTAssertNil(query1.getRankingInfo);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.getRankingInfo = value;
    XCTAssertEqualObjects(query1[@"getRankingInfo"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.getRankingInfo, value);
}

- (void)test_restrictHighlightAndSnippetArrays {
    Query* query1 = [Query new];
    XCTAssertNil(query1.restrictHighlightAndSnippetArrays);
    
    NSNumber* value = [NSNumber numberWithBool:FALSE];
    query1.restrictHighlightAndSnippetArrays = value;
    XCTAssertEqualObjects(query1[@"restrictHighlightAndSnippetArrays"], @"false");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.restrictHighlightAndSnippetArrays, value);
}

- (void)test_distinct {
    Query* query1 = [Query new];
    XCTAssertNil(query1.distinct);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.distinct = value;
    XCTAssertEqualObjects(query1[@"distinct"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.distinct, value);
}

- (void)test_maxValuesPerFacet {
    Query* query1 = [Query new];
    XCTAssertNil(query1.maxValuesPerFacet);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.maxValuesPerFacet = value;
    XCTAssertEqualObjects(query1[@"maxValuesPerFacet"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.maxValuesPerFacet, value);
}

- (void)test_aroundLatLngViaIP {
    Query* query1 = [Query new];
    XCTAssertNil(query1.aroundLatLngViaIP);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.aroundLatLngViaIP = value;
    XCTAssertEqualObjects(query1[@"aroundLatLngViaIP"], @"true");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.aroundLatLngViaIP, value);
}

- (void)test_aroundRadius {
    Query* query1 = [Query new];
    XCTAssertNil(query1.aroundRadius);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.aroundRadius = value;
    XCTAssertEqualObjects(query1[@"aroundRadius"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.aroundRadius, value);
}

- (void)test_aroundPrecision {
    Query* query1 = [Query new];
    XCTAssertNil(query1.aroundPrecision);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.aroundPrecision = value;
    XCTAssertEqualObjects(query1[@"aroundPrecision"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.aroundPrecision, value);
}

- (void)test_minimumAroundRadius {
    Query* query1 = [Query new];
    XCTAssertNil(query1.minimumAroundRadius);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.minimumAroundRadius = value;
    XCTAssertEqualObjects(query1[@"minimumAroundRadius"], @"6");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.minimumAroundRadius, value);
}

- (void)test_percentileComputation {
    Query* query1 = [Query new];
    XCTAssertNil(query1.percentileComputation);
    
    NSNumber* value = [NSNumber numberWithBool:FALSE];
    query1.percentileComputation = value;
    XCTAssertEqualObjects(query1[@"percentileComputation"], @"false");
    Query* query2 = [Query parse:[query1 build]];
    XCTAssertEqualObjects(query2.percentileComputation, value);
}

// MARK: Places

- (void)testPlacesClient {
    PlacesClient* client = [[PlacesClient alloc] init];
    PlacesQuery* query = [[PlacesQuery alloc] init];
    [client search:query completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    client = [[PlacesClient alloc] initWithAppID:@"APP_ID" apiKey:@"API_KEY"];
}

- (void)testPlacesQuery_type {
    PlacesQuery* query1 = [PlacesQuery new];
    XCTAssertNil(query1.type);

    NSArray* VALUES = @[ @"city", @"country", @"address", @"busStop", @"trainStation", @"townhall", @"airport" ];
    for (int i = 0; i < VALUES.count; ++i) {
        query1.type = VALUES[i];
        XCTAssertEqualObjects(query1[@"type"], VALUES[i]);
        PlacesQuery* query2 = [PlacesQuery parse:[query1 build]];
        XCTAssertEqualObjects(query2.type, VALUES[i]);
    }

    query1[@"type"] = @"invalid";
    XCTAssertNil(query1.type);
}

- (void)testPlacesQuery_hitsPerPage {
    PlacesQuery* query1 = [PlacesQuery new];
    XCTAssertNil(query1.hitsPerPage);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.hitsPerPage = value;
    XCTAssertEqualObjects(query1[@"hitsPerPage"], @"6");
    PlacesQuery* query2 = [PlacesQuery parse:[query1 build]];
    XCTAssertEqualObjects(query2.hitsPerPage, value);
}

- (void)testPlacesQuery_aroundLatLngViaIP {
    PlacesQuery* query1 = [PlacesQuery new];
    XCTAssertNil(query1.aroundLatLngViaIP);

    NSNumber* value = [NSNumber numberWithBool:YES];
    query1.aroundLatLngViaIP = value;
    XCTAssertEqualObjects(query1[@"aroundLatLngViaIP"], @"true");
    PlacesQuery* query2 = [PlacesQuery parse:[query1 build]];
    XCTAssertEqualObjects(query2.aroundLatLngViaIP, value);
}

- (void)testPlacesQuery_aroundRadius {
    PlacesQuery* query1 = [PlacesQuery new];
    XCTAssertNil(query1.aroundRadius);

    NSNumber* value = [NSNumber numberWithInt:6];
    query1.aroundRadius = value;
    XCTAssertEqualObjects(query1[@"aroundRadius"], @"6");
    PlacesQuery* query2 = [PlacesQuery parse:[query1 build]];
    XCTAssertEqualObjects(query2.aroundRadius, value);
}

@end
