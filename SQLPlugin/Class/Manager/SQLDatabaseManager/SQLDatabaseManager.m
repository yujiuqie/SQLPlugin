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

- (void)addDatabaseItems:(NSMutableArray *)items
{
    [items enumerateObjectsUsingBlock:^(SQLDatabaseModel * obj, NSUInteger idx, BOOL * stop) {
        [self addDatabaseItem:obj];
    }];
}

- (void)addDatabaseItem:(SQLDatabaseModel *)item
{
    [self removeDatabaseItem:item];
    
    [self.recordDatabaseList addObject:item];
    
    [[NSUserDefaults standardUserDefaults] setObject:[self archiver:self.recordDatabaseList] forKey:SQLDatabaseManagerRecordDatabaseList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeDatabaseItem:(SQLDatabaseModel *)item
{
    self.recordDatabaseList = [NSMutableArray arrayWithArray:[self recordDatabaseList]];
    
    __block SQLDatabaseModel *existdb = nil;
    
    [self.recordDatabaseList enumerateObjectsUsingBlock:^(SQLDatabaseModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.path isEqualToString:item.path]) {
            existdb = obj;
            *stop = YES;
        }
    }];
    
    if (existdb) {
        [self.recordDatabaseList removeObject:existdb];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[self archiver:self.recordDatabaseList] forKey:SQLDatabaseManagerRecordDatabaseList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)recordDatabaseItems
{
    self.recordDatabaseList = [NSMutableArray arrayWithArray:[self loadArchiver:[[NSUserDefaults standardUserDefaults] objectForKey:SQLDatabaseManagerRecordDatabaseList]]];
    
    if ([self.recordDatabaseList count] == 0) {
        
        return @[];
    }
    
    return self.recordDatabaseList;
}

- (void)clearDatabaseItems
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SQLDatabaseManagerRecordDatabaseList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableData *)archiver:(NSMutableArray *)list
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:list forKey:@"kArchivingDataKey"];
    [archiver finishEncoding];
    
    return data;
}

- (NSArray *)loadArchiver:(id)data
{
    if (![data isKindOfClass:[NSData class]]) {
        return @[];
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSArray *archivingData = [unarchiver decodeObjectForKey:@"kArchivingDataKey"];
    [unarchiver finishDecoding];
    
    return archivingData;
}

#pragma mark -

- (SQLDatabaseModel *)databaseInPath:(NSString *)path
{
    __block SQLDatabaseModel *database = nil;
    [self.recordDatabaseList enumerateObjectsUsingBlock:^(SQLDatabaseModel *  obj, NSUInteger idx, BOOL * stop) {
        if ([obj.path isEqualToString:path]) {
            database = obj;
            *stop = YES;
        }
    }];
    
    return database;
}

@end
