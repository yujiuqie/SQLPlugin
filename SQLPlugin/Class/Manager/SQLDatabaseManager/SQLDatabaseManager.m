//
//  SQLDatabaseManager.m
//  SQLPlugin
//
//  Created by viktyz on 16/4/6.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "SQLDatabaseManager.h"

#define SQLDatabaseManagerRecordDatabaseList @"SQLDatabaseManagerRecordDatabaseList"

@interface SQLDatabaseManager()

@property (nonatomic,strong,readwrite) NSMutableArray *recordDatabaseList;
@property (nonatomic, strong, readwrite) NSMutableArray *databaseDescriptionList;

@end

@implementation SQLDatabaseManager

static SQLDatabaseManager *_sharedManager = nil;

+ (instancetype)sharedManager
{
    if(!_sharedManager)
    {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _sharedManager = [[SQLDatabaseManager alloc] init];
        });
    }
    
    return _sharedManager;
}

- (void)clearDatabaseDescriptions
{
    if (!_databaseDescriptionList)
    {
        return;
    }
    
    [_databaseDescriptionList removeAllObjects];
}

#pragma mark -

- (NSArray *)databaseDescriptions
{
    if (!_databaseDescriptionList)
    {
        _databaseDescriptionList = [NSMutableArray array];
    }
    
    return [_databaseDescriptionList copy];
}

- (void)addDatabaseDescription:(SQLDatabaseDescription *)databaseDescription
{
    if (!_databaseDescriptionList)
    {
        _databaseDescriptionList = [NSMutableArray array];
    }
    
    [_databaseDescriptionList enumerateObjectsUsingBlock:^(SQLDatabaseDescription *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.path isEqualToString:databaseDescription.path])
        {
            [_databaseDescriptionList removeObject:obj];
        }
    }];
    
    [_databaseDescriptionList insertObject:databaseDescription atIndex:0];
}

- (void)removeDatabaseDescription:(SQLDatabaseDescription *)databaseDescription
{
    if (_databaseDescriptionList
        || [_databaseDescriptionList count] == 0
        || ![_databaseDescriptionList containsObject:databaseDescription])
    {
        return;
    }
    
    [_databaseDescriptionList removeObject:databaseDescription];
}

- (SQLDatabaseDescription *)databaseDescriptionInPath:(NSString *)path;
{
    __block SQLDatabaseDescription *database = nil;
    
    [self.databaseDescriptions enumerateObjectsUsingBlock:^(SQLDatabaseDescription *  obj, NSUInteger idx, BOOL * stop) {
        
        if ([obj.path isEqualToString:path])
        {
            database = obj;
            *stop = YES;
        }
    }];
    
    return database;
}

@end
