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
    [query parameterWithName:@"foo"];
    
    // Subscript.
    query[@"foo"] = [query[@"foo"] stringByAppendingString:@"baz"];
    
    // Copying.
    Query* query2 = [query copy];
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
    query.exactOnSingleWordQuery = @"attribute";
    query.alternativesAsExact = @[ @"foo", @"bar" ];
    query.page = [NSNumber numberWithInt:6];
    query.hitsPerPage = [NSNumber numberWithInt:66];
    query.attributesToRetrieve = @[ @"foo", @"bar" ];
    query.attributesToHighlight = @[ @"foo", @"bar" ];
    query.attributesToSnippet = @[ @"foo", @"bar" ];
    query.getRankingInfo = [NSNumber numberWithBool:YES];
    query.highlightPreTag = @"<mark>";
    query.highlightPostTag = @"</mark>";
    query.snippetEllipsisText = @"...";
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
    query.aroundRadius = [NSNumber numberWithUnsignedInteger:[Query aroundRadiusAll]];
    query.aroundPrecision = [NSNumber numberWithInt:66];
    query.minimumAroundRadius = [NSNumber numberWithInt:666];
    query.insideBoundingBox = @[ [[GeoRect alloc] initWithP1:[[LatLng alloc] initWithLat:123.45 lng:67.89] p2:[[LatLng alloc] initWithLat:129.99 lng:69.99]] ];
    query.insidePolygon = @[ [[LatLng alloc] initWithLat:123.45 lng:67.89], [[LatLng alloc] initWithLat:129.99 lng:69.99], [[LatLng alloc] initWithLat:0.0 lng:0.0] ];
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

    // User agents.
    client.userAgents = [client.userAgents arrayByAddingObject:[[LibraryVersion alloc] initWithName:@"FooBar" version:@"1.2.3"]];
    
    // Timeouts.
    client.timeout = client.timeout + 10;
    client.searchTimeout = client.searchTimeout + 5;

    // Hosts.
    client.readHosts = [client.readHosts arrayByAddingObject:@"nowhere.net"];
    client.writeHosts = [client.writeHosts arrayByAddingObject:@"nobody.com"];
    [client setHosts:@[ @"nowhere.net", @"nobody.com", @"never.org" ]];
    
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
    [index partialUpdateObjects:@[ DUMMY_JSON ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [index search:[Query new] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
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

@end
