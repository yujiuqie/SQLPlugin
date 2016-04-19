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

@property (nonatomic, strong) SQLStoreSharedManager *storeManager;
@property (nonatomic, strong) NSString *testDBPath;

@end

@implementation SQLPluginTests

- (void)setUp
{
    [super setUp];
    
    _storeManager = [SQLStoreSharedManager sharedManager];
    
    NSBundle *testBundle = [NSBundle bundleWithIdentifier:@"com.alfredjiang.SQLPluginTests"];
    _testDBPath = [NSString stringWithFormat:@"%@/SQLPluginTestDB.sqlite",[testBundle resourcePath]];
}

- (void)tearDown
{
    [_storeManager close];
    [super tearDown];
}

- (void)testOpenSqliteDB
{
    XCTAssert([_storeManager openDatabaseAtPath:_testDBPath], @"Pass");
}

- (void)testCreateTable
{
    [_storeManager executeSQLCommand:@"create table easy (a text)"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"PRAGMA table_info(easy)"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertNotNil(table);
                                                    }];
                          }];
    
    [_storeManager executeSQLCommand:@"create table qfoo (foo text)"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"PRAGMA table_info(qfoo)"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertNotNil(table);
                                                    }];
                          }];
}

- (void)testDropTable
{
    [_storeManager executeSQLCommand:@"drop table easy"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"PRAGMA table_info(easy)"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertNil(table);
                                                    }];
                          }];
}

- (void)testInsertItem
{
    [_storeManager executeSQLCommand:@"insert into qfoo values ('hi')"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"select * from qfoo where foo like 'h%'"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertEqual(table.rowCount, @1);
                                                    }];
                          }];
    
    [_storeManager executeSQLCommand:@"insert into qfoo values ('hello')"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"select * from qfoo where foo like 'h%'"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertEqual(table.rowCount, @2);
                                                    }];
                          }];
    
    [_storeManager executeSQLCommand:@"insert into qfoo values ('not')"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"SELECT * FROM qfoo"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertEqual(table.rowCount, @3);
                                                    }];
                          }];
}

- (void)testUpdateItem
{
    [_storeManager executeSQLCommand:@"update qfoo set foo = 'hii' where foo = 'hi'"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"select * from qfoo where foo = 'hii'"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertEqual(table.rowCount, @1);
                                                    }];
                          }];
}

- (void)testDeleteItem
{
    [_storeManager executeSQLCommand:@"delete from qfoo where foo like 'h%'"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"select * from qfoo"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertEqual(table.rowCount, @1);
                                                    }];
                          }];
    
    [_storeManager executeSQLCommand:@"delete from qfoo"
                            inDBPath:_testDBPath
                          completion:^(SQLTableDescription *table, NSError *error) {
                              
                              XCTAssert(error.code == 0, @"Pass");
                              
                              [_storeManager executeSQLCommand:@"select * from qfoo"
                                                      inDBPath:_testDBPath
                                                    completion:^(SQLTableDescription *table, NSError *error) {
                                                        
                                                        XCTAssert(error.code == 0, @"Pass");
                                                        XCTAssertEqual(table.rowCount, @0);
                                                    }];
                          }];
}

@end
