//
//  SQLPluginTests.m
//  SQLPluginTests
//
//  Created by viktyz on 16/4/18.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLStoreSharedManager.h"

@interface SQLPluginTests : XCTestCase

@property (nonatomic,strong) SQLStoreSharedManager *storeManager;

@end

@implementation SQLPluginTests

- (void)setUp {
    
    [super setUp];
    _storeManager = [SQLStoreSharedManager sharedManager];
}

- (void)tearDown {
    
    [_storeManager close];
    [super tearDown];
}

- (void)testOpenSqliteDB {
    
    NSBundle *testBundle = [NSBundle bundleWithIdentifier:@"com.alfredjiang.SQLPluginTests"];
    NSString *testDBPath = [NSString stringWithFormat:@"%@/SQLPluginTestDB.sqlite",[testBundle resourcePath]];
    XCTAssert([_storeManager openDatabaseAtPath:testDBPath], @"Pass");
}

@end
