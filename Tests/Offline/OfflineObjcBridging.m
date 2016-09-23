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
@interface OfflineObjcBridging : XCTestCase

@end


@implementation OfflineObjcBridging

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testOfflineClient {
    OfflineClient* client = [[OfflineClient alloc] initWithAppID:@"APPID" apiKey:@"APIKEY"];
    [client enableOfflineModeWithLicenseKey:@"LICENSE_KEY"];

    // Operations
    // ----------
    [client listOfflineIndexes:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client deleteOfflineIndexWithName:@"name" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
    [client moveOfflineIndexFrom:@"from" to:@"to" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        // Do nothing.
    }];
}

- (void)testOfflineIndex {
    OfflineClient* client = [[OfflineClient alloc] initWithAppID:@"APPID" apiKey:@"APIKEY"];
    OfflineIndex* index = [client offlineIndexWithName:@"INDEX_NAME"];

    // Read operations
    // ---------------
    XCTestExpectation* expectation_search = [self expectationWithDescription:@"search"];
    [index search:[Query new] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_search fulfill];
    }];
    XCTestExpectation* expectation_getSettings = [self expectationWithDescription:@"getSettings"];
    [index getSettings:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_getSettings fulfill];
    }];
    XCTestExpectation* expectation_browseWithQuery = [self expectationWithDescription:@"browseWithQuery"];
    [index browseWithQuery:[Query new] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_browseWithQuery fulfill];
    }];
    XCTestExpectation* expectation_browseFromCursor = [self expectationWithDescription:@"browseFromCursor"];
    [index browseFromCursor:@"cursor" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_browseFromCursor fulfill];
    }];
    XCTestExpectation* expectation_searchDisjunctiveFaceting = [self expectationWithDescription:@"searchDisjunctiveFaceting"];
    [index searchDisjunctiveFaceting:[Query new] disjunctiveFacets:@[ @"disjunctive", @"facets" ] refinements:@{ @"facets": @[ @"refinements" ] } completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_searchDisjunctiveFaceting fulfill];
    }];
    XCTestExpectation* expectation_multipleQueries = [self expectationWithDescription:@"multipleQueries"];
    [index multipleQueries:@[ [Query new] ] strategy:@"stopIfEnoughMatches" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_multipleQueries fulfill];
    }];
    XCTestExpectation* expectation_getObjectWithID = [self expectationWithDescription:@"getObjectWithID"];
    [index getObjectWithID:@"snoopy" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_getObjectWithID fulfill];
    }];
    XCTestExpectation* expectation_getObjectWithIDAttributes = [self expectationWithDescription:@"getObjectWithIDAttributes"];
    [index getObjectWithID:@"snoopy" attributesToRetrieve:@[ @"foo", @"bar" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_getObjectWithIDAttributes fulfill];
    }];
    XCTestExpectation* expectation_getObjectsWithIDs = [self expectationWithDescription:@"getObjectsWithIDs"];
    [index getObjectsWithIDs:@[ @"snoopy", @"woodstock" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_getObjectsWithIDs fulfill];
    }];
    XCTestExpectation* expectation_getObjectsWithIDsAttributes = [self expectationWithDescription:@"getObjectsWithIDsAttributes"];
    [index getObjectsWithIDs:@[ @"snoopy", @"woodstock" ] attributesToRetrieve:@[ @"foo", @"bar" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_getObjectsWithIDsAttributes fulfill];
    }];
    
    // Write operations (async)
    // ------------------------
    NSDictionary<NSString*, id>* DUMMY_JSON = @{ @"objectID": @"snoopy", @"kind": @"dog" };
    [index beginTransaction];
    XCTestExpectation* expectation_saveObject = [self expectationWithDescription:@"saveObject"];
    [index saveObject:DUMMY_JSON completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_saveObject fulfill];
    }];
    XCTestExpectation* expectation_saveObjects = [self expectationWithDescription:@"saveObjects"];
    [index saveObjects:@[ DUMMY_JSON ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_saveObjects fulfill];
    }];
    XCTestExpectation* expectation_deleteObjectWithID = [self expectationWithDescription:@"deleteObjectWithID"];
    [index deleteObjectWithID:@"snoopy" completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_deleteObjectWithID fulfill];
    }];
    XCTestExpectation* expectation_deleteObjectsWithIDs = [self expectationWithDescription:@"deleteObjectsWithIDs"];
    [index deleteObjectsWithIDs:@[ @"snoopy", @"woodstock" ] completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_deleteObjectsWithIDs fulfill];
    }];
    XCTestExpectation* expectation_setSettings = [self expectationWithDescription:@"setSettings"];
    [index setSettings:DUMMY_JSON completionHandler:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_setSettings fulfill];
    }];
    XCTestExpectation* expectation_clearIndex = [self expectationWithDescription:@"clearIndex"];
    [index clearIndex:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_clearIndex fulfill];
    }];
    XCTestExpectation* expectation_rollbackTransaction = [self expectationWithDescription:@"rollbackTransaction"];
    [index rollbackTransaction:^(NSDictionary<NSString*,id>* content, NSError* error) {
        [expectation_rollbackTransaction fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];

    // Write operations (sync)
    // ------------------------
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSError* error = nil;
        [index beginTransaction];
        [index saveObjectSync:DUMMY_JSON error:&error];
        XCTAssertNil(error);
        [index saveObjectsSync:@[ DUMMY_JSON ] error:&error];
        XCTAssertNil(error);
        [index deleteObjectSyncWithID:@"snoopy" error:&error];
        XCTAssertNil(error);
        [index deleteObjectsSyncWithIDs:@[ @"snoopy", @"woodstock" ] error:&error];
        XCTAssertNil(error);
        [index setSettingsSync:DUMMY_JSON error:&error];
        XCTAssertNil(error);
        [index clearIndexSyncAndReturnError:&error];
        XCTAssertNil(error);
        [index commitTransactionSyncAndReturnError:&error];
        XCTAssertNil(error);
    });
}

@end