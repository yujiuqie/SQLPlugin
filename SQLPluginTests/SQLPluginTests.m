//
//  SQLPluginTests.m
//  SQLPluginTests
//
//  Created by viktyz on 16/4/17.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLStoreSharedManager.h"

@interface SQLPluginTests : XCTestCase

@property (nonatomic, strong) SQLStoreSharedManager *sqlManager;

@end

@implementation SQLPluginTests

- (void)setUp {
    [super setUp];
    
    _sqlManager = [SQLStoreSharedManager sharedManager];
}

- (void)tearDown {
    
    [_sqlManager close];
    
    [super tearDown];
}

- (void)testOpenSqliteDB {

    NSBundle* testsBundle = [NSBundle bundleWithIdentifier:@"com.alfredjiang.SQLPluginTests"];
    NSString *testDBPath = [NSString stringWithFormat:@"%@/SQLPluginTestsDB.sqlite",[testsBundle resourcePath]];
    
    XCTAssert([[SQLStoreSharedManager sharedManager] openDatabaseAtPath:testDBPath], @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
