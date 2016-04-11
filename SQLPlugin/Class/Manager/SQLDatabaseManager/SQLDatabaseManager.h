//
//  SQLDatabaseManager.h
//  SQLPlugin
//
//  Created by viktyz on 16/4/6.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLSimulatorModel.h"

@interface SQLDatabaseManager : NSObject

+ (instancetype)sharedManager;

- (void)addDatabaseItems:(NSMutableArray<SQLDatabaseModel *> *)items;

- (void)addDatabaseItem:(SQLDatabaseModel *)item;

- (void)removeDatabaseItem:(SQLDatabaseModel *)item;

- (NSArray *)recordDatabaseItems;

- (void)clearDatabaseItems;

- (SQLDatabaseModel *)databaseInPath:(NSString *)path;

@end
