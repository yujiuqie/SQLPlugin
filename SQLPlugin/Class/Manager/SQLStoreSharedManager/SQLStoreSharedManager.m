//
//  SQLStoreSharedManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/4.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLStoreSharedManager.h"

#import "FMDB.h"

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface SQLStoreSharedManager ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@end

@implementation SQLStoreSharedManager

static SQLStoreSharedManager *_sharedManager = nil;

+(instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _sharedManager = [[SQLStoreSharedManager alloc] init];
        });
    }
    
    return _sharedManager;
}

-(void)close
{
    [self.databaseQueue close];
}

-(BOOL)openDatabaseAtPath:(NSString*)path
{
    // Close Existing Database Queue
    if(self.databaseQueue)
    {
        [self.databaseQueue close];
        self.databaseQueue = nil;
    }
    
    // Open Path
    self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    
    return (self.databaseQueue != nil);
}

-(void)getAllTablesinPath:(NSString *)path completion:(void (^)(NSArray *))completion
{
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         NSMutableArray *tables = [[NSMutableArray alloc] init];
         FMResultSet *result = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type='table'"];
         
         while([result next])
         {
             SQLTableDescription *table = [[SQLTableDescription alloc] init];
             table.name = result.resultDictionary[@"name"];
             table.path = path;
             
             NSMutableArray *properties = [[NSMutableArray alloc] init];
             FMResultSet *propertiesResult = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)",table.name]];
             
             while ([propertiesResult next])
             {
                 SQLTableProperty *property = [[SQLTableProperty alloc] init];
                 property.name = propertiesResult.resultDictionary[@"name"];
                 [properties addObject:property];
             }
             
             table.properties = properties;
             
             FMResultSet *count = [db executeQuery:[NSString stringWithFormat:@"SELECT Count(*) FROM %@", table.name]];
             
             while([count next])
             {
                 table.rowCount = count.resultDictionary[@"Count(*)"];
             }
             
             [tables addObject:table];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if(completion)
             {
                 completion(tables);
             }
         });
     }];
}

-(void)executeSQLCommand:(NSString *)command inDBPath:(NSString *)path completion:(void(^)(SQLTableDescription *table, NSError *error))completion
{
    if (!self.databaseQueue) {
        
        if (![self openDatabaseAtPath:path]) {
            
            if(completion)
            {
                NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:@"SQL error or missing database" forKey:NSLocalizedDescriptionKey];
                completion(nil,[NSError errorWithDomain:@"FMDatabase" code:SQLITE_ERROR userInfo:errorMessage]);
            }
        }
    }
    
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         SQLTableDescription *table = [[SQLTableDescription alloc] init];
         table.name = @"";
         table.path = path;
         
         FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"%@",command]];
         
         BOOL cacheProperty = NO;
         
         NSMutableArray *rows = [[NSMutableArray alloc] init];
         
         while([result next])
         {
             NSMutableArray *properties = [[NSMutableArray alloc] init];
             NSMutableArray *row = [[NSMutableArray alloc] init];
             
             [[result.resultDictionary allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
                 
                 if (!cacheProperty)
                 {
                     SQLTableProperty *property = [[SQLTableProperty alloc] init];
                     property.name = key;
                     [properties addObject:property];
                 }
                 
                 [row addObject:result.resultDictionary[key]];
             }];
             
             if (!cacheProperty)
             {
                 table.properties = properties;
                 cacheProperty = YES;
             }
             
             [rows addObject:row];
         }
         
         table.rows = rows;
         table.rowCount = [NSNumber numberWithInteger:[rows count]];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if(completion)
             {
                 completion(table, [db lastError]);
             }
         });
     }];
}

-(void)getRowsWithCommand:(NSString *)command withTableDescription:(SQLTableDescription*)table completion:(void(^)(NSArray*))completion
{
    [self.databaseQueue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"%@",command]];
         
         NSMutableArray *rows = [[NSMutableArray alloc] init];
         
         while([result next])
         {
             NSMutableArray *row = [[NSMutableArray alloc] init];
             
             for (SQLTableProperty *property in table.properties)
             {
                 [row addObject:result.resultDictionary[property.name]];
             }
             
             [rows addObject:row];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if(completion)
             {
                 completion(rows);
             }
         });
     }];
}

-(void)getRowsWithOffset:(NSNumber*)offset withTableDescription:(SQLTableDescription*)table completion:(void(^)(NSArray*))completion
{
    [self getRowsWithCommand:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ %@ LIMIT %@,%d" ,table.name,table.selectedPropertName,(table.desc ? @"DESC" : @"ASC"), offset, 50] withTableDescription:table completion:completion];
}

@end
